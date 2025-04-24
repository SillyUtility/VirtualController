//
//  AppDelegate.h
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/14/25.
//

#import <Cocoa/Cocoa.h>

#import "DriverIPCController.h"

@class DriverInstallationController;
@class DriverIPCController;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property DriverInstallationController *driverInstallationController;
@property DriverIPCController *driverIPC;

- (IBAction)showMainWindow:(id)sender;
- (IBAction)openSettings:(id)sender;

@end

