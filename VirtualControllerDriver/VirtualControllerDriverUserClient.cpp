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
#include "VirtualControllerDriver.h"
#include "VirtualControllerDevice.h"
#include "DriverIPCMessages.h"
#include "Devices.h"

#define Log(fmt, ...) os_log(OS_LOG_DEFAULT, "[VirtualControllerDriverUserClient] " fmt "\n", ##__VA_ARGS__)

kern_return_t
DeviceInputReportDispatch(OSObject *target, void *ref, IOUserClientMethodArguments *args)
{
	Log("%{public}s", __func__);

	if (target == nullptr)
		return kIOReturnError;
	return ((VirtualControllerDriverUserClient*)target)->DeviceInputReport(ref, args);
}

kern_return_t
DeviceErrorDispatch(OSObject *target, void *ref, IOUserClientMethodArguments *args)
{
	Log("%{public}s", __func__);

	if (target == nullptr)
		return kIOReturnError;
	return ((VirtualControllerDriverUserClient*)target)->DeviceError(ref, args);
}

const IOUserClientMethodDispatch IPCMethods[SLYDriverMessageCount] = {
	[SLYDriverDeviceInputReportMessageID] = {
		.function = (IOUserClientMethodFunction)DeviceInputReportDispatch,
		.checkCompletionExists = false,
		.checkScalarInputCount = 0,
		.checkStructureInputSize = sizeof(NineES_HIDInputReport1),
		.checkScalarOutputCount = 0,
		.checkStructureOutputSize = 0,
	},
	[SLYDriverErrorMessageID] = {
		.function = (IOUserClientMethodFunction)DeviceErrorDispatch,
		.checkCompletionExists = false,
		.checkScalarInputCount = 0,
		.checkStructureInputSize = sizeof(SLYDriverErrorMessage),
		.checkScalarOutputCount = 0,
		.checkStructureOutputSize = 0,
	},
};

struct VirtualControllerDriverUserClient_IVars {
	VirtualControllerDriver *driver = nullptr;
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

	OSSafeReleaseNULL(ivars->driver);
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
		Log("Start failed with error: 0x%08x", ret);
		goto Exit;
	}

	ivars->driver = OSDynamicCast(VirtualControllerDriver, provider);
	if (!ivars->driver) {
		Log("Provider is the wrong type");
		ret = false;
		goto Exit;
	}

	ret = RegisterService();
	if (ret != kIOReturnSuccess) {
		Log("RegisterService failed with error: 0x%08x", ret);
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
		Log("Stop failed with error: 0x%08x", ret);

	return ret;
}

kern_return_t
VirtualControllerDriverUserClient::ExternalMethod(uint64_t selector,
	IOUserClientMethodArguments *arguments,
	const IOUserClientMethodDispatch *dispatch,
	OSObject *target, void *reference)
{
	kern_return_t ret = kIOReturnSuccess;

	Log("%{public}s", __func__);

	if (selector >= SLYDriverMessageCount) {
		Log("Unrecognized message");
		ret = kIOReturnBadArgument;
		goto Exit;
	}

#if 0
	dispatch = &IPCMethods[selector];
	if (!target)
		target = this;

	ret = super::ExternalMethod(selector, arguments,
		dispatch, target, reference);
	if (ret != kIOReturnSuccess)
		Log("ExternalMethod failed with error: 0x%08x", ret);
#endif

	if (selector == SLYDriverDeviceInputReportMessageID)
		DeviceInputReportDispatch(this, reference, arguments);

Exit:
	return ret;
}

kern_return_t
VirtualControllerDriverUserClient::DeviceInputReport(void *ref,
	IOUserClientMethodArguments *args)
{
	kern_return_t ret = kIOReturnSuccess;
	NineES_HIDInputReport1 *input;

	uint64_t timestamp;
	uint32_t reportLength;
	IOHIDReportType reportType = kIOHIDReportTypeInput;
	//IOOptionBits options = 0;

	IOMemoryDescriptor *report = nullptr;
	IOBufferMemoryDescriptor *memory = nullptr;

	//uint64_t options = 0;
	uint64_t address = 0;
	uint64_t length = 0;
	uint64_t alignment = 0;

	uint64_t returnAddress;
	uint64_t returnLength;

	Log("%{public}s", __func__);

	input = (NineES_HIDInputReport1 *)args->structureInput->getBytesNoCopy();
	reportLength = (uint32_t)args->structureInput->getLength();

	ret = IOBufferMemoryDescriptor::Create(kIOMemoryDirectionOut, reportLength, 0, &memory);
	if (ret != kIOReturnSuccess) {
		Log("Failed to allocate buffer memory descriptor with error: 0x%08x", ret);
		goto Exit;
	}

	ret = memory->Map(0, address, length, alignment, &returnAddress, &returnLength);
	if (ret != kIOReturnSuccess) {
		Log("Failed to map buffer memory descriptor with error: 0x%08x", ret);
		goto Exit;
	}

	if (returnLength != reportLength) {
		Log("reportLength and mapped memory returnLength mismatch");
		ret = kIOReturnNoMemory;
		goto Exit;
	}

	memcpy(reinterpret_cast<void *>(returnAddress), input, reportLength);
	report = memory;

	timestamp = mach_absolute_time();
	ret = ivars->driver->GetDevice()->handleReport(timestamp, report,
		reportLength, reportType, 0);
	if (ret != kIOReturnSuccess) {
		Log("handleReport failed with error: 0x%08x", ret);
		goto Exit;
	}

Exit:
	OSSafeReleaseNULL(memory);
	return ret;
}

kern_return_t
VirtualControllerDriverUserClient::DeviceError(void *ref,
	IOUserClientMethodArguments *args)
{
	kern_return_t ret = kIOReturnSuccess;

	Log("%{public}s", __func__);

Exit:
	return ret;
}
