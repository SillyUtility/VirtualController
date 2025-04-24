//
//  GameScene.m
//  VirtualControllerShared
//
//  Created by Eddie Hillenbrand on 4/14/25.
//

#import <os/log.h>

#import "GameScene.h"
#import "DriverIPCController.h"

#import "VirtualController-Swift.h"
#import "NSApplication+Additions.h"
#import "AppDelegate.h"

#import "SLYButton.h"

#define Log(fmt, ...) os_log(OS_LOG_DEFAULT, "[VirtualController(GameScene)] " fmt "\n", ##__VA_ARGS__)

@interface GameScene ()
@end

@implementation GameScene {
	SKShapeNode *_spinnyNode;
	SKLabelNode *_driverNotInstalledLabel;
	SKLabelNode *_driverInstalledLabel;
	SLYButton *_settingsButton;
}

+ (GameScene *)newGameScene {
    GameScene *scene = (GameScene *)[SKScene nodeWithFileNamed:@"GameScene"];
    if (!scene) {
        NSLog(@"Failed to load GameScene.sks");
        abort();
    }

    // Set the scale mode to scale to fit the window
    //scene.scaleMode = SKSceneScaleModeAspectFill;
	scene.scaleMode = SKSceneScaleModeResizeFill;

    return scene;
}

- (void)showDriverNotInstalledLabel
{
	 Log("%{public}s", __func__);
	if (_driverNotInstalledLabel) {
		_driverNotInstalledLabel.hidden = NO;
		return;
	}
	_driverNotInstalledLabel = SKLabelNode.new;
	_driverNotInstalledLabel.fontName = @"Retro-Pixel-Arcade-Regular";
	_driverNotInstalledLabel.fontSize = 32;
	_driverNotInstalledLabel.fontColor = NSColor.whiteColor;
	_driverNotInstalledLabel.text = @"Driver not installed";
	Log("_driverNotInstalledLabel.frame=%{public}@", NSStringFromRect(_driverNotInstalledLabel.frame));
	[self addChild:_driverNotInstalledLabel];
}

- (void)removeDiverNotInstalledLabel
{
	 Log("%{public}s", __func__);
	if (_driverNotInstalledLabel) {
		[_driverNotInstalledLabel removeFromParent];
		_driverNotInstalledLabel = nil;
	}
}

- (void)showDriverInstalledLabel
{
	 Log("%{public}s", __func__);
	if (_driverInstalledLabel) {
		[self repositionDriverInstalledLabel];
		_driverInstalledLabel.hidden = NO;
		return;
	}
	_driverInstalledLabel = SKLabelNode.new;
	_driverInstalledLabel.fontName = @"Retro-Pixel-Arcade-Regular";
	_driverInstalledLabel.fontSize = 22;
	_driverInstalledLabel.fontColor = NSColor.whiteColor;
	_driverInstalledLabel.text = @"Driver installed";
	[self repositionDriverInstalledLabel];
	Log("_driverInstalledLabel.frame=%{public}@", NSStringFromRect(_driverInstalledLabel.frame));
	[self addChild:_driverInstalledLabel];
}

- (void)removeDiverInstalledLabel
{
	 Log("%{public}s", __func__);
	if (_driverInstalledLabel) {
		[_driverInstalledLabel removeFromParent];
		_driverInstalledLabel = nil;
	}
}

- (void)repositionDriverInstalledLabel
{
	CGSize ssize = self.size;
	CGSize lsize = _driverInstalledLabel.frame.size;
	CGFloat x = -(ssize.width / 2) + (lsize.width / 2) + 42;
	CGFloat y = (ssize.height / 2) - (lsize.height / 2) - 42;

	_driverInstalledLabel.position = CGPointMake(x, y);
}

- (void)didChangeSize:(CGSize)oldSize
{
	// Log("%{public}s", __func__);
	[self repositionDriverInstalledLabel];
}

- (void)setUpScene {
	if (!NSApp.appDelegate.driverInstallationController.installed)
		[self showDriverNotInstalledLabel];
	else
		[self showDriverInstalledLabel];

	_settingsButton = (SLYButton *)[self childNodeWithName:@"//Settings"];
	_settingsButton.target = self;
	_settingsButton.action = @selector(openSettings:);
	Log("%{public}s _settingsButton=%{public}@", __func__, _settingsButton);

    // Create shape node to use during mouse interaction
    CGFloat w = (self.size.width + self.size.height) * 0.05;
    _spinnyNode = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(w, w) cornerRadius:w * 0.3];

    _spinnyNode.lineWidth = 4.0;
    [_spinnyNode runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:M_PI duration:1]]];
    [_spinnyNode runAction:[SKAction sequence:@[
        [SKAction waitForDuration:0.5],
        [SKAction fadeOutWithDuration:0.5],
        [SKAction removeFromParent],
    ]]];
}

- (void)didMoveToView:(SKView *)view {
	//Log("%{public}s", __func__);
	[self setUpScene];
}

- (void)makeSpinnyAtPoint:(CGPoint)pos color:(SKColor *)color {
    SKShapeNode *spinny = [_spinnyNode copy];
    spinny.position = pos;
    spinny.strokeColor = color;
    [self addChild:spinny];
}

-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
}

#if TARGET_OS_IOS || TARGET_OS_TV
// Touch-based event handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_label runAction:[SKAction actionNamed:@"Pulse"] withKey:@"fadeInOut"];

    for (UITouch *t in touches) {
        [self makeSpinnyAtPoint:[t locationInNode:self] color:[SKColor greenColor]];
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *t in touches) {
        [self makeSpinnyAtPoint:[t locationInNode:self] color:[SKColor blueColor]];
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {
        [self makeSpinnyAtPoint:[t locationInNode:self] color:[SKColor redColor]];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {
        [self makeSpinnyAtPoint:[t locationInNode:self] color:[SKColor redColor]];
    }
}
#endif

#if TARGET_OS_OSX
// Mouse-based event handling

- (void)mouseDown:(NSEvent *)event {
    [self makeSpinnyAtPoint:[event locationInNode:self] color:[SKColor greenColor]];
}

- (void)mouseDragged:(NSEvent *)event {
    [self makeSpinnyAtPoint:[event locationInNode:self] color:[SKColor blueColor]];
}

- (void)mouseUp:(NSEvent *)event {
    [self makeSpinnyAtPoint:[event locationInNode:self] color:[SKColor redColor]];
}

#endif

- (void)driverInstallationStateChange
{
	Log("%{public}s", __func__);
	if (NSApp.appDelegate.driverInstallationController.installed) {
		[self showDriverInstalledLabel];
		[self removeDiverNotInstalledLabel];
	} else {
		[self removeDiverInstalledLabel];
		[self showDriverNotInstalledLabel];
	}
}

- (void)driverIPCStateChange
{
	Log("%{public}s", __func__);
}

- (IBAction)openSettings:(id)sender
{
	Log("%{public}s", __func__);
	[NSApp.appDelegate performSelector:_cmd withObject:sender];
}

@end
