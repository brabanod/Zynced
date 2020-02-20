//
//  StackedInputView.swift
//  Zynced
//
//  Created by Pascal Braband on 19.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa


enum InputType {
    case textfield, dropdown
}


struct InputItem {
    var label: String
    var type: InputType
    var inputIdentifier: String
}


protocol StackedInputViewDelegate {
    func didChangeTextField(sender: NSTextField)
    func didSelectDropdownItem(sender: NSPopUpButton, index: Int)
}


class StackedInputView: NSView {
    
    var inputItems: [InputItem] = [InputItem]()
    var labelStack: NSStackView!
    var inputStack: NSStackView!
    
    // The percentual distribution of the two views (means one is 0.3 wide, the other 0.7)
    private let distributionRatio: CGFloat = 0.3
    
    // The spacing between the two stack view
    private let stackSpace: CGFloat = 10.0
    
    // The height of an input group
    private let itemHeight: CGFloat = 20.0
    
    // The spacing between elements in the stacks
    private let stackItemSpacing: CGFloat = 20.0
    
    var delegate: StackedInputViewDelegate?

    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupLayout()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    
    init(frame frameRect: NSRect, inputs: [InputItem]) {
        super.init(frame: frameRect)
        setupLayout()
    }
    
    
    /**
     Creates the basic structure for every StackedInputView
     */
    private func setupLayout() {
        let spacer = NSView(frame: .zero)
        
        labelStack = NSStackView(frame: .zero)
        labelStack.orientation = .vertical
        labelStack.distribution = .gravityAreas
        labelStack.spacing = stackItemSpacing
        
        inputStack = NSStackView(frame: .zero)
        inputStack.orientation = .vertical
        inputStack.distribution = .gravityAreas
        inputStack.spacing = stackItemSpacing
        
        spacer.translatesAutoresizingMaskIntoConstraints = false
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        inputStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Calculate view distribution
        let centerMultiplier: CGFloat = 2 * distributionRatio
        
        // Add spacer with constraints
        let spacerTop = NSLayoutConstraint(item: spacer, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        let spacerBottom = NSLayoutConstraint(item: spacer, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let spacerCenter = NSLayoutConstraint(item: spacer, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: centerMultiplier, constant: 0.0)
        let spacerWidth = NSLayoutConstraint(item: spacer, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: stackSpace)
        
        self.addSubview(spacer)
        self.addConstraints([spacerTop, spacerBottom, spacerCenter])
        spacer.addConstraints([spacerWidth])

        // Add labelStack with constraints
        let labelTop = NSLayoutConstraint(item: labelStack!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        let labelBottom = NSLayoutConstraint(item: labelStack!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let labelLeft = NSLayoutConstraint(item: labelStack!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0)
        let labelRight = NSLayoutConstraint(item: labelStack!, attribute: .right, relatedBy: .equal, toItem: spacer, attribute: .left, multiplier: 1.0, constant: 0.0)

        self.addSubview(labelStack)
        self.addConstraints([labelTop, labelBottom, labelLeft, labelRight])

        // Add inputStack
        let inputTop = NSLayoutConstraint(item: inputStack!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        let inputBottom = NSLayoutConstraint(item: inputStack!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let inputLeft = NSLayoutConstraint(item: inputStack!, attribute: .left, relatedBy: .equal, toItem: spacer, attribute: .right, multiplier: 1.0, constant: 0.0)
        let inputRight = NSLayoutConstraint(item: inputStack!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)

        self.addSubview(inputStack)
        self.addConstraints([inputTop, inputBottom, inputLeft, inputRight])
        
        
        
        
        // FIXME: Just for demo -- REMOVE
//        spacer.wantsLayer = true
//        spacer.layer?.backgroundColor = CGColor(red: 0.6, green: 0.1, blue: 0.0, alpha: 0.3)
//        labelStack.wantsLayer = true
//        labelStack.layer?.backgroundColor = CGColor(red: 0.2, green: 0.1, blue: 0.0, alpha: 0.3)
//        inputStack.wantsLayer = true
//        inputStack.layer?.backgroundColor = CGColor(red: 0.6, green: 0.8, blue: 0.0, alpha: 0.3)
    }
    
    
    /**
     Removes all input groups from the `StackedInputView`.
     */
    private func resetLayout() {
        // Remove all labels from stack
        for view in labelStack.views {
            labelStack.removeView(view)
        }
        
        // Remove all inputs from stack
        for view in inputStack.views {
            inputStack.removeView(view)
        }
    }
    
    
    func layout(_ inputs: [InputItem]) {
        resetLayout()
        inputItems = inputs
        
        for item in inputs {
            // Create label
            let label = NSTextField(frame: .zero)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.stringValue = item.label
            label.isEditable = false
            label.isSelectable = false
            label.isBordered = false
            label.drawsBackground = false
            label.font = NSFont.systemFont(ofSize: 14.0)
            label.alignment = .right
            
            // Add label to stack with constraints
            let labelLeft = NSLayoutConstraint(item: label, attribute: .left, relatedBy: .equal, toItem: labelStack, attribute: .left, multiplier: 1.0, constant: 0.0)
            let labelRight = NSLayoutConstraint(item: label, attribute: .right, relatedBy: .equal, toItem: labelStack, attribute: .right, multiplier: 1.0, constant: 0.0)
            let labelHeight = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: itemHeight)
            
            label.addConstraint(labelHeight)
            labelStack.addView(label, in: .top)
            labelStack.addConstraints([labelLeft, labelRight])
            
            
            // Create Input
            var input: NSControl!
            switch item.type {
            case .textfield:
                let textfield = NSTextField(frame: .zero)
                textfield.isEditable = true
                textfield.delegate = self
                input = textfield

            case .dropdown:
                let dropdown = NSPopUpButton(frame: .zero)
                dropdown.target = self
                dropdown.action = #selector(StackedInputView.popUpButtonDidChange(_:))
                dropdown.autoenablesItems = true
                input = dropdown
            }

            input.font = NSFont.systemFont(ofSize: 14)
            input.translatesAutoresizingMaskIntoConstraints = false
            input.identifier = NSUserInterfaceItemIdentifier(rawValue: item.inputIdentifier)

            // Add input to stack with constraints
            let inputLeft = NSLayoutConstraint(item: input!, attribute: .left, relatedBy: .equal, toItem: inputStack, attribute: .left, multiplier: 1.0, constant: 0.0)
            let inputRight = NSLayoutConstraint(item: input!, attribute: .right, relatedBy: .equal, toItem: inputStack, attribute: .right, multiplier: 1.0, constant: 0.0)
            let inputHeight = NSLayoutConstraint(item: input!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: itemHeight)
            
            input.addConstraint(inputHeight)
            inputStack.addView(input, in: .top)
            inputStack.addConstraints([inputLeft, inputRight])
        }
    }
}



extension StackedInputView: NSTextFieldDelegate {
    
    func controlTextDidEndEditing(_ obj: Notification) {
        print("textfield did change...")
        if let textField = obj.object as? NSTextField {
            delegate?.didChangeTextField(sender: textField)
        }
    }
}



extension StackedInputView {
    
    @objc func popUpButtonDidChange(_ sender: NSPopUpButton) {
        print("pop up did change...")
        delegate?.didSelectDropdownItem(sender: sender, index: sender.indexOfSelectedItem)
    }
}
