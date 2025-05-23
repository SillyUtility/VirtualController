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
#import "SLYController.h"
#import "SLYController_9ES.h"

#define Log(fmt, ...) os_log(OS_LOG_DEFAULT, "[VirtualController(GameScene)] " fmt "\n", ##__VA_ARGS__)

@interface GameScene ()
@end

@implementation GameScene {
	SKTextureAtlas *_textureAtlas;
	SKShapeNode *_spinnyNode;
	SKLabelNode *_driverNotInstalledLabel;
	SKLabelNode *_driverIntallHintLabel;
	SKLabelNode *_driverInstalledLabel;
	SLYButton *_settingsButton;
	SKSpriteNode *_driverIPCState;
	SLYController_9ES *_nesController;
	SKSpriteNode *_controllerConnectionState;
}

+ (GameScene *)newGameScene
{
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
	if (_driverNotInstalledLabel)
		_driverNotInstalledLabel.hidden = NO;
	if (_driverIntallHintLabel)
		_driverIntallHintLabel.hidden = NO;
	if (_settingsButton)
		_settingsButton.hidden = NO;
}

- (void)removeDiverNotInstalledLabel
{
	 Log("%{public}s", __func__);
	if (_driverNotInstalledLabel)
		_driverNotInstalledLabel.hidden = YES;
	if (_driverIntallHintLabel)
		_driverIntallHintLabel.hidden = YES;
	if (_settingsButton)
		_settingsButton.hidden = YES;
}

- (void)showDriverInstalledLabel
{
	 Log("%{public}s", __func__);
	if (_driverInstalledLabel) {
		[self repositionDriverInstalledLabel];
		_driverInstalledLabel.hidden = NO;
	}
}

- (void)removeDiverInstalledLabel
{
	Log("%{public}s", __func__);
	if (_driverInstalledLabel)
		_driverInstalledLabel.hidden = YES;
}

- (void)repositionDriverInstalledLabel
{
	CGSize ssize = _driverInstalledLabel.scene.size;
	CGFloat x = -(ssize.width / 2) + 10;
	CGFloat y = (ssize.height / 2) - 10;
	_driverInstalledLabel.position = CGPointMake(x, y);
}

- (void)driverDisconnected
{
	Log("%{public}s", __func__);
	if (!_driverIPCState)
		return;

	_driverIPCState.texture = [_textureAtlas textureNamed:@"DriverDisconnected"];
	[self repositionDriverIPCState];

	if (_nesController)
		_nesController.hidden = YES;
}

- (void)driverConnected
{
	Log("%{public}s", __func__);
	if (!_driverIPCState)
		return;

	_driverIPCState.texture = [_textureAtlas textureNamed:@"DriverConnected"];
	[self repositionDriverIPCState];

	// Accessing any of the controllers child nodes will fail unless the scene has rendered at least once
	if (!_nesController)
		[self performSelectorOnMainThread:@selector(add9ES_Controller) withObject:nil waitUntilDone:NO];

	_nesController.hidden = NO;
}

- (void)repositionDriverIPCState
{
	CGSize ssize = _driverIPCState.scene.size;
	CGFloat x = (ssize.width / 2) - 10;
	CGFloat y = (ssize.height / 2) - 10;
	_driverIPCState.position = CGPointMake(x, y);
}

- (void)repositionControllerConnectionState
{
	CGSize ssize = _controllerConnectionState.scene.size;
	CGFloat x = -(ssize.width / 2) + 10;
	CGFloat y = -(ssize.height / 2) + 10;
	_controllerConnectionState.position = CGPointMake(x, y);
}

- (void)didChangeSize:(CGSize)oldSize
{
	// Log("%{public}s", __func__);
	[self repositionDriverInstalledLabel];
	[self repositionDriverIPCState];
	[self repositionControllerConnectionState];
}

