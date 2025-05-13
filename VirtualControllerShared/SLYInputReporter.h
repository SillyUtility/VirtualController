//
//  SLYInputReporter.h
//  VirtualController
//
//  Created by Eddie Hillenbrand on 5/6/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SLYInputReporter <NSObject>
- (void)sendInputReport:(void *)report size:(size_t)reportSize;
@end

NS_ASSUME_NONNULL_END
