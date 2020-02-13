//
//  ConfigurationInfoView.swift
//  Zynced
//
//  Created by Pascal Braband on 13.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

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
    
}
