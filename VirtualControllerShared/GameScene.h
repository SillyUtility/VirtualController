//
//  GameScene.h
//  VirtualControllerShared
//
//  Created by Eddie Hillenbrand on 4/14/25.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene

+ (GameScene *)newGameScene;

- (void)driverInstallationStateChange;
- (void)driverIPCStateChange;

- (void)controllerDisconnected;
- (void)controllerConnecting;
- (void)controllerConnected;

@end
