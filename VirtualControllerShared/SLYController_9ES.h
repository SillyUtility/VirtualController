//
//  SLYController_9ES.h
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/25/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SLYController.h"

NS_ASSUME_NONNULL_BEGIN

@class SLYButton;

@interface SLYController_9ES : SLYController
@property (readonly) SLYButton *DPadUp;
@property (readonly) SLYButton *DPadDown;
@property (readonly) SLYButton *DPadLeft;
@property (readonly) SLYButton *DPadRight;
@property (readonly) SLYButton *Select;
@property (readonly) SLYButton *Start;
@property (readonly) SLYButton *ButtonA;
@property (readonly) SLYButton *ButtonB;
@end

@interface SKNode (SLYController_9ES)
- (SLYController_9ES *)controller_9ES;
@end

NS_ASSUME_NONNULL_END
