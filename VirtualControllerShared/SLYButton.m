//
//  SLYButton.m
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/24/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#import "SLYButton.h"

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
@end

@implementation SLYButton

- initWithCoder:(NSCoder *)coder
{
	if (!(self = [super initWithCoder:coder]))
		return self;

	self.texture = nil;

	if (self.userData[SLYButtonUserDataTitleKey])
		self.title = self.userData[SLYButtonUserDataTitleKey];

	@try {
		if (self.userData[SLYButtonUserDataTextureAtlasNameKey]) {
			self.textureAtlasName = self.userData[SLYButtonUserDataTextureAtlasNameKey];
		} else {
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
		self.upTextureName = [NSString stringWithFormat:@"%@Up", self.name];
	if ([self.textureAtlas.textureNames containsObject:self.upTextureName])
		self.upTexture = [self.textureAtlas textureNamed:self.upTextureName];

	if (self.userData[SLYButtonUserDataDownTextureNameKey])
		self.downTextureName = self.userData[SLYButtonUserDataDownTextureNameKey];
	if (!self.downTextureName)
		self.downTextureName = [NSString stringWithFormat:@"%@Down", self.name];
	if ([self.textureAtlas.textureNames containsObject:self.downTextureName])
		self.downTexture = [self.textureAtlas textureNamed:self.downTextureName];

	if (self.userData[SLYButtonUserDataSoundFileNameKey])
		self.soundFileName = self.userData[SLYButtonUserDataSoundFileNameKey];

	if (self.userData[SLYButtonUserDataUpActionNameKey])
		self.upActionName = self.userData[SLYButtonUserDataUpActionNameKey];
	if (!self.upActionName)
		self.upActionName = SLYButton.defaultUpActionName;
	self.upAction = [SKAction actionNamed:self.upActionName];

	if (self.upAction && self.soundFileName)
		self.upAction = [SKAction group:@[
			self.upAction,
			[SKAction playSoundFileNamed:self.soundFileName waitForCompletion:NO]
		]];

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

	return self;
}

- (void)down:(CGPoint)location
{
	if (self.downTexture)
		self.sprite.texture = self.downTexture;
}

- (void)up:(CGPoint)location
{
	if ([self containsPoint:location])
		if (self.upAction) {
			[self runAction:self.upAction completion:^{
				self.sprite.texture = self.upTexture;
				if (self.target && self.action)
					if ([self.target respondsToSelector:self.action])
						[self.target performSelector:self.action withObject:self];
			}];
		} else {
			self.sprite.texture = self.upTexture;
			if (self.target && self.action)
				if ([self.target respondsToSelector:self.action])
					[self.target performSelector:self.action withObject:self];
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
