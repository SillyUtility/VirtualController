//
//  SLYButton.m
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/24/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#import "SLYButton.h"

@implementation SLYButton

// Needed to respond to touches & and events
- (BOOL)isUserInteractionEnabled
{
	return YES;
}

#if TARGET_OS_IOS || TARGET_OS_TV
// Touch-based event handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[_label runAction:[SKAction actionNamed:@"Pulse"] withKey:@"fadeInOut"];

	for (UITouch *t in touches) {
		[self makeSpinnyAtPoint:[t locationInNode:self] color:[SKColor greenColor]];
	}
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	for (UITouch *t in touches) {
		[self makeSpinnyAtPoint:[t locationInNode:self] color:[SKColor blueColor]];
	}
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch *t in touches) {
		[self makeSpinnyAtPoint:[t locationInNode:self] color:[SKColor redColor]];
	}
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch *t in touches) {
		[self makeSpinnyAtPoint:[t locationInNode:self] color:[SKColor redColor]];
	}
}
#endif

#if TARGET_OS_OSX
// Mouse-based event handling

- (void)mouseDown:(NSEvent *)event {
	//[self makeSpinnyAtPoint:[event locationInNode:self] color:[SKColor greenColor]];
}

- (void)mouseDragged:(NSEvent *)event {
	//[self makeSpinnyAtPoint:[event locationInNode:self] color:[SKColor blueColor]];
}

- (void)mouseUp:(NSEvent *)event {
	//[self makeSpinnyAtPoint:[event locationInNode:self] color:[SKColor redColor]];
}

#endif

@end
