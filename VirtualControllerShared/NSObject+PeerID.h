//
//  NSObject+PeerID.h
//  VirtualController
//
//  Created by Eddie Hillenbrand on 5/5/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const kDisplayNameKey;
FOUNDATION_EXPORT NSString * const kPeerIDKey;

FOUNDATION_EXPORT NSString * const kIdentityKey;
FOUNDATION_EXPORT NSString * const kServiceIdentity;
FOUNDATION_EXPORT NSString * const kServiceType;

@class MCPeerID;

@interface NSObject (PeerID)
- (MCPeerID *)peerID;
@end

NS_ASSUME_NONNULL_END
