//
//  NSApplication+Additions.m
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/23/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#import "NSApplication+Additions.h"

@implementation NSApplication (Additions)

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)self.delegate;
}

@end
