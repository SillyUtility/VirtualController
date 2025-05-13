//
//  NSObject+PeerID.m
//  VirtualController
//
//  Created by Eddie Hillenbrand on 5/5/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#import "NSObject+PeerID.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

NSString * const kDisplayNameKey = @"DisplayName";
NSString * const kPeerIDKey = @"PeerID";

NSString * const kIdentityKey = @"identity";
NSString * const kServiceIdentity = @"com.sillyutility.virtualcontroller";
NSString * const kServiceType = @"su-virtgc01"; // max 15 characters

@implementation NSObject (PeerID)

- (MCPeerID *)peerID
{
	NSString *displayName = nil;
#if TARGET_OS_OSX
	// On macOS the login name (or hostname) is probably a good enough display name
	//displayName = NSProcessInfo.processInfo.userName;
	displayName = NSProcessInfo.processInfo.hostName;
#else
	// On iOS the device name is probably a good enough display name
	displayName = UIDevice.currentDevice.name;
#endif

	NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
	NSString *oldDisplayName = [defaults stringForKey:kDisplayNameKey];
	MCPeerID *pID = nil;
	NSError *err = nil;

	if ([oldDisplayName isEqualToString:displayName]) {
		NSData *peerIDData = [defaults dataForKey:kPeerIDKey];
		pID = [NSKeyedUnarchiver unarchivedObjectOfClass:MCPeerID.class fromData:peerIDData error:&err];
		// TODO: handle error
	} else {
		pID = [[MCPeerID alloc] initWithDisplayName:displayName];
		NSData *peerIDData = [NSKeyedArchiver archivedDataWithRootObject:pID requiringSecureCoding:YES error:&err];
		// TODO: handle error
		[defaults setObject:peerIDData forKey:kPeerIDKey];
		[defaults setObject:displayName forKey:kDisplayNameKey];
		[defaults synchronize];
	}

	return pID;
}

@end
