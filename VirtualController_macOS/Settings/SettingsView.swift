//
//  SettingsView.swift
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/15/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

import SwiftUI

func systemImageForState(_ state: DriverState.State) -> (String,  Color) {
	switch state {
	case .unknown:
		return ("questionmark.square.dashed", Color.gray)
	case .checking:
		return ("magnifyingglass", Color.primary)
	case .missing:
		return ("square.dashed", Color.orange)
	case .activating, .deactivating, .waitingForUserApproval:
		return ("clock", Color.primary)
	case .failedToActivate:
		return ("exclamationmark.circle", Color.red)
	case .installed:
		return ("checkmark.circle", Color.green)
	case .failedToDeactivate:
		return ("exclamationmark.circle", Color.red)
	case .uninstalled:
		return ("trash.circle", Color.green)
	case .waitingForReboot:
		return ("arrow.trianglehead.counterclockwise", Color.orange)
	case .error:
		return ("nosign.app", Color.red)
	}
}

func canInstall(_ state: DriverState.State) -> Bool {
	switch state {
	case .missing, .uninstalled: return true
	default: return false
	}
}

struct SettingsView: View {
	@ObservedObject var driverController = DriverController()

	var body: some View {
		VStack(alignment: .center) {
			Text("Virtual Controller Driver").font(.title)
			Image(systemName: "gamecontroller").imageScale(.large)
				.foregroundColor(.accentColor)
				//.rotationEffect(Angle(degrees: 0), anchor: .center)
				.padding(.vertical)

			let (sysImage, color) = systemImageForState(self.driverController.state)
			Label {
				Text(self.driverController.stateDescription)
					.font(.title2)
					.multilineTextAlignment(.center)
			} icon: {
				Image(systemName: sysImage)
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
