//
//  AppDelegate.m
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/14/25.
//

#import "AppDelegate.h"
#import "SLYSettingsWindowController.h"

@interface AppDelegate ()
@property (readonly) SLYSettingsWindowController *settingsWindowControler;
@end

@implementation AppDelegate {
	SLYSettingsWindowController *_settingsWindowControler;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

- (SLYSettingsWindowController *)settingsWindowControler {
	if (!_settingsWindowControler) {
		NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Settings" bundle:nil];
		_settingsWindowControler = [storyboard instantiateInitialController];
	}
	return _settingsWindowControler;
}

- (IBAction)openSettings:(id)sender {
	[self.settingsWindowControler showWindow:self];
}

@end
