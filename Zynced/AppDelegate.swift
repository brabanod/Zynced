//
//  AppDelegate.swift
//  Zynced
//
//  Created by Pascal Braband on 13.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import BoteCore

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItemManager: StatusItemManager!
    var configManager: ConfigurationManager!
    var syncOrchestrator: SyncOrchestrator!
    
    @IBOutlet weak var menu: NSMenu?


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupSync()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func showPreferences(_ sender: Any) {
        statusItemManager.showPreferences()
    }
    
    
    
    // MARK: - Synchronization setup
    
    func setupSync() {
        if let configManager = ConfigurationManager.init(()){
            self.configManager = configManager
        } else {
            // Alert and terminate app
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("ConfMng fail message", comment: "Alert message for failed initialization of ConfigurationManager.")
            alert.informativeText = NSLocalizedString("ConfMng fail test", comment: "Alert text for failed initialization of ConfigurationManager.")
            alert.alertStyle = NSAlert.Style.warning
            alert.addButton(withTitle: "OK")
            let res = alert.runModal()
            if res == .alertFirstButtonReturn {
                NSApp.terminate(self)
            }
        }
        
        syncOrchestrator = SyncOrchestrator()
        for configuration in configManager.configurations {
            do {
                let item = try syncOrchestrator.register(configuration: configuration)
                try syncOrchestrator.startSynchronizing(for: item, errorHandler: { (item, error) in
                    print("ERROR:\nItem: \(item)\nMessage: \(error)")
                    // FIXME: Write to Error Log file for this item's id
                })
            } catch let error {
                // Alert print(error)
            }
        }
        
        statusItemManager = StatusItemManager(menu: menu, configManager: configManager, syncOrchestrator: syncOrchestrator)
    }
}

