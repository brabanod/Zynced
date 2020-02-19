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
        case .active:
            self.layer?.backgroundColor = CGColor.StatusColor.active
        case .inactive:
            self.layer?.backgroundColor = CGColor.StatusColor.inactive
        case .failed:
            self.layer?.backgroundColor = CGColor.StatusColor.failed
        }
    }
    
}
