//
//  GameScene.m
//  ControllerApp
//
//  Created by Eddie Hillenbrand on 4/14/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#import <os/log.h>

#import "GameScene.h"

#import "SLYButton.h"
#import "SLYController.h"
#import "SLYController_9ES.h"

#define Log(fmt, ...) os_log(OS_LOG_DEFAULT, "[VirtualController(ControllerApp.GameScene)] " fmt "\n", ##__VA_ARGS__)

@implementation GameScene {
	SLYController_9ES *_nesController;
}

- (void)add9ES_Controller
{
	_nesController = [self controller_9ES];
	Log("%{public}s _nesController=%{public}@", __func__, _nesController);
	Log("%{public}s _nesController.scene=%{public}@", __func__, _nesController.scene);
	Log("%{public}s _nesController.parent=%{public}@", __func__, _nesController.parent);
}

- (void)didMoveToView:(SKView *)view
{
	if (!_nesController)
		[self performSelectorOnMainThread:@selector(add9ES_Controller) withObject:nil waitUntilDone:NO];
}


- (void)touchDownAtPoint:(CGPoint)pos
{
}

- (void)touchMovedToPoint:(CGPoint)pos
{
}

- (void)touchUpAtPoint:(CGPoint)pos
{
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches)
		[self touchDownAtPoint:[t locationInNode:self]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches)
		[self touchMovedToPoint:[t locationInNode:self]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches)
		[self touchUpAtPoint:[t locationInNode:self]];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches)
		[self touchUpAtPoint:[t locationInNode:self]];
}

-(void)update:(CFTimeInterval)currentTime
{
    // Called before each frame is rendered
}

@end
