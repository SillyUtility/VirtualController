//
//  GameScene.h
//  ControllerApp
//
//  Created by Eddie Hillenbrand on 4/14/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol SLYInputReporter;

@interface GameScene : SKScene
@property(nonatomic, weak, nullable) id<SLYInputReporter> inputReporter;
@end
