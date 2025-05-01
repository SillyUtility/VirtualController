//
//  main.m
//  ControllerApp
//
//  Created by Eddie Hillenbrand on 4/14/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControllerAppDelegate.h"

int main(int argc, char * argv[]) {
	NSString * appDelegateClassName;
	@autoreleasepool {
	    // Setup code that might create autoreleased objects goes here.
	    appDelegateClassName = NSStringFromClass([ControllerAppDelegate class]);
	}
	return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
