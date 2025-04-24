//
//  AppDelegate.m
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/14/25.
//

#import <os/log.h>

#import "AppDelegate.h"
#import "SLYSettingsWindowController.h"

#import "VirtualController-Swift.h"
#import "DriverIPCController.h"

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
	os_log(OS_LOG_DEFAULT, "swiftPreviews=%@", swiftPreviews);
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

@end
