//
//	VirtualControllerDriverUserClient.cpp
//	VirtualControllerDriver
//
//	Created by Eddie Hillenbrand on 4/16/25.
//	Copyright © 2025 Silly Utility. All rights reserved.
//

#include <os/log.h>

#include <DriverKit/IOLib.h>
#include <DriverKit/IOUserClient.h>
#include <DriverKit/OSData.h>

#include "VirtualControllerDriverUserClient.h"

#define Log(fmt, ...) os_log(OS_LOG_DEFAULT, "[VirtualControllerDriverUserClient] " fmt "\n", ##__VA_ARGS__)

struct VirtualControllerDriverUserClient_IVars {

};

bool
VirtualControllerDriverUserClient::init()
{
	Log("%{public}s", __func__);

	if (!super::init()) {
		Log("Super %{public}s failed", __func__);
		return false;
	}

	ivars = IONewZero(VirtualControllerDriverUserClient_IVars, 1);
	if (!ivars) {
		Log("Faild to allocate ivars");
		return false;
	}

	return true;
}

void
VirtualControllerDriverUserClient::free()
{
	Log("%{public}s", __func__);

	IOSafeDeleteNULL(ivars, VirtualControllerDriverUserClient_IVars, 1);

	super::free();
}

kern_return_t
VirtualControllerDriverUserClient::Start_Impl(IOService *provider)
{
	kern_return_t ret = kIOReturnSuccess;

	Log("%{public}s", __func__);

	ret = Start(provider, SUPERDISPATCH);
	if (ret != kIOReturnSuccess) {
		Log("Start failed with error: 0x%08x.", ret);
		goto Exit;
	}

	ret = RegisterService();
	if (ret != kIOReturnSuccess) {
		Log("RegisterService failed with error: 0x%08x.", ret);
		goto Exit;
	}

Exit:
	return ret;
}

kern_return_t
VirtualControllerDriverUserClient::Stop_Impl(IOService *provider)
{
	kern_return_t ret = kIOReturnSuccess;

	Log("%{public}s", __func__);

	ret = Stop(provider, SUPERDISPATCH);
	if (ret != kIOReturnSuccess)
		Log("Stop failed with error: 0x%08x.", ret);

	return ret;
}
