//
//  SettingsHostingController.swift
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/15/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

import AppKit
import SwiftUI
import os.log

class SettingsHostingController: NSHostingController<SettingsView> {
	required init?(coder: NSCoder) {
		os_log("\(type(of: self)).\(#function)")
		super.init(coder: coder, rootView: SettingsView())
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}
}
