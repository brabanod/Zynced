//
//  SyncDirectionSelector.swift
//  Zynced
//
//  Created by Pascal Braband on 19.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa


enum SyncDirectionSelectorType: Int {
    case unidirectional = 1
    case bidirectional = 2
}


protocol SyncDirectionSelectorDelegate {
    func didSelectLeft()
    func didUnselectLeft()
    func didSelectRight()
    func didUnselectRight()
}


class SyncDirectionSelector: NSView {
    
    var delegate: SyncDirectionSelectorDelegate?
    private(set) var type: SyncDirectionSelectorType!
    
    private(set) var isLeftSelected = false
    private(set) var isRightSelected = false
    
    private var buttonLeft: NSButton?
    private var buttonRight: NSButton?
    
    private let leftButtonImage = NSImage(named: "LeftArrow")!
    private let rightButtonImage = NSImage(named: "RightArrow")!
    private let leftButtonSelectedImage = NSImage(named: "LeftArrowSelected")!
    private let rightButtonSelectedImage = NSImage(named: "RightArrowSelected")!

    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        set(type: .unidirectional)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        set(type: .unidirectional)
    }
    
    
    init(frame frameRect: NSRect, type: SyncDirectionSelectorType) {
        super.init(frame: frameRect)
        set(type: type)
    }
    
    
    public func set(type: SyncDirectionSelectorType) {
        self.type = type
        self.subviews.forEach({ $0.removeFromSuperview() })
        
        switch type {
        case .unidirectional:
            setupUnidirectional()
        case .bidirectional:
            setupBidirectional()
        }
    }
    
    
    private func setupUnidirectional() {
        let imageView = NSImageView(image: NSImage(named: "RightArrowSelected")!)
        let centerHorizontal = NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let topConst = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        let heightConst = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60.0)
        let aspectRatio = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0.0)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        self.addConstraints([centerHorizontal, topConst, heightConst, aspectRatio])
    }
    
    
    private func setupBidirectional() {
        isLeftSelected = false
        isRightSelected = false
        
        buttonLeft = NSButton(image: leftButtonImage, target: self, action: #selector(SyncDirectionSelector.leftArrowClicked(_:)))
        buttonRight = NSButton(image: rightButtonImage, target: self, action: #selector(SyncDirectionSelector.rightArrowClicked(_:)))
        
        buttonLeft!.isBordered = false
        buttonRight!.isBordered = false
        
        buttonLeft!.translatesAutoresizingMaskIntoConstraints = false
        buttonRight!.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints left button (pin right edge to center x)
        let blRightConst = NSLayoutConstraint(item: buttonLeft!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let blTopConst = NSLayoutConstraint(item: buttonLeft!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        let blWidthConst = NSLayoutConstraint(item: buttonLeft!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60.0)
        let blAspectRatio = NSLayoutConstraint(item: buttonLeft!, attribute: .height, relatedBy: .equal, toItem: buttonLeft!, attribute: .width, multiplier: 1.0, constant: 0.0)
        
        // Constraints right button (pin right edge to center x)
        let brLeftConst = NSLayoutConstraint(item: buttonRight!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let brTopConst = NSLayoutConstraint(item: buttonRight!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        let brWidthConst = NSLayoutConstraint(item: buttonRight!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60.0)
        let brAspectRatio = NSLayoutConstraint(item: buttonRight!, attribute: .height, relatedBy: .equal, toItem: buttonRight!, attribute: .width, multiplier: 1.0, constant: 0.0)
        
        // Add buttons and constraints
        self.addSubview(buttonLeft!)
        self.addSubview(buttonRight!)
        self.addConstraints([blRightConst, blTopConst, blWidthConst, blAspectRatio])
        self.addConstraints([brLeftConst, brTopConst, brWidthConst, brAspectRatio])
        
    }
    
    
    @objc private func leftArrowClicked(_ sender: NSButton) {
        // Update status, image and then call delegate
        if isLeftSelected {
            isLeftSelected = false
            sender.image = leftButtonImage
            delegate?.didUnselectLeft()
        } else {
            isLeftSelected = true
            sender.image = leftButtonSelectedImage
            delegate?.didSelectLeft()
        }
    }
    
    
    @objc private func rightArrowClicked(_ sender: NSButton) {
        // Update status, image and then call delegate
        if isRightSelected {
            isRightSelected = false
            sender.image = rightButtonImage
            delegate?.didUnselectRight()
        } else {
            isRightSelected = true
            sender.image = rightButtonSelectedImage
            delegate?.didSelectRight()
        }
        
        
    }
}
