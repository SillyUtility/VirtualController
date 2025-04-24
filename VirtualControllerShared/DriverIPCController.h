//
//  DriverIPCController.h
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/21/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DriverIPCController : NSObject

@property (readonly) BOOL connected;

- (void)connect;
- (void)disconnect;

@end

NS_ASSUME_NONNULL_END
