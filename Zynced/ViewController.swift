//
//  ViewController.swift
//  Zynced
//
//  Created by Pascal Braband on 13.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import BoteCore

class ViewController: NSViewController {
    
    var configManager: ConfigurationManager!
    var syncOrchestrator: SyncOrchestrator!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        view.window?.styleMask.remove(.resizable)
        view.window?.styleMask.remove(.miniaturizable)
        view.window?.center()
        
        let preferencesView = PreferencesView(frame: self.view.bounds)
        preferencesView.add(toView: self.view)
    }
}

