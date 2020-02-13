//
//  StatusItemManager.swift
//  Zynced
//
//  Created by Pascal Braband on 13.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class StatusItemManager: NSObject {
    
    var statusItem: NSStatusItem?
    
    var menu: NSMenu?
    
    
    init(menu: NSMenu?) {
        super.init()
        
        self.menu = menu
        initStatusItem()
    }
    
    
    func initStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Assign status item button image
        let itemImage = NSImage(named: "StatusIcon")
        itemImage?.isTemplate = true
        statusItem?.button?.image = itemImage
        
        // React to menu actions
        if let menu = menu {
            statusItem?.menu = menu
            menu.delegate = self
        }
        
        // Setup info views
        if let infoItem = menu?.items.first {
            let customView = ConfigurationInfoView(frame: NSRect(x: 0.0, y: 0.0, width: 350.0, height: 56.0))
            infoItem.view = customView
        }
    }
    
    
    func showPreferences() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: .init(stringLiteral: "preferencesID")) as? ViewController else { return }
        
        let window = NSWindow(contentViewController: vc)
        window.makeKeyAndOrderFront(nil)
    }
}



extension StatusItemManager: NSMenuDelegate {
    
    func menuWillOpen(_ menu: NSMenu) {
        // Update something
    }
    
    func menuDidClose(_ menu: NSMenu) {
        // Stop updating
    }
}
