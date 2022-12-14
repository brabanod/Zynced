//
//  StackedInputView.swift
//  Zynced
//
//  Created by Pascal Braband on 19.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa


enum InputType {
    case textfield, dropdown, filetextfield
}


struct InputItem {
    var label: String
    var placeholder: String?
    var type: InputType
    var inputIdentifier: String
    var selector: Selector?
    var target: AnyObject?
}


class StackedInputView: ClipfreeControl {
    
    /** An array of the configured `InputItem`'s. */
    var inputItems: [InputItem] = [InputItem]()
    
    /** The `NSStackView` which contains all the input fields. */
    var labelStack: NSStackView!
    
    /** The `NSStackView` which contains all the input fields. */
    var inputStack: NSStackView!
    
    /** Setting this will also set the according value in all inputs. */
    override var isEnabled: Bool {
        didSet {
            setIsEnabledForAllInputs(self.isEnabled)
        }
    }
    
    /** The percentual distribution of the two views (means one is 0.3 wide, the other 0.7). */
    private let distributionRatio: CGFloat = 0.3
    
    /** The spacing between the two stack view. */
    private let stackSpace: CGFloat = 10.0
    
    /** The height of an input group. */
    private let itemHeight: CGFloat = 20.0
    
    /** The spacing between elements in the stacks. */
    private let stackItemSpacing: CGFloat = 20.0
    
    private var callbacks = [NSObject]()

    
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
        
        // Remove all callbacks
        callbacks = [TextFieldCallback]()
    }
    
    
    func layout(_ inputs: [InputItem]) {
        resetLayout()
        inputItems = inputs
        
        // Create input for each item in array
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
                textfield.placeholderString = item.placeholder
                textfield.isEditable = true
                textfield.cell?.isScrollable = true
                let callback = TextFieldCallback(selector: item.selector, target: item.target)
                callbacks.append(callback)
                textfield.delegate = callback
                input = textfield
                
            case .filetextfield:
                let fileInput = PathInputField(frame: .zero)
                fileInput.textField.placeholderString = item.placeholder
                fileInput.textField.isEditable = true
                fileInput.textField.cell?.isScrollable = true
                let callback = TextFieldCallback(selector: item.selector, target: item.target)
                callbacks.append(callback)
                fileInput.textField.delegate = callback
                input = fileInput

            case .dropdown:
                let dropdown = PopUpButton(frame: .zero)
                dropdown.autoenablesItems = true
                let callback = PopUpButtonCallback(selector: item.selector, target: item.target, popupButton: dropdown)
                callbacks.append(callback)
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
    
    
    private func setIsEnabledForAllInputs(_ isEnabled: Bool) {
        for view in inputStack.views {
            if let input = view as? NSControl {
                input.isEnabled = isEnabled
            }
        }
    }
}




/**
 This class is used to wire up a target + selector to an NSTextFieldDelegate
 */
class TextFieldCallback: NSObject, NSTextFieldDelegate {
    let selector: Selector?
    let target: AnyObject?
    
    init(selector: Selector?, target: AnyObject?) {
        self.selector = selector
        self.target = target
    }
    
    func controlTextDidChange(_ obj: Notification) {
        if target != nil && selector != nil {
            target!.performSelector(inBackground: selector!, with: obj.object as? NSTextField)
        }
    }
}
