//
//  DriverIPC.h
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/21/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#ifndef SLYVirtualControllerIPC_h
#define SLYVirtualControllerIPC_h

#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>

static const UInt32 SLYDriverProtocolVersion_v1 = 1;
static const UInt32 SLYDriverProtocolCurrentVersion = SLYDriverProtocolVersion_v1;

typedef enum {
	SLYDriverErrorMessageID,
} SLYDriverMessageID;

typedef void (*SLYDriverCB)(void);

typedef struct {
    IONotificationPortRef port;
    mach_port_t mport;
    CFRunLoopRef runLoop;
    CFRunLoopSourceRef source;
    io_iterator_t addIter;
    io_iterator_t remIter;
	SLYDriverCB connectCB;
	SLYDriverCB disconnectCB;
} SLYDriverConnection;

bool
SLYDriverConnect(SLYDriverConnection **con,
    SLYDriverCB connectCB, SLYDriverCB disconnectCB);

void
SLYDriverDisconnect(SLYDriverConnection *con);

#endif /* SLYVirtualControllerIPC_h */
