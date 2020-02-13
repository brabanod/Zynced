//
//  ConfigurationInfoView.swift
//  Zynced
//
//  Created by Pascal Braband on 13.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import BoteCore

class ConfigurationInfoView: NSView, LoadableView {
    
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var locationLabel: NSTextField!
    @IBOutlet weak var lastSyncedLabel: NSTextField!
    @IBOutlet weak var statusIndicator: NSView!
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        _ = load(fromNIBNamed: "ConfigurationInfoView")
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func awakeFromNib() {
        statusIndicator.wantsLayer = true
        statusIndicator.layer?.cornerRadius = statusIndicator.bounds.width / 2
        statusIndicator.layer?.backgroundColor = CGColor.StatusColor.active
        
        nameLabel.stringValue = "Admin Server"
        locationLabel.stringValue = "~/Movies/Projekte/DaVinci Resolve"
        lastSyncedLabel.stringValue = "12:08"
    }
    
    
    func setStatus(_ status: SyncStatus) {
        switch status {
        case .connected:
            statusIndicator.layer?.backgroundColor = CGColor.StatusColor.connected
        case .active:
            statusIndicator.layer?.backgroundColor = CGColor.StatusColor.active
        case .inactive:
            statusIndicator.layer?.backgroundColor = CGColor.StatusColor.inactive
        case .failed:
            statusIndicator.layer?.backgroundColor = CGColor.StatusColor.failed
        }
    }
    
    
    func setName(_ string: String) {
        nameLabel.stringValue = string
    }
    
    
    func setLocation(_ path: String) {
        // Replace the home directory with ~
        let homePath = FileManager.default.homeDirectoryForCurrentUser.absoluteString.dropFirst("file://".count)
        let readablePath = path.replacingOccurrences(of: homePath, with: "~/")
        locationLabel.stringValue = readablePath
    }
    
    
    func setLastSynced(_ time: Date) {
        // If last synced today, show time
        if Calendar.current.isDateInToday(time) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            lastSyncedLabel.stringValue = formatter.string(from: Date.init())
        }
        // Else show nothing
        else {
            lastSyncedLabel.stringValue = "-"
        }
    }
}
