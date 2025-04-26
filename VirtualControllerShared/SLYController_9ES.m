//
//  SLYController_9ES.m
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/25/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#import <os/log.h>

#import "SLYController_9ES.h"
#import "SLYController.h"

#import "SLYButton.h"

#define Log(fmt, ...) os_log(OS_LOG_DEFAULT, "[VirtualController(SLYController_9ES)] " fmt "\n", ##__VA_ARGS__)

@interface SLYController_9ES ()
@end

@implementation SLYController_9ES

- (void)configure
{
	_DPadUp = [self buttonWithName:@".//DPad_Up" forceConfigure:YES];
	_DPadDown = [self buttonWithName:@".//DPad_Down" forceConfigure:YES];
	_DPadLeft = [self buttonWithName:@".//DPad_Left" forceConfigure:YES];
	_DPadRight = [self buttonWithName:@".//DPad_Right" forceConfigure:YES];
	_Select = [self buttonWithName:@".//Select" forceConfigure:YES];
	_Start = [self buttonWithName:@".//Start" forceConfigure:YES];
	_ButtonA = [self buttonWithName:@".//Button_A" forceConfigure:YES];
	_ButtonB = [self buttonWithName:@".//Button_B" forceConfigure:YES];
}

@end

@implementation SKNode (SLYController_9ES)

- (SLYController_9ES *)controller_9ES
{
	SLYController_9ES *controller = (SLYController_9ES *)[self controllerWithName:@"9ES"];
	[controller configure];
	return controller;
}

@end
