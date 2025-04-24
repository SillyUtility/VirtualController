//
//  NSApplication+Additions.h
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/23/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class AppDelegate;

@interface NSApplication (Additions)
@property (readonly) AppDelegate *appDelegate;
@end

NS_ASSUME_NONNULL_END
