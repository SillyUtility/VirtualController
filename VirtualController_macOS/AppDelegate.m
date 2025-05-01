//
//  AppDelegate.m
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/14/25.
//

#import <os/log.h>
#import <GameController/GameController.h>

#import "AppDelegate.h"
#import "SLYSettingsWindowController.h"

#import "VirtualController-Swift.h"
#import "DriverIPCController.h"

#define Log(fmt, ...) os_log(OS_LOG_DEFAULT, "[VirtualController(macOS.AppDelegate)] " fmt "\n", ##__VA_ARGS__)

@interface AppDelegate ()
@property (readonly) NSWindowController *mainWindowController;
@property (readonly) SLYSettingsWindowController *settingsWindowController;
@end

@implementation AppDelegate {
	NSWindowController *_mainWidnowController;
	SLYSettingsWindowController *_settingsWindowController;
}



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	_driverIPC = DriverIPCController.new;
	_driverInstallationController = DriverInstallationController.new;

	// Don't show the main window when previewing a SwiftUI view
	NSString *swiftPreviews = NSProcessInfo.processInfo.environment[@"XCODE_RUNNING_FOR_PREVIEWS"];
	Log("swiftPreviews=%@", swiftPreviews);
	if (!swiftPreviews)
		[self showMainWindow:self];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

- (NSWindowController *)mainWindowController {
	if (!_mainWidnowController) {
		NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
		_mainWidnowController = [storyboard instantiateControllerWithIdentifier:@"MainWindow"];
	}
	return _mainWidnowController;
}

- (SLYSettingsWindowController *)settingsWindowController {
	if (!_settingsWindowController) {
		NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Settings" bundle:nil];
		_settingsWindowController = [storyboard instantiateInitialController];
	}
	return _settingsWindowController;
}

- (IBAction)showMainWindow:(id)sender {
	[self.mainWindowController showWindow:sender];
}

- (IBAction)openSettings:(id)sender {
	[self.settingsWindowController showWindow:sender];
}

- (IBAction)checkForControllers:(id)sender
{
	Log("GCController.controllers=%{public}@", GCController.controllers);
	Log("GCController.current=%{public}@", GCController.current);

	IOHIDManagerRef manager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDManagerOptionNone);
	IOHIDManagerSetDeviceMatching(manager, (__bridge CFDictionaryRef)@{
		@kIOProviderClassKey: @kIOHIDDeviceKey,
		@kIOHIDPrimaryUsagePageKey: @(0x01),
		@kIOHIDPrimaryUsageKey: @(0x05),
	});
	CFSetRef devices = IOHIDManagerCopyDevices(manager);
	if (!devices) {
		Log("No matching devices");
		return;
	}

	Log("Found devices=%{public}@", devices);

	CFIndex count = CFSetGetCount(devices);
	const void **values = calloc(count, sizeof(void *));
	CFSetGetValues(devices, values);
	for (CFIndex i = 0; i < count; i++) {
		IOHIDDeviceRef device = (IOHIDDeviceRef)values[i];
		Log("device=%{public}@", device);
		Log("GameController.supportsHIDDevice? %{BOOL}d", [GCController supportsHIDDevice:device]);

		// CFTypeRef prop = IOHIDDeviceGetProperty(device, (__bridge CFStringRef)@kIOHIDPrimaryUsageKey);
		// if ([(__bridge NSNumber *)prop isEqualToNumber:@(0x05)]) {
		// 	break;
		// }
	}
}

@end
