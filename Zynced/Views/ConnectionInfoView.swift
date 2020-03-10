//
//  ConnectionInfoView.swift
//  Zynced
//
//  Created by Pascal Braband on 09.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import BoteCore

class ConnectionInfoView: NSView, LoadableView {
    
    private var connection: Connection?
    
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var locationLabel: NSTextField!
    @IBOutlet weak var pathLabel: NSTextField!
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        _ = load(fromNIBNamed: "ConnectionInfoView")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _ = load(fromNIBNamed: "ConnectionInfoView")
    }
    
    
    override func awakeFromNib() {
        update(with: nil)
    }
    
    
    func update(with connection: Connection?) {
        self.connection = connection
        
        if connection != nil {
            // Set image
            if isRemoteConnection(connection!) {
                imageView.image = NSImage(named: "Remote")
            } else {
                imageView.image = NSImage(named: "Local")
            }
            
            // Set location
            locationLabel.stringValue = getLocation(for: connection!)
            
            // Set path
            pathLabel.stringValue = getPath(for: connection!)
        } else {
            imageView.image = NSImage(named: "Local")!
            locationLabel.stringValue = NSLocalizedString("Location", comment: "Title for location in connection detail view.")
            pathLabel.stringValue = NSLocalizedString("Path Title", comment: "Title for path in connection detail view.")
        }
    }
    
    
    private func isRemoteConnection(_: Connection) -> Bool {
        let isRemoteType = connection?.type != ConnectionType.local
        return isRemoteType || self.isiCloudConnection(connection)
    }
    
    
    private func getLocation(for connection: Connection) -> String {
        if connection.type == .local {
            if self.isiCloudConnection(connection) {
                return "iCloud"
            } else {
                return Host.current().localizedName ?? NSLocalizedString("Local Machine", comment: "Title for local machine.")
            }
        } else {
            return NSLocalizedString("Remote Machine", comment: "Title for remote machine.")
        }
    }
    
    
    private func getPath(for connection: Connection) -> String {
        if connection.path == "" {
            return NSLocalizedString("Path Title", comment: "Title for path in connection detail view.")
        } else {
            var cleanPath = connection.path.replaceHomeDirectory()
            cleanPath = cleanPath.replacingOccurrences(of: "~/Library/Mobile Documents/com~apple~CloudDocs/", with: "/")
            return cleanPath
        }
    }
    
    
    private func isiCloudConnection(_ connection: Connection?) -> Bool {
        return connection?.path.contains("/Library/Mobile Documents/com~apple~CloudDocs/") ?? false
    }
    
}
