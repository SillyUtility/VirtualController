//
//	SLYController_9ES.m
//	VirtualController_macOS
//
//	Created by Eddie Hillenbrand on 4/25/25.
//	Copyright © 2025 Silly Utility. All rights reserved.
//

#import <os/log.h>
#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif

#import "SLYController_9ES.h"
#import "SLYController.h"

#import "SLYButton.h"
#import "Devices.h"

#if TARGET_OS_OSX
#import "DriverIPCController.h"
#import "DriverIPCMessages.h"
#import "NSApplication+Additions.h"
#import "AppDelegate.h"
#else
#import "SLYInputReporter.h"
#endif

#define Log(fmt, ...) os_log(OS_LOG_DEFAULT, "[VirtualController(SLYController_9ES)] " fmt "\n", ##__VA_ARGS__)

@interface SLYController_9ES ()
- (void)buttonDown:(SLYButton *)sender;
- (void)buttonUp:(SLYButton *)sender;
@end

@implementation SLYController_9ES {
	NineES_HIDInputReport1 inputReport;
}

+ (NSString *)deviceName
{
#if TARGET_OS_IOS
	// UIDevice *device = UIDevice.currentDevice;
	// UIUserInterfaceIdiom idom = device.userInterfaceIdiom;
	return @"9ES_HomeButton";
#else
	return @"9ES";
#endif
}

- (void)configure
{
	[super configure];

	inputReport.ReportID = 1;
	inputReport.Buttons = 0;

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

	if (sender == _DPadUp)
		inputReport.DPad_Up = 1;
	if (sender == _DPadDown)
		inputReport.DPad_Down = 1;
	if (sender == _DPadLeft)
		inputReport.DPad_Left = 1;
	if (sender == _DPadRight)
		inputReport.DPad_Right = 1;
	if (sender == _Select)
		inputReport.Select = 1;
	if (sender == _Start)
		inputReport.Start = 1;
	if (sender == _ButtonA)
		inputReport.Button_A = 1;
	if (sender == _ButtonB)
		inputReport.Button_B = 1;

#if TARGET_OS_OSX
	[NSApp.appDelegate.driverIPC sendInputReport:&inputReport
		size:sizeof(NineES_HIDInputReport1)];
#else
	[self.inputReporter sendInputReport:&inputReport
		size:sizeof(NineES_HIDInputReport1)];
#endif
}

- (void)buttonUp:(SLYButton *)sender
{
	Log("%{public}s sender=%{public}@", __func__, sender);

	if (sender == _DPadUp)
		inputReport.DPad_Up = 0;
	if (sender == _DPadDown)
		inputReport.DPad_Down = 0;
	if (sender == _DPadLeft)
		inputReport.DPad_Left = 0;
	if (sender == _DPadRight)
		inputReport.DPad_Right = 0;
	if (sender == _Select)
		inputReport.Select = 0;
	if (sender == _Start)
		inputReport.Start = 0;
	if (sender == _ButtonA)
		inputReport.Button_A = 0;
	if (sender == _ButtonB)
		inputReport.Button_B = 0;

#if TARGET_OS_OSX
	[NSApp.appDelegate.driverIPC sendInputReport:&inputReport
		size:sizeof(NineES_HIDInputReport1)];
#else
	[self.inputReporter sendInputReport:&inputReport
		size:sizeof(NineES_HIDInputReport1)];
#endif
}

@end

@implementation SKNode (SLYController_9ES)

- (SLYController_9ES *)controller_9ES
{
	NSString *name = SLYController_9ES.deviceName;
	Log("DEVICE_NAME=%{public}@", name);
	SLYController_9ES *controller =
		(SLYController_9ES *)[self controllerWithName:name];
	[controller configure];
	return controller;
}

@end
