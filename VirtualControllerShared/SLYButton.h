//
//  SLYButton.h
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/24/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLYButton : SKNode

@property (weak, nullable) id target;
@property (nullable) SEL action;

@end

NS_ASSUME_NONNULL_END
