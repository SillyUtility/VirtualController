//
//  DriverController.swift
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/15/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

import Foundation
import SystemExtensions
import os.log

class DriverState {
	enum State {
		case unknown
		case checking
		case missing
		case activating
		case failedToActivate
		case installed
	}

	enum Event {
		case checkBegan
		case checkDidNotFindDriver
		case checkFoundDriver
		case activationBegan
		case activationFailed
		case activationNeedsReboot
		case activationFinished
	}

	static func transition(_ state: State, _ event: Event) -> State {
		switch state {
		case .unknown:
			switch event {
			case .checkBegan:
				return .checking
			case .checkDidNotFindDriver:
				return .unknown
			case .checkFoundDriver:
				return .unknown
			case .activationBegan:
				return .unknown
			case .activationFailed:
				return .unknown
			case .activationNeedsReboot:
				return .unknown
			case .activationFinished:
				return .unknown
			}
		case .checking:
			return .unknown
		case .missing:
			return .unknown
		case .activating:
			return .unknown
		case .failedToActivate:
			return .unknown
		case .installed:
			return .unknown
		}
	}
}

class DriverController: NSObject {
	@Published private(set) var state: DriverState.State = .unknown

	private var installedDextProperties: OSSystemExtensionProperties? = nil
	private let dextIdentifier: String = Bundle.main.bundleIdentifier! + "Driver"
	private var swiftPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil

	override init() {
		super.init()
		os_log("\(type(of: self)).\(#function) swiftPreviews=\(self.swiftPreviews), dextIdentifier=\(self.dextIdentifier)")
		checkExtension()
	}

	public var stateDescription: String {
		switch state {
		case .unknown:
			return String(localized: "Unknown driver state.",
						  comment: "Have not checked for installed driver")
		case .checking:
			return String(localized: "Checking if driver is installed.",
						  comment: "Performing check for installed driver")
		case .missing:
			return String(localized: "Driver is not installed.",
						  comment: "Driver not found during check")
		case .activating:
			return String(localized: "Installing driver.",
						  comment: "Attempting to install driver")
		case .failedToActivate:
			return String(localized: "Driver failed to install.",
						  comment: "Encountered an error while installing")
		case .installed:
			return String(localized: "Driver is installed.",
						  comment: "Driver successfully installed")
		}
	}
}

extension DriverController: ObservableObject {}

extension DriverController: OSSystemExtensionRequestDelegate {
	func request(_ request: OSSystemExtensionRequest,
				 actionForReplacingExtension existing: OSSystemExtensionProperties,
				 withExtension ext: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction
	{
		os_log("\(type(of: self)).\(#function)")
		return .cancel
	}

	func requestNeedsUserApproval(_ request: OSSystemExtensionRequest)
	{
		os_log("\(type(of: self)).\(#function)")
	}

	func request(_ request: OSSystemExtensionRequest,
				 didFinishWithResult result: OSSystemExtensionRequest.Result)
	{
		os_log("\(type(of: self)).\(#function)")
	}

	func request(_ request: OSSystemExtensionRequest,
				 didFailWithError error: any Error)
	{
		os_log("\(type(of: self)).\(#function)")
	}

	func request(_ request: OSSystemExtensionRequest,
				 foundProperties properties: [OSSystemExtensionProperties])
	{
		os_log("\(type(of: self)).\(#function) request=\(request), properties=\(properties)")
	}
}

extension DriverController {
	func checkExtension() {
		os_log("\(type(of: self)).\(#function)")

		if (swiftPreviews) {
			return
		}

		let request = OSSystemExtensionRequest.propertiesRequest(
			forExtensionWithIdentifier: dextIdentifier,
			queue: .global(qos: .userInteractive)
		)
		request.delegate = self
		OSSystemExtensionManager.shared.submitRequest(request)

		self.state = DriverState.transition(state, .checkBegan)
	}

	func activateExtension() {
		os_log("\(type(of: self)).\(#function)")

		if (swiftPreviews) {
			return
		}
	}

	func deactivateExtension() {
		os_log("\(type(of: self)).\(#function)")

		if (swiftPreviews) {
			return
		}
	}
}
