//
//  SLYButton.m
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/24/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#import <os/log.h>

#import "SLYButton.h"

#define Log(fmt, ...) os_log(OS_LOG_DEFAULT, "[VirtualController(SLYButton)] " fmt "\n", ##__VA_ARGS__)

NSString * const SLYButtonUserDataTitleKey = @"Title";
NSString * const SLYButtonUserDataTextureAtlasNameKey = @"TextureAtlasName";
NSString * const SLYButtonUserDataUpTextureNameKey = @"UpTextureName";
NSString * const SLYButtonUserDataDownTextureNameKey = @"DownTextureName";
NSString * const SLYButtonUserDataSoundFileNameKey = @"SoundFileName";
NSString * const SLYButtonUserDataUpActionNameKey = @"UpActionName";
NSString * const SLYButtonUserDataDownActionNameKey = @"DownActionName";

static NSString * const SLYDefaultTextureAtlasName = @"Sprites";
NSString *_defaultTextureAtlasName = SLYDefaultTextureAtlasName;

static NSString * const SLYDefaultUpActionName = @"Pulse";
NSString *_defaultUpActionName = SLYDefaultUpActionName;

static NSString * const SLYDefaultDownActionName = @"";
NSString *_defaultDownActionName = SLYDefaultDownActionName;

@interface SLYButton ()
@property SKSpriteNode *sprite;
@property SKLabelNode *label;

- (void)reset;
- (void)configureFromUserData;
- (void)down:(CGPoint)location;
- (void)up:(CGPoint)location;
@end

@implementation SLYButton

- initWithCoder:(NSCoder *)coder
{
	if (!(self = [super initWithCoder:coder]))
		return self;

	self.texture = nil;
	[self configureFromUserData];
	return self;
}

- (void)reset
{
	self.title = nil;
	self.textureAtlasName = nil;
	self.upTextureName = nil;
	self.downTextureName = nil;
	self.soundFileName = nil;
	self.skUpActionName = nil;
	self.skDownActionName = nil;

	self.textureAtlas = nil;
	self.upTexture = nil;
	self.downTexture = nil;
	self.skUpAction = nil;
	self.skDownAction = nil;
}

- (void)configureFromUserData
{
	Log("name=%{public}@ self.scene=%{public}@", self.name, self.scene);
	Log("name=%{public}@ self.parent=%{public}@", self.name, self.parent);

	if (self.userData[SLYButtonUserDataTitleKey])
		self.title = self.userData[SLYButtonUserDataTitleKey];

	@try {
		if (self.userData[SLYButtonUserDataTextureAtlasNameKey]) {
			self.textureAtlasName = self.userData[SLYButtonUserDataTextureAtlasNameKey];
		} else {
			SKNode *node = self;
			while ((node = node.parent)) {
				if (node.userData[SLYButtonUserDataTextureAtlasNameKey]) {
					self.textureAtlasName = node.userData[SLYButtonUserDataTextureAtlasNameKey];
					break;
				}
			}
			if (!self.textureAtlasName)
				self.textureAtlasName = SLYButton.defaultTextureAtlasName;
		}
		self.textureAtlas = [SKTextureAtlas atlasNamed:self.textureAtlasName];
	} @finally {
		if (!self.textureAtlas) {
			self.textureAtlasName = SLYButton.defaultTextureAtlasName;
			self.textureAtlas = [SKTextureAtlas atlasNamed:self.textureAtlasName];
		}
	}

	if (self.userData[SLYButtonUserDataUpTextureNameKey])
		self.upTextureName = self.userData[SLYButtonUserDataUpTextureNameKey];
	if (!self.upTextureName)
		self.upTextureName = [NSString stringWithFormat:@"%@_Up", self.name];
	if ([self.textureAtlas.textureNames containsObject:self.upTextureName])
		self.upTexture = [self.textureAtlas textureNamed:self.upTextureName];

	if (self.userData[SLYButtonUserDataDownTextureNameKey])
		self.downTextureName = self.userData[SLYButtonUserDataDownTextureNameKey];
	if (!self.downTextureName)
		self.downTextureName = [NSString stringWithFormat:@"%@_Down", self.name];
	if ([self.textureAtlas.textureNames containsObject:self.downTextureName])
		self.downTexture = [self.textureAtlas textureNamed:self.downTextureName];

	if (self.userData[SLYButtonUserDataSoundFileNameKey])
		self.soundFileName = self.userData[SLYButtonUserDataSoundFileNameKey];

	if (!self.downTexture) {
		if (self.userData[SLYButtonUserDataUpActionNameKey])
			self.skUpActionName = self.userData[SLYButtonUserDataUpActionNameKey];
		if (!self.skUpActionName)
			self.skUpActionName = SLYButton.defaultUpActionName;
		self.skUpAction = [SKAction actionNamed:self.skUpActionName];

		if (self.skUpAction && self.soundFileName)
			self.skUpAction = [SKAction group:@[
				self.skUpAction,
				[SKAction playSoundFileNamed:self.soundFileName waitForCompletion:NO]
			]];
	}

	/* down action not implemented */

	if (self.upTexture) {
		self.sprite = [SKSpriteNode spriteNodeWithTexture:self.upTexture];
		self.sprite.zPosition = 1000;
		[self addChild:self.sprite];
	}
	if (self.sprite && self.title) {
		self.label = SKLabelNode.new;
		self.label.fontName = @"Retro-Pixel-Arcade-Regular";
		self.label.fontSize = 32;
		self.label.fontColor = NSColor.whiteColor;
		self.label.text = self.title;
		self.label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
		self.label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
		self.label.zPosition = 1001;
		[self.sprite addChild:self.label];
	}
}

