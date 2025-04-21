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
		case installed

		case activating
		case failedToActivate
		case watingForActivationApproval

		case deactivating
		case failedToDeactivate
		case watingForDeactivationApproval
		case uninstalled

		case waitingForReboot

		case error
	}

	enum Event {
		// check events
		case checkBegan
		case checkDidNotFindDriver
		case checkFoundDriver

		case activationBegan
		case deactivationBegan

		case actionFailed
		case actionNeedsApproval
		case actionNeedsReboot
		case actionSucceded
	}

	static func transition(_ state: State, _ event: Event) -> State {
		switch state {
		case .unknown:
			switch event {
			case .checkBegan: return .checking
			default: return .error
			}
		case .checking:
			switch event {
			case .checkDidNotFindDriver: return .missing
			case .checkFoundDriver: return .installed
			default: return .error
			}
		case .missing:
			switch event {
			case .activationBegan: return .activating
			default: return .error
			}
		case .activating:
			switch event {
			case .actionFailed: return .failedToActivate
			case .actionNeedsApproval: return .watingForActivationApproval
			case .actionNeedsReboot: return .waitingForReboot
			case .actionSucceded: return .installed
			default: return .error
			}
		case .failedToActivate:
			switch event {
			case .checkBegan: return .checking
			case .activationBegan: return .activating
			case .deactivationBegan: return .deactivating
			default: return .error
			}
		case .installed:
			switch event {
			case .checkBegan: return .checking
			case .activationBegan: return .activating
			case .deactivationBegan: return .deactivating
			default: return .error
			}
		case .deactivating:
			switch event {
			case .actionFailed: return .failedToDeactivate
			case .actionNeedsApproval: return .watingForDeactivationApproval
			case .actionNeedsReboot: return .waitingForReboot
			case .actionSucceded: return .uninstalled
			default: return .error
			}
		case .failedToDeactivate:
			switch event {
			case .checkBegan: return .checking
			case .activationBegan: return .activating
			case .deactivationBegan: return .deactivating
			default: return .error
			}
		case .uninstalled:
			switch event {
			case .checkBegan: return .checking
			case .activationBegan: return .activating
			default: return .error
			}
		case .watingForActivationApproval:
			switch event {
			case .actionFailed: return .failedToActivate
			case .actionSucceded: return .installed
			default: return .error
			}
		case .watingForDeactivationApproval:
			switch event {
			case .actionFailed: return .failedToDeactivate
			case .actionSucceded: return .uninstalled
			default: return .error
			}
		case .waitingForReboot: return .waitingForReboot
		case .error: return .error
		}
	}
}

class DriverController: NSObject {
	@Published private(set) var state: DriverState.State = .unknown

	private var installedDextProperties: OSSystemExtensionProperties? = nil
	private let dextIdentifier: String = Bundle.main.bundleIdentifier! + ".VirtualControllerDriver"
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
			return String(localized: "Driver installed.",
						  comment: "Driver successfully installed")
		case .deactivating:
			return String(localized: "Uninstalling driver.",
						  comment: "Attempting to uninstall driver")
		case .failedToDeactivate:
			return String(localized: "Uninstall failed.",
						  comment: "Encountered an error while uninstalling")
		case .uninstalled:
			return String(localized: "Driver uninstalled.",
						  comment: "Driver successfully removed.")
		case .watingForActivationApproval:
			return String(localized: "Install waiting for user approval.",
						  comment: "User must approve or deny last action")
		case .watingForDeactivationApproval:
			return String(localized: "Uninstall waiting for user approval.",
						  comment: "User must approve or deny last action")
		case .waitingForReboot:
			return String(localized: "Reboot your computer to finalize changes.",
						  comment: "User must rebot to complete that last action")
		case .error:
			return String(localized: "Error.",
						  comment: "Encountered an error or inconsistency.")
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
		//return .replace
		return .cancel
	}

	func requestNeedsUserApproval(_ request: OSSystemExtensionRequest)
	{
		os_log("\(type(of: self)).\(#function)")
		self.state = DriverState.transition(state, .actionNeedsApproval)
	}

	func request(_ request: OSSystemExtensionRequest,
				 didFinishWithResult result: OSSystemExtensionRequest.Result)
	{
		os_log("\(type(of: self)).\(#function)")

		switch result {
		case .completed:
			self.state = DriverState.transition(state, .actionSucceded)
			break
		case .willCompleteAfterReboot:
			self.state = DriverState.transition(state, .actionNeedsReboot)
			break
		@unknown default:
			self.state = .error
		}
	}

	func request(_ request: OSSystemExtensionRequest,
				 didFailWithError error: any Error)
	{
		os_log("\(type(of: self)).\(#function) error=\(error)")
		self.state = DriverState.transition(state, .actionFailed)
	}

	func request(_ request: OSSystemExtensionRequest,
				 foundProperties properties: [OSSystemExtensionProperties])
	{
		os_log("\(type(of: self)).\(#function) request=\(request), properties=\(properties)")
		// Properties:
		// url
		// bundleIdentifier
		// bundleVersion
		// bundleShortVersion
		// isEnabled
		// isAwaitingUserApproval
		// isUninstalling

		if (properties.isEmpty) {
			self.state = DriverState.transition(state, .checkDidNotFindDriver)
			return
		}

		self.state = DriverState.transition(state, .checkFoundDriver)
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

		let request = OSSystemExtensionRequest.activationRequest(
			forExtensionWithIdentifier: dextIdentifier,
			queue: .main // .global(qos: .userInteractive) ??
		)
		request.delegate = self
		OSSystemExtensionManager.shared.submitRequest(request)

		self.state = DriverState.transition(state, .activationBegan)
	}

	func deactivateExtension() {
		os_log("\(type(of: self)).\(#function)")

		if (swiftPreviews) {
			return
		}

		let request = OSSystemExtensionRequest.deactivationRequest(
			forExtensionWithIdentifier: dextIdentifier,
			queue: .main // .global(qos: .userInteractive) ??
		)
		request.delegate = self
		OSSystemExtensionManager.shared.submitRequest(request)

		self.state = DriverState.transition(state, .deactivationBegan)
	}
}
