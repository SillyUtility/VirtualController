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
	case .activating:
		return ("progress.indicator", Color.primary)
	//case .needsRestart:
	//	return "arrow.trianglehead.counterclockwise", Color.orange
	case .failedToActivate:
		return ("exclamationmark.circle", Color.red)
	case .installed:
		return ("checkmark.circle", Color.green)
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
				}.disabled(true)
				Button("Uninstall Driver") {
				}.disabled(true)
			}.padding()
		}.frame(width: 600, height: 400)
	}
}

#Preview {
	SettingsView()
}