- (void)down:(CGPoint)location
{
	if (self.downTexture)
		self.sprite.texture = self.downTexture;
	if ([self.target respondsToSelector:self.downAction])
		[self.target performSelector:self.downAction withObject:self];
}

- (void)up:(CGPoint)location
{
	SEL action = self.upAction;
	if (!action)
		action = self.action;

	if ([self containsPoint:location])
		if (self.skUpAction) {
			[self runAction:self.skUpAction completion:^{
				self.sprite.texture = self.upTexture;
				if (self.target && action)
					if ([self.target respondsToSelector:action])
						[self.target performSelector:action withObject:self];
			}];
		} else {
			self.sprite.texture = self.upTexture;
			if (self.target && action)
				if ([self.target respondsToSelector:action])
					[self.target performSelector:action withObject:self];
			if (self.soundFileName)
				[SKAction playSoundFileNamed:self.soundFileName waitForCompletion:NO];
		}
	else
		self.sprite.texture = self.upTexture;
}

// Needed to respond to touches & and events
- (BOOL)isUserInteractionEnabled
{
	return YES;
}

#if TARGET_OS_IOS || TARGET_OS_TV
// Touch-based event handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch *t in touches) {
		[self down:[t locationInNode:self.parent]];
	}
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	for (UITouch *t in touches) {
		(void)t;
	}
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch *t in touches) {
		[self up:[t locationInNode:self.parent]];
	}
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch *t in touches) {
		(void)t;
	}
}
#endif

#if TARGET_OS_OSX
// Mouse-based event handling

- (void)mouseDown:(NSEvent *)event {
	[self down:[event locationInNode:self.parent]];
}

- (void)mouseDragged:(NSEvent *)event {
}

- (void)mouseUp:(NSEvent *)event {
	[self up:[event locationInNode:self.parent]];
}

#endif

+ (NSString *)defaultTextureAtlasName
{
	return _defaultTextureAtlasName;
}

+ (void)setDefaultTextureAtlasName:(NSString *)name
{
	_defaultTextureAtlasName = name;
}

+ (NSString *)defaultUpActionName
{
	return _defaultUpActionName;
}

+ (void)setDefaultUpActionName:(NSString *)name
{
	_defaultUpActionName = name;
}

+ (NSString *)defaultDownActionName
{
	return _defaultDownActionName;
}

+ (void)setDefaultDownActionName:(NSString *)name
{
	_defaultDownActionName = name;
}

@end

@implementation SKNode (SLYButton)

- (SLYButton *)buttonWithName:(NSString *)name
{

	return [self buttonWithName:name forceConfigure:NO];
}

- (SLYButton *)buttonWithName:(NSString *)name forceConfigure:(BOOL)forceConfig;
{
	SLYButton *button = (SLYButton *)[self childNodeWithName:name];
	if (forceConfig) {
		[button reset];
		[button configureFromUserData];
	}
	return button;
}

@end

