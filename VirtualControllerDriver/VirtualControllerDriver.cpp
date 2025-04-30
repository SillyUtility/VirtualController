//
//	VirtualControllerDriver.cpp
//	VirtualControllerDriver
//
//	Created by Eddie Hillenbrand on 4/14/25.
//	Copyright © 2025 Silly Utility. All rights reserved.
//

#include <os/log.h>

#include <DriverKit/IOUserServer.h>
#include <DriverKit/IOLib.h>

#include "VirtualControllerDriver.h"
#include "VirtualControllerDevice.h"
#include "VirtualControllerDriverUserClient.h"

#include "Defines.h"

#define Log(fmt, ...) os_log(OS_LOG_DEFAULT, "[VirtualControllerDriver] " fmt "\n", ##__VA_ARGS__)

struct VirtualControllerDriver_IVars {
	VirtualControllerDriverUserClient *userClient = nullptr;
	VirtualControllerDevice *device = nullptr;
};

bool
VirtualControllerDriver::init()
{
	Log("%{public}s", __func__);

	if (!super::init()) {
		Log("Super %{public}s failed", __func__);
		return false;
	}

	ivars = IONewZero(VirtualControllerDriver_IVars, 1);
	if (!ivars) {
		Log("Failed to allocate ivars");
		return false;
	}

	return true;
}

void
VirtualControllerDriver::free()
{
	Log("%{public}s", __func__);

	OSSafeReleaseNULL(ivars->userClient);
	OSSafeReleaseNULL(ivars->device);
	IOSafeDeleteNULL(ivars, VirtualControllerDriver_IVars, 1);

	super::free();
}

kern_return_t
VirtualControllerDriver::Start_Impl(IOService *provider)
{
	kern_return_t ret = kIOReturnSuccess;

	Log("%{public}s", __func__);

	ret = Start(provider, SUPERDISPATCH);
	if (ret != kIOReturnSuccess) {
		Log("Start failed with error: 0x%08x.", ret);
		goto Exit;
	}

	ret = AttachNewVirtualDevice();
	if (ret != kIOReturnSuccess) {
		Log("Unable to attach device; error: 0x%08x.", ret);
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
VirtualControllerDriver::Stop_Impl(IOService *provider)
{
	kern_return_t ret = kIOReturnSuccess;

	Log("%{public}s", __func__);

	ret = Stop(provider, SUPERDISPATCH);
	if (ret != kIOReturnSuccess)
		Log("Stop failed with error: 0x%08x", ret);

	return ret;
}

kern_return_t
VirtualControllerDriver::NewUserClient_Impl(uint32_t type, IOUserClient **userClient)
{
	kern_return_t ret = kIOReturnSuccess;
	IOService *client = nullptr;

	Log("%{public}s", __func__);

	ret = Create(this, "UserClientProperties", &client);
	if (ret != kIOReturnSuccess) {
		Log("Failed to create user client from UserClientProperties with error: 0x%08x", ret);
		goto Exit;
	}

	*userClient = OSDynamicCast(VirtualControllerDriverUserClient, client);
	if (*userClient == NULL) {
		Log("Failed to cast new client");
		OSSafeReleaseNULL(client);
		ret = kIOReturnError;
		goto Exit;
	}

Exit:
	return ret;
}

kern_return_t
VirtualControllerDriver::AttachNewVirtualDevice()
{
	kern_return_t ret = kIOReturnSuccess;
	IOService *device = nullptr;

	Log("%{public}s", __func__);

	ret = Create(this, "VirtualDeviceProperties", &device);
	if (ret != kIOReturnSuccess) {
		Log("Failed to create new virtual device with error: 0x%08x", ret);
		goto Exit;
	}

	ivars->device = OSDynamicCast(VirtualControllerDevice, device);
	if (!ivars->device) {
		Log("Unexpected device type");
		OSSafeReleaseNULL(device);
		ret = kIOReturnError;
		goto Exit;
	}

Exit:
	return ret;
}

VirtualControllerDevice *
VirtualControllerDriver::GetDevice()
{
	return ivars->device;
}
