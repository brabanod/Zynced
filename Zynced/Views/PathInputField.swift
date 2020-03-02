//
//  PathInputField.swift
//  Zynced
//
//  Created by Pascal Braband on 29.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class PathInputField: ClipfreeControl {
       
    var textField: NSTextField!
    private var openButton: NSButton!
    var canChooseFiles = false
    
    override var isEnabled: Bool {
        didSet {
            self.textField.isEnabled = self.isEnabled
            self.openButton.isEnabled = self.isEnabled
        }
    }
    
    
    override var font: NSFont? {
        set {
            self.textField.font = newValue
        } get {
            return self.textField.font
        }
    }
    
    
    override var stringValue: String {
        set {
            self.textField.stringValue = newValue
        } get {
            return self.textField.stringValue
        }
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
        textField = NSTextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isEditable = true
        textField.isSelectable = true
        textField.cell?.isScrollable = true
        
        openButton = NSButton(frame: .zero)
        openButton.translatesAutoresizingMaskIntoConstraints = false
        openButton.setButtonType(.momentaryPushIn)
        openButton.isBordered = true
        openButton.bezelStyle = .rounded
        openButton.title = "..."
        openButton.target = self
        openButton.action = #selector(PathInputField.openPathDialog)
        
        // Add constraints
        let textFieldLeft = NSLayoutConstraint(item: textField!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0)
        let textFieldCenter = NSLayoutConstraint(item: textField!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        
        let openButtonRight = NSLayoutConstraint(item: openButton!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)
        let openButtonCenter = NSLayoutConstraint(item: openButton!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let openButtonWidth = NSLayoutConstraint(item: openButton!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25.0)
        
        let textFieldOpenButtonDistance = NSLayoutConstraint(item: openButton!, attribute: .left, relatedBy: .equal, toItem: textField!, attribute: .right, multiplier: 1.0, constant: 10.0)
        
        self.addSubview(textField)
        self.addSubview(openButton)
        self.addConstraints([textFieldLeft, textFieldCenter, openButtonRight, openButtonCenter, textFieldOpenButtonDistance])
        openButton.addConstraint(openButtonWidth)
    }
    
    
    @objc private func openPathDialog() {
        let dialog = NSOpenPanel();

        dialog.title = NSLocalizedString("Choose Directory", comment: "Title for open file panel in PathInputField.");
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = self.canChooseFiles
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = true
        dialog.allowsMultipleSelection = false;

        if (dialog.runModal() == .OK) {
            // Write path to textfield
            if let result = dialog.url {
                let path = result.path
                textField.stringValue = path
            }
        }
    }
}
