//
//	VirtualControllerDevice.cpp
//	VirtualControllerDriver
//
//	Created by Eddie Hillenbrand on 4/20/25.
//	Copyright © 2025 Silly Utility. All rights reserved.
//

#include <os/log.h>

#include <DriverKit/IOUserServer.h>
#include <DriverKit/IOLib.h>

#include <DriverKit/OSDictionary.h>
#include <DriverKit/OSString.h>
#include <DriverKit/OSData.h>
#include <DriverKit/OSNumber.h>
#include <DriverKit/OSBoolean.h>

#include <HIDDriverKit/IOHIDDeviceKeys.h>

#include "VirtualControllerDriver.h"
#include "VirtualControllerDriverUserClient.h"
#include "VirtualControllerDevice.h"

#include "Defines.h"
#include "Devices.h"

#define kRegisterServiceKey "RegisterService"
#define kHIDDefaultBehaviorKey "HIDDefaultBehavior"

#define Log(fmt, ...) os_log(OS_LOG_DEFAULT, "[VirtualControllerDevice] " fmt "\n", ##__VA_ARGS__)

struct VirtualControllerDevice_IVars {
	VirtualControllerDriver *driver = nullptr;
};

bool
VirtualControllerDevice::init()
{
	Log("%{public}s", __func__);

	if (!super::init()) {
		Log("Super %{public}s failed", __func__);
		return false;
	}

	ivars = IONewZero(VirtualControllerDevice_IVars, 1);
	if (!ivars) {
		Log("Failed to allocate ivars");
		return false;
	}

	return true;
}

void
VirtualControllerDevice::free()
{
	Log("%{public}s", __func__);

	OSSafeReleaseNULL(ivars->driver);
	IOSafeDeleteNULL(ivars, VirtualControllerDevice_IVars, 1);

	super::free();
}

kern_return_t
VirtualControllerDevice::Stop_Impl(IOService *provider)
{
	kern_return_t ret = kIOReturnSuccess;

	Log("%{public}s", __func__);

	ret = Stop(provider, SUPERDISPATCH);
	if (ret != kIOReturnSuccess)
		Log("Stop failed with error: 0x%08x", ret);

	return ret;
}

bool
VirtualControllerDevice::handleStart(IOService *provider)
{
	bool ret = true;

	Log("%{public}s", __func__);

	if (!super::handleStart(provider)) {
		Log("Super %{public}s failed", __func__);
		ret = false;
		goto Exit;
	}

	ivars->driver = OSDynamicCast(VirtualControllerDriver, provider);
	if (!ivars->driver) {
		Log("Provider is the wrong type");
		ret = false;
		goto Exit;
	}

Exit:
	return ret;
}

OSDictionary *
VirtualControllerDevice::newDeviceDescription(void)
{
	OSDictionary *description = nullptr;
	OSString *manufacturer = nullptr;
	OSString *product = nullptr;
	OSString *serial = nullptr;
	OSNumber *vendorID, *productID, *versionNumber,
	*countryCode, *locationID, *usagePage, *usage;

	vendorID = productID = versionNumber = countryCode =
		locationID = usagePage = usage = nullptr;

	Log("%{public}s", __func__);

	/* See: HIDDriverKit/IOHIDDeviceKeys.h */
	description = OSDictionary::withCapacity(12);
	if (!description) {
		Log("Failed to allocate dictionary");
		description = nullptr;
		goto Exit;
	}

	manufacturer = OSString::withCStringNoCopy(GPONE_Manufacturer);
	if (!manufacturer) {
		Log("Failed to allocate manufacturer string");
		goto Exit;
	}

	product = OSString::withCStringNoCopy(GPONE_Product);
	if (!product) {
		Log("Failed to allocate product string");
		goto Exit;
	}

	serial = OSString::withCStringNoCopy(GPONE_SerialNumber);
	if (!serial) {
		Log("Failed to allocate serial string");
		goto Exit;
	}

	vendorID = OSNumber::withNumber(GPONE_VendorID, 32);
	if (vendorID == nullptr)
		goto Exit;

	productID = OSNumber::withNumber(GPONE_ProductID, 32);
	if (vendorID == nullptr)
		goto Exit;

	versionNumber = OSNumber::withNumber(GPONE_VersionNumber, 32);
	if (productID == nullptr)
		goto Exit;

	countryCode = OSNumber::withNumber((uint64_t)GPONE_CountryCode, 32);
	if (countryCode == nullptr)
		goto Exit;

	locationID = OSNumber::withNumber((uint64_t)GPONE_LocationID, 32);
	if (locationID == nullptr)
		goto Exit;

	usagePage = OSNumber::withNumber(GPONE_PrimaryUsagePage, 32);
	if (usagePage == nullptr)
		goto Exit;

	usage = OSNumber::withNumber(GPONE_PrimaryUsage, 32);
	if (usage == nullptr)
		goto Exit;

	description->setObject(kIOHIDManufacturerKey, manufacturer);
	description->setObject(kIOHIDProductKey, product);
	description->setObject(kIOHIDSerialNumberKey, serial);
	description->setObject(kIOHIDVendorIDKey, vendorID);
	description->setObject(kIOHIDProductIDKey, productID);
	description->setObject(kIOHIDVersionNumberKey, versionNumber);
	description->setObject(kIOHIDCountryCodeKey, countryCode);
	description->setObject(kIOHIDLocationIDKey, locationID);
	description->setObject(kIOHIDPrimaryUsagePageKey, usagePage);
	description->setObject(kIOHIDPrimaryUsageKey, usage);
	description->setObject(kRegisterServiceKey, kOSBooleanTrue);
	description->setObject(kHIDDefaultBehaviorKey, kOSBooleanTrue);

Exit:
	OSSafeReleaseNULL(manufacturer);
	OSSafeReleaseNULL(product);
	OSSafeReleaseNULL(serial);
	OSSafeReleaseNULL(vendorID);
	OSSafeReleaseNULL(productID);
	OSSafeReleaseNULL(versionNumber);
	OSSafeReleaseNULL(countryCode);
	OSSafeReleaseNULL(locationID);
	OSSafeReleaseNULL(usagePage);
	OSSafeReleaseNULL(usage);
	return description;
}

OSData *
VirtualControllerDevice::newReportDescriptor(void)
{
	OSData *descriptor = nullptr;

	Log("%{public}s", __func__);

	descriptor = OSData::withBytesNoCopy((void *)hidReportDescriptor,
		ARRAY_SIZE(hidReportDescriptor));
	if (!descriptor) {
		Log("Failed to allocate data");
		descriptor = nullptr;
		goto Exit;
	}

Exit:
	return descriptor;
}
