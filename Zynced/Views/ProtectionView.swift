//
//  ProtectionView.swift
//  Zynced
//
//  Created by Pascal Braband on 02.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class ProtectionView: NSControl {

    /**  A boolean value indicating whether the protection is active. */
    private(set) var isProtectionEnabled = false
    
    /** An array of controls, which should be disabled, when protection is active */
    var protectedControls: [NSControl]?
    
    
    override func mouseDown(with event: NSEvent) {
        print("mouse down")
        if isProtectionEnabled {
            if target != nil, action != nil {
                target!.performSelector(onMainThread: action!, with: self, waitUntilDone: false)
            }
        }
    }
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    func setup() {
        disableProtection()
    }
    
    
    func enableProtection() {
        isProtectionEnabled = true
        
        // Enable all protected controls
        setIsEnabledForProtectedControls(false)
    }
    
    
    func disableProtection() {
        isProtectionEnabled = false
        
        // Disable all protected controls
        setIsEnabledForProtectedControls(true)
    }
    
    
    func setIsEnabledForProtectedControls(_ isEnabled: Bool) {
        if let protected = protectedControls {
            for control in protected {
                control.isEnabled = isEnabled
            }
        }
    }
    
}
