//
//  DriverIPCController.m
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/21/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#import <os/log.h>

#import "DriverIPCController.h"
#import "DriverIPC.h"

#define Log(fmt, ...) os_log(OS_LOG_DEFAULT, "[VirtualController(IPC_Controller)] " fmt "\n", ##__VA_ARGS__)

NSString * const SLYDiverDidConnect = @"DiverDidConnect";
NSString * const SLYDiverDidDisconnect = @"DiverDidDisconnect";

void ConnectCallback(void)
{
	NSNotificationCenter *notificationCenter = NSNotificationCenter.defaultCenter;
	NSNotification *notification =
		[NSNotification notificationWithName:SLYDiverDidConnect object:nil];
	[notificationCenter postNotification:notification];
}

void DisconnectCallback(void)
{
	NSNotificationCenter *notificationCenter = NSNotificationCenter.defaultCenter;
	NSNotification *notification =
		[NSNotification notificationWithName:SLYDiverDidDisconnect object:nil];
	[notificationCenter postNotification:notification];
}

@interface DriverIPCController ()
@property (readwrite) BOOL connected;
@end

@implementation DriverIPCController {
	SLYDriverConnection *_connection;
}

- init
{
    if (!(self = [super init]))
        return nil;

    NSNotificationCenter *notificationCenter = NSNotificationCenter.defaultCenter;
    [notificationCenter addObserver:self
        selector:@selector(driverDidConnect:)
        name:SLYDiverDidConnect
        object:nil];

    [notificationCenter addObserver:self
        selector:@selector(driverDidDisconnect:)
        name:SLYDiverDidDisconnect
        object:nil];


    return self;
}

- (void)connect
{
	SLYDriverConnect(&_connection, ConnectCallback, DisconnectCallback);
}

- (void)disconnect
{
	SLYDriverDisconnect(_connection);
}


- (void)driverDidConnect:(NSNotification *)notification
{
	Log("%{public}s", __func__);
	self.connected = YES;
}

- (void)driverDidDisconnect:(NSNotification *)notification
{
	Log("%{public}s", __func__);
	self.connected = NO;
}

@end
