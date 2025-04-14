//
//  VirtualControllerDriver.cpp
//  VirtualControllerDriver
//
//  Created by Eddie Hillenbrand on 4/14/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#include <os/log.h>

#include <DriverKit/IOUserServer.h>
#include <DriverKit/IOLib.h>

#include "VirtualControllerDriver.h"

kern_return_t
IMPL(VirtualControllerDriver, Start)
{
    kern_return_t ret;
    ret = Start(provider, SUPERDISPATCH);
    os_log(OS_LOG_DEFAULT, "Hello World");
    return ret;
}
