//
//  PopUpButton.swift
//  Zynced
//
//  Created by Pascal Braband on 04.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

/**
 This class is used to wire up a target + selector to an NSPopupField, with an additional filter.
 */
class PopUpButtonCallback: NSObject {
    let selector: Selector?
    let target: AnyObject?
    let popupButton: PopUpButton!
    
    init(selector: Selector?, target: AnyObject?, popupButton: PopUpButton) {
        self.selector = selector
        self.target = target
        self.popupButton = popupButton
        
        super.init()
        self.popupButton.target = self
        self.popupButton.action = #selector(PopUpButtonCallback.didChangeSelection)
    }
    
    @objc func didChangeSelection() {
        // Only call target.selector if selection truly changed
        if popupButton.indexOfPreviouslySelectedItem != popupButton.indexOfSelectedItem {
            if target != nil && selector != nil {
                target!.performSelector(onMainThread: selector!, with: popupButton, waitUntilDone: false)
            }
        }
    }
}




class PopUpButton: NSPopUpButton {
    
    var indexOfPreviouslySelectedItem: Int = -1
    
    override func selectItem(at index: Int) {
        super.selectItem(at: index)
        indexOfPreviouslySelectedItem = self.indexOfSelectedItem
    }
    
    override func select(_ item: NSMenuItem?) {
        super.select(item)
        indexOfPreviouslySelectedItem = self.indexOfSelectedItem
    }
    
    override func selectItem(withTitle title: String) {
        super.selectItem(withTitle: title)
        indexOfPreviouslySelectedItem = self.indexOfSelectedItem
    }
    
    override func selectItem(withTag tag: Int) -> Bool {
        let result = super.selectItem(withTag: tag)
        indexOfPreviouslySelectedItem = self.indexOfSelectedItem
        return result
    }
}
