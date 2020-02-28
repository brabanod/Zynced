//
//  ZyncedApplication.swift
//  Zynced
//
//  Created by Pascal Braband on 28.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class MainApplication: NSApplication {
    
    override func sendEvent(_ event: NSEvent) {
        if event.type == .keyDown {
            if event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                switch event.charactersIgnoringModifiers?.lowercased() {
                case "x":
                    if NSApp.sendAction(#selector(NSText.cut(_:)), to:nil, from:self) { return }
                case "c":
                    if NSApp.sendAction(#selector(NSText.copy(_:)), to:nil, from:self) { return }
                case "v":
                    if NSApp.sendAction(#selector(NSText.paste(_:)), to:nil, from:self) { return }
                case "z":
                    if NSApp.sendAction(Selector(("undo:")), to:nil, from:self) { return }
                case "a":
                    if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to:nil, from:self) { return }
                default:
                    break
                }
            }
            else if ((event.modifierFlags.intersection(.deviceIndependentFlagsMask).rawValue == (NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue)) ||
                (event.modifierFlags.intersection(.deviceIndependentFlagsMask).rawValue) == (NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue | NSEvent.ModifierFlags.capsLock.rawValue)) {
                if event.charactersIgnoringModifiers == "Z" {
                    if NSApp.sendAction(Selector(("redo:")), to:nil, from:self) { return }
                }
            }
        }
        return super.sendEvent(event)
    }
}
