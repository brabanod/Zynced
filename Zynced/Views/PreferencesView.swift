//
//  PreferencesView.swift
//  Zynced
//
//  Created by Pascal Braband on 13.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class PreferencesView: NSView, LoadableView {

    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        if load(fromNIBNamed: "PreferencesView") {
            // call another init function
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
        
    @IBAction func applySelection(_ sender: Any) {
        dismissPreferences(self)
    }
    
    
    @IBAction func dismissPreferences(_ sender: Any) {
        self.window?.performClose(self)
    }
    
}
