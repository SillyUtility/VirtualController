//
//  SettingsView.swift
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/15/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

import SwiftUI

func systemImageForState(_ state: DriverInstallationState.State) -> (String,  Color) {
	switch state {
	case .unknown:
		return ("questionmark", Color.gray)
	case .checking:
		return ("magnifyingglass", Color.primary)
	case .missing:
		return ("exclamationmark.magnifyingglass", Color.orange)
	case .activating, .deactivating, .watingForActivationApproval,
			.watingForDeactivationApproval:
		return ("clock", Color.primary)
	case .failedToActivate, .failedToDeactivate:
		return ("exclamationmark.triangle", Color.red)
	case .installed:
		return ("checkmark.circle", Color.green)
	case .uninstalled:
		return ("trash.circle", Color.green)
	case .waitingForReboot:
		return ("arrow.counterclockwise", Color.orange)
	case .error:
		return ("nosign.app", Color.red)
	}
}

func canInstall(_ state: DriverInstallationState.State) -> Bool {
	switch state {
	case .missing, .uninstalled: return true
	default: return false
	}
}

struct SettingsView: View {
	@ObservedObject var driverController = NSApp.appDelegate.driverInstallationController

	var body: some View {
		VStack(alignment: .center) {
			Text("Virtual Controller Driver").font(.largeTitle)
			Image(systemName: "gamecontroller").imageScale(.large)
				.foregroundColor(.accentColor)
				//.rotationEffect(Angle(degrees: 0), anchor: .center)
				.padding(.vertical)

			let (sysImage, color) = systemImageForState(self.driverController.state)
			Label {
				Text(self.driverController.stateDescription)
					.font(.title)
					.multilineTextAlignment(.center)
			} icon: {
				Image(systemName: sysImage)
					.imageScale(.large)
					.foregroundColor(color)
			}
			.padding(.bottom)

			HStack {
				Button("Install Driver") {
					self.driverController.activateExtension()
				}.disabled(!canInstall(self.driverController.state))
				Button("Uninstall Driver") {
					self.driverController.deactivateExtension()
				}.disabled(self.driverController.state != .installed)
			}.padding()
		}.frame(width: 600, height: 400)
	}
}

#Preview {
	SettingsView()
}
