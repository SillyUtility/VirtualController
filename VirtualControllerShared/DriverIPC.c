//
//  DriverIPC.h
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/21/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//


#include <os/log.h>

#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/IOTypes.h>

#include "DriverIPC.h"

#define Log(fmt, ...) os_log(OS_LOG_DEFAULT, "[VirtualController(IPC)] " fmt "\n", ##__VA_ARGS__)

static const char *DextIdentifier = "VirtualControllerDriver";

void
DeviceAdded(void *refcon, io_iterator_t iterator);

void
DeviceRemoved(void *refcon, io_iterator_t iterator);

bool
SLYDriverConnect(SLYDriverConnection **con,
    SLYDriverCB connectCB, SLYDriverCB disconnectCB)
{
	SLYDriverConnection *newCon = NULL;

    Log("%{public}s", __func__);

    if (!con) {
        Log("Must have valid address");
        goto ExitFailure;
    }
    *con = NULL;

    newCon = calloc(1, sizeof(SLYDriverConnection));
    if (!newCon) {
        Log("Failed to allocate connection");
        goto ExitFailure;
    }

    newCon->connectCB = connectCB;
    newCon->disconnectCB = disconnectCB;

    newCon->runLoop = CFRunLoopGetCurrent();
    if (!newCon->runLoop) {
        Log("Failed to allocate connection");
        goto ExitFailure;
    }

    newCon->port = IONotificationPortCreate(kIOMainPortDefault);
    if (!newCon->port) {
        Log("Failed to create port");
        goto ExitFailure;
    }

    newCon->mport = IONotificationPortGetMachPort(newCon->port);
    if (!newCon->mport) {
        Log("Failed to get mach port");
        goto ExitFailure;
    }

    newCon->source = IONotificationPortGetRunLoopSource(newCon->port);
    if (!newCon->source) {
        Log("Failed to get run loop source ");
        goto ExitFailure;
    }

    CFRunLoopAddSource(newCon->runLoop, newCon->source, kCFRunLoopDefaultMode);

    {
        kern_return_t ret = kIOReturnSuccess;
        CFMutableDictionaryRef matchingDictionary = IOServiceNameMatching(DextIdentifier);
        if (!matchingDictionary) {
            Log("Failed to initialize matchingDictionary");
            goto ExitFailure;
        }

        CFRetain(matchingDictionary);
        ret = IOServiceAddMatchingNotification(newCon->port, kIOFirstMatchNotification,
            matchingDictionary, DeviceAdded, newCon, &newCon->addIter);
        if (ret != kIOReturnSuccess) {
            Log("Add matching notification failed with error: 0x%08x", ret);
            CFRelease(matchingDictionary);
            goto ExitFailure;
        }
        DeviceAdded(newCon, newCon->addIter);

        CFRetain(matchingDictionary);
        ret = IOServiceAddMatchingNotification(newCon->port, kIOTerminatedNotification,
            matchingDictionary, DeviceRemoved, newCon, &newCon->remIter);
        if (ret != kIOReturnSuccess) {
            Log("Add termination notification failed with error: 0x%08x", ret);
            CFRelease(matchingDictionary);
            goto ExitFailure;
        }
        DeviceRemoved(newCon, newCon->remIter);

		CFRelease(matchingDictionary);
    }

    *con = newCon;
    return true;

ExitFailure:
    SLYDriverDisconnect(newCon);
    return false;
}

void
SLYDriverDisconnect(SLYDriverConnection *con)
{
	Log("%{public}s", __func__);

    if (!con)
        return;

    if (con->source)
        CFRunLoopRemoveSource(con->runLoop, con->source, kCFRunLoopDefaultMode);

    if (con->port)
        IONotificationPortDestroy(con->port);

    if (con->runLoop)
        CFRelease(con->runLoop);

    con->addIter = IO_OBJECT_NULL;
    con->remIter = IO_OBJECT_NULL;
}

void
DeviceAdded(void *refcon, io_iterator_t iterator)
{
    kern_return_t ret = kIOReturnSuccess;
    io_connect_t connection = IO_OBJECT_NULL;
    io_service_t device = IO_OBJECT_NULL;

	Log("%{public}s", __func__);

    while ((device = IOIteratorNext(iterator)) != IO_OBJECT_NULL) {
        ret = IOServiceOpen(device, mach_task_self_, 0, &connection);
        if (ret == kIOReturnSuccess) {
            Log("Opened connection to dext");
            if (((SLYDriverConnection *)refcon)->connectCB)
                ((SLYDriverConnection *)refcon)->connectCB();
        } else {
            Log("Failed opening connection to dext with error: 0x%08x", ret);
            IOObjectRelease(device);
            return;
        }

        IOObjectRelease(device);
    }
}

void
DeviceRemoved(void *refcon, io_iterator_t iterator)
{
    io_service_t device = IO_OBJECT_NULL;

	Log("%{public}s", __func__);

    while ((device = IOIteratorNext(iterator)) != IO_OBJECT_NULL) {
        Log("Closed connection to dext");
        IOObjectRelease(device);
        if (((SLYDriverConnection *)refcon)->disconnectCB)
            ((SLYDriverConnection *)refcon)->disconnectCB();
    }
}
