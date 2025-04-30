# Essential DriverKit Articles

- https://developer.apple.com/documentation/driverkit/creating-a-driver-using-the-driverkit-sdk
- https://developer.apple.com/documentation/driverkit/debugging-and-testing-system-extensions

# System Extensions

Show activated (installed) system extensions

    % systemextensionsctl list

Uninstall

    % systemextensionsctl uninstall - com.sillutility.VirtualController.VirtualControllerDriver

# Activation Debugging

    log stream --style compact --predicate 'process == "sysextd" or eventMessage contains "VirtualControllerDriver"'

# Dext Loading Debugging

Activation (installing) the Dext is only part of the battle. After its
installed the kernel needs to load the driver. When debugging this
process examine the logs of `kernelmanagerd`, `kernel`, and `amfid`.

# Driver Debugging

Use `ioreg` to ensure the IO object graph matches your expectation as
configured in the driver's `Info.plist` and the graph you construct
within the driver's implementation.

Filter out everything but messages from the driver:

	log stream --style compact --predicate 'process == "kernel" and eventMessage contains "[VirtualController"' --info --debug

Stream messages from the macOS app and the driver (but some unrelated subsystems too):

	log stream --style compact --predicate 'eventMessage contains "[VirtualController"' --info --debug

# Where is the `IMPL` macro?

From `DriverKit/OSObject.igg`:

	/*
     * Use of the IMPL macro is discouraged and should be replaced by a normal c++
     * method implementation (with the all method arguments) and the name of the method
     * given a suffix '_Impl'
     */

# Available APIs

Remember that only APIs declared in

    $(xcode-select -p)/Platforms/DriverKit.platform/Developer/SDKs/DriverKit.sdk/System/DriverKit/System/Library/Frameworks

and declared in

    $(xcode-select -p)/Platforms/DriverKit.platform/Developer/SDKs/DriverKit.sdk/System/DriverKit/usr/include

are available.


# OpenEmu Control Binding

	<key>OEGenericDeviceIdentifier_1209_2</key>
	<array>
		<dict>
			<key>OENESButtonUp</key>
			<string>OEGenericControlButton1446</string>
			<key>OENESButtonDown</key>
			<string>OEGenericControlButton1457</string>
			<key>OENESButtonLeft</key>
			<string>OEGenericControlButton1478</string>
			<key>OENESButtonRight</key>
			<string>OEGenericControlButton1469</string>
			<key>OENESButtonA</key>
			<string>OEGenericControlButton112</string>
			<key>OENESButtonB</key>
			<string>OEGenericControlButton213</string>
			<key>OENESButtonStart</key>
			<string>OEGenericControlButton6111</string>
			<key>OENESButtonSelect</key>
			<string>OEGenericControlButton6210</string>
		</dict>
	</array>
