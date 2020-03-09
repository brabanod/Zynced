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
    @IBOutlet weak var statusIndicator: StatusIndicatorView!
    
    
    static let defaultHeight: CGFloat = 58.0
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        _ = load(fromNIBNamed: "ConfigurationInfoView")
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func awakeFromNib() {
        statusIndicator.update(status: .inactive)
    }
    
    
    func setStatus(_ status: SyncStatus) {
        statusIndicator.update(status: status)
    }
    
    
    func setName(_ string: String) {
        nameLabel.stringValue = string
    }
    
    
    func setLocation(_ path: String) {
        locationLabel.stringValue = path.replaceHomeDirectory()
    }
    
    
    func setLastSynced(_ time: Date?) {
        if let lastSynced = time {
            // If last synced today, show time
            if Calendar.current.isDateInToday(lastSynced) {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                lastSyncedLabel.stringValue = formatter.string(from: lastSynced)
                return
            }
        }
        
        // Else show nothing
        lastSyncedLabel.stringValue = "-"
    }
}
