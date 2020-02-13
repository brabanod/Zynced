//
//  AppDelegate.swift
//  Zynced
//
//  Created by Pascal Braband on 13.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItemManager: StatusItemManager!
    
    @IBOutlet weak var menu: NSMenu?


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        statusItemManager = StatusItemManager(menu: menu)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func showPreferences(_ sender: Any) {
        statusItemManager.showPreferences()
    }
}

