//
//	SLYController_9ES.m
//	VirtualController_macOS
//
//	Created by Eddie Hillenbrand on 4/25/25.
//	Copyright © 2025 Silly Utility. All rights reserved.
//

#import <os/log.h>

#import "SLYController_9ES.h"
#import "SLYController.h"

#import "SLYButton.h"
#import "Devices.h"

#if TARGET_OS_OSX
#import "DriverIPCController.h"
#import "DriverIPCMessages.h"
#import "NSApplication+Additions.h"
#import "AppDelegate.h"
#endif

#define Log(fmt, ...) os_log(OS_LOG_DEFAULT, "[VirtualController(SLYController_9ES)] " fmt "\n", ##__VA_ARGS__)

@interface SLYController_9ES ()
- (void)buttonDown:(SLYButton *)sender;
- (void)buttonUp:(SLYButton *)sender;
@end

@implementation SLYController_9ES

- (void)configure
{
	_DPadUp = [self buttonWithName:@".//DPad_Up" forceConfigure:YES];
	_DPadUp.target = self;
	_DPadUp.downAction = @selector(buttonDown:);
	_DPadUp.upAction = @selector(buttonUp:);

	_DPadDown = [self buttonWithName:@".//DPad_Down" forceConfigure:YES];
	_DPadDown.target = self;
	_DPadDown.downAction = @selector(buttonDown:);
	_DPadDown.upAction = @selector(buttonUp:);

	_DPadLeft = [self buttonWithName:@".//DPad_Left" forceConfigure:YES];
	_DPadLeft.target = self;
	_DPadLeft.downAction = @selector(buttonDown:);
	_DPadLeft.upAction = @selector(buttonUp:);

	_DPadRight = [self buttonWithName:@".//DPad_Right" forceConfigure:YES];
	_DPadRight.target = self;
	_DPadRight.downAction = @selector(buttonDown:);
	_DPadRight.upAction = @selector(buttonUp:);

	_Select = [self buttonWithName:@".//Select" forceConfigure:YES];
	_Select.target = self;
	_Select.downAction = @selector(buttonDown:);
	_Select.upAction = @selector(buttonUp:);

	_Start = [self buttonWithName:@".//Start" forceConfigure:YES];
	_Start.target = self;
	_Start.downAction = @selector(buttonDown:);
	_Start.upAction = @selector(buttonUp:);

	_ButtonA = [self buttonWithName:@".//Button_A" forceConfigure:YES];
	_ButtonA.target = self;
	_ButtonA.downAction = @selector(buttonDown:);
	_ButtonA.upAction = @selector(buttonUp:);

	_ButtonB = [self buttonWithName:@".//Button_B" forceConfigure:YES];
	_ButtonB.target = self;
	_ButtonB.downAction = @selector(buttonDown:);
	_ButtonB.upAction = @selector(buttonUp:);
}

- (void)buttonDown:(SLYButton *)sender
{
	Log("%{public}s sender=%{public}@", __func__, sender);
	NineES_HIDInputReport1 inputReport = {};
	inputReport.ReportID = 1;
	inputReport.DPad_Up = (sender == _DPadUp);
	inputReport.DPad_Down = (sender == _DPadDown);
	inputReport.DPad_Left = (sender == _DPadLeft);
	inputReport.DPad_Right = (sender == _DPadRight);
	inputReport.Select = (sender == _Select);
	inputReport.Start = (sender == _Start);
	inputReport.Button_A = (sender == _ButtonA);
	inputReport.Button_B = (sender == _ButtonB);

#if TARGET_OS_OSX
	[NSApp.appDelegate.driverIPC sendInputReport:&inputReport
		size:sizeof(NineES_HIDInputReport1)];
#endif
}

- (void)buttonUp:(SLYButton *)sender
{
	Log("%{public}s sender=%{public}@", __func__, sender);
	NineES_HIDInputReport1 inputReport = {};
	inputReport.ReportID = 1;
	inputReport.Buttons = 0;

#if TARGET_OS_OSX
	[NSApp.appDelegate.driverIPC sendInputReport:&inputReport
		size:sizeof(NineES_HIDInputReport1)];
#endif
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