- (void)add9ES_Controller
{
	_nesController = [self controller_9ES];
	Log("%{public}s _nesController=%{public}@", __func__, _nesController);
	Log("%{public}s _nesController.scene=%{public}@", __func__, _nesController.scene);
	Log("%{public}s _nesController.parent=%{public}@", __func__, _nesController.parent);
}

- (void)setUpScene
{
	_textureAtlas = [SKTextureAtlas atlasNamed:@"Sprites"];

	_driverInstalledLabel = (SKLabelNode *)[self childNodeWithName:@"//DriverInstalledLabel"];
	_driverInstalledLabel.fontName = @"Retro-Pixel-Arcade-Regular";
	_driverInstalledLabel.fontSize = 22;
	_driverInstalledLabel.fontColor = NSColor.whiteColor;
	_driverInstalledLabel.text = @"Driver installed";
	[self repositionDriverInstalledLabel];

	_driverNotInstalledLabel = (SKLabelNode *)[self childNodeWithName:@"//DriverNotInstalledLabel"];
	_driverNotInstalledLabel.fontName = @"Retro-Pixel-Arcade-Regular";
	_driverNotInstalledLabel.fontSize = 32;
	_driverNotInstalledLabel.fontColor = NSColor.whiteColor;
	_driverNotInstalledLabel.text = @"Driver not installed";

	_driverIntallHintLabel = (SKLabelNode *)[self childNodeWithName:@"//DriverInstallHintLabel"];
	_driverIntallHintLabel.fontName = @"Retro-Pixel-Arcade-Regular";
	_driverIntallHintLabel.fontSize = 18;
	_driverIntallHintLabel.fontColor = NSColor.whiteColor;
	_driverIntallHintLabel.text = @"Open Settings to install";

	_settingsButton = (SLYButton *)[self childNodeWithName:@"//SettingsButton"];
	_settingsButton.target = self;
	_settingsButton.action = @selector(openSettings:);
	Log("%{public}s _settingsButton=%{public}@", __func__, _settingsButton);

	_driverIPCState = (SKSpriteNode *)[self childNodeWithName:@"//DriverIPCState"];
	Log("%{public}s _driverIPCState=%{public}@", __func__, _driverIPCState);
	[self driverDisconnected];

	_controllerConnectionState = (SKSpriteNode *)[self childNodeWithName:@"//ControllerConnectionState"];
	Log("%{public}s _controllerConnectionState=%{public}@", __func__, _controllerConnectionState);

	if (NSApp.appDelegate.driverInstallationController.installed) {
		[self showDriverInstalledLabel];
		[self removeDiverNotInstalledLabel];
	} else {
		[self removeDiverInstalledLabel];
		[self showDriverNotInstalledLabel];
	}
}

- (void)didMoveToView:(SKView *)view
{
	//Log("%{public}s", __func__);
	[self setUpScene];
}

-(void)update:(CFTimeInterval)currentTime
{
    // Called before each frame is rendered
}

#if TARGET_OS_IOS || TARGET_OS_TV

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches)
		(void)t;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches)
		(void)t;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches)
		(void)t;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches)
		(void)t;
}

#endif

#if TARGET_OS_OSX

- (void)mouseDown:(NSEvent *)event
{

}

- (void)mouseDragged:(NSEvent *)event
{

}

- (void)mouseUp:(NSEvent *)event
{

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
	if (NSApp.appDelegate.driverIPC.connected)
		[self driverConnected];
	else
		[self driverDisconnected];
}

- (IBAction)openSettings:(id)sender
{
	Log("%{public}s", __func__);
	[NSApp.appDelegate performSelector:_cmd withObject:sender];
}

- (void)controllerDisconnected
{
	_controllerConnectionState.texture = [_textureAtlas textureNamed:@"ControllerDisconnected"];
}

- (void)controllerConnecting
{

}

- (void)controllerConnected
{
	_controllerConnectionState.texture = [_textureAtlas textureNamed:@"ControllerConnected"];
}

@end
