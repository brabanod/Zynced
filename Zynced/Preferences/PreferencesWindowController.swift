//
//  PreferencesWindowController.swift
//  Zynced
//
//  Created by Pascal Braband on 18.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Setup window
        self.window?.styleMask.remove(.resizable)
        self.window?.center()
        self.window?.setContentBorderThickness(50.0, for: NSRectEdge.minY)
    }

}
