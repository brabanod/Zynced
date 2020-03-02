//
//  StatusIndicatorView.swift
//  Zynced
//
//  Created by Pascal Braband on 19.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import BoteCore

class StatusIndicatorView: NSView {
    
    private(set) var status: SyncStatus = .inactive

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    
    private func setupView() {
        self.wantsLayer = true
        self.layer?.cornerRadius = self.bounds.width / 2
        update(status: .inactive)
    }
    
    
    public func update(status: SyncStatus) {
        switch status {
        case .connected:
            self.layer?.backgroundColor = CGColor.StatusColor.connected
            self.toolTip = NSLocalizedString("Status Connected Explanation", comment: "A tooltip text, which explain what the green color (connected) means.")
        case .active:
            self.layer?.backgroundColor = CGColor.StatusColor.active
            self.toolTip = NSLocalizedString("Status Active Explanation", comment: "A tooltip text, which explain what the yellow color (active) means.")
        case .inactive:
            self.layer?.backgroundColor = CGColor.StatusColor.inactive
            self.toolTip = NSLocalizedString("Status Inactive Explanation", comment: "A tooltip text, which explain what the gray color (inactive) means.")
        case .failed:
            self.layer?.backgroundColor = CGColor.StatusColor.failed
            self.toolTip = NSLocalizedString("Status Failed Explanation", comment: "A tooltip text, which explain what the red color (failed) means.")
        }
    }
    
}
