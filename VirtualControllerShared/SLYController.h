//
//  SLYController.h
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/25/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLYController : SKSpriteNode
- (void)configure;
@end

@interface SKNode (SLYController)
- (SLYController *)controllerWithName:(NSString *)name;
- (SLYController *)controllerWithName:(NSString *)name fromScene:(NSString *)scene;
@end

NS_ASSUME_NONNULL_END
