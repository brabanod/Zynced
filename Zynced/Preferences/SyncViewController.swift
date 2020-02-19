//
//  SyncViewController.swift
//  Zynced
//
//  Created by Pascal Braband on 18.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import Combine

class SyncViewController: PreferencesViewController {
    
    @IBOutlet weak var itemsTable: NSTableView!
    @IBOutlet weak var syncDirectionSelector: SyncDirectionSelector!
    @IBOutlet weak var detailContainer: NSView!
    
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var startStopButton: NSButton!
    
    @IBOutlet weak var connectionSelectLeft: StackedInputView!
    @IBOutlet weak var connectionSelectRight: StackedInputView!
    private let connectionChoicesLeft = [NSLocalizedString("Local", comment: "Description for local connection")]
    private let connectionChoicesRight = [NSLocalizedString("Local", comment: "Description for local connection"),
                                          NSLocalizedString("SFTP", comment: "Description for SFTP connection"),
                                          NSLocalizedString("FTP", comment: "Description for FTP connection")]
    
    @IBOutlet weak var stackedInputLeft: StackedInputView!
    @IBOutlet weak var stackedInputRight: StackedInputView!
    
    var subscriptions = [(AnyCancellable, AnyCancellable)]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeSubscriptions()
        
        // Set detail container background to white
        detailContainer.wantsLayer = true
        detailContainer.layer?.backgroundColor = NSColor(named: NSColor.Name("BackgroundColor"))?.cgColor
        
        // Setup buttons
        startStopButton.keyEquivalent = "\r"
        
        // Table setup
        itemsTable.delegate = self
        itemsTable.dataSource = self
        itemsTable.rowHeight = ConfigurationInfoView.defaultHeight
        
        // Sync direction selector setup
        syncDirectionSelector.delegate = self
        
        // Setup stacked input views
        setupConnectionSelect()
    }
    
    
    override func viewDidDisappear() {
        removeSubscriptions()
    }
    
    
    override func viewWillAppear() {
        itemsTable.reloadData()
        if itemsTable.numberOfRows > 0 {
            itemsTable.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
    }
    
    
    func setupConnectionSelect() {
        let connectionSelectLeftId = "connectionSelectLeft"
        let connectionSelectRightId = "connectionSelectRight"
        connectionSelectLeft.layout([InputItem(label: NSLocalizedString("Connection", comment: "Label for connection configuration input description."), type: .dropdown, inputIdentifier: connectionSelectLeftId)])
        connectionSelectRight.layout([InputItem(label: NSLocalizedString("Connection", comment: "Label for connection configuration input description."), type: .dropdown, inputIdentifier: connectionSelectRightId)])
        
        if let leftDropdown = connectionSelectLeft.inputStack.views.first(where: { $0.identifier!.rawValue ==  connectionSelectLeftId} ) as? NSPopUpButton {
            leftDropdown.addItems(withTitles: connectionChoicesLeft)
        }
        if let rightDropdown = connectionSelectRight.inputStack.views.first(where: { $0.identifier!.rawValue ==  connectionSelectRightId} ) as? NSPopUpButton {
            rightDropdown.addItems(withTitles: connectionChoicesRight)
        }
    }
    
    
    func removeSubscriptions() {
        // Cancel all subscriptions
        for (statusSub, syncedSub) in subscriptions {
            statusSub.cancel()
            syncedSub.cancel()
        }
        subscriptions.removeAll()
    }
    
    
    @IBAction func addItem(_ sender: Any) {
        print("add")
    }
    
    
    @IBAction func removeItem(_ sender: Any) {
        if itemsTable.selectedRow > -1 {
            // Alert: Ask if user really wants to delete
        } else {
            // Alert: No item selected
        }
    }
    
    
    @IBAction func showErrorLog(_ sender: NSButton) {
    }
    
    
    @IBAction func saveClicked(_ sender: NSButton) {
    }
    
    
    @IBAction func startStopSyncClicked(_ sender: NSButton) {
        // Start -> Set button to default
        sender.keyEquivalent = "\r"
        
        // Stop -> Set button to non-default
        //sender.keyEquivalent = ""
    }
    
}



extension SyncViewController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let item = syncOrchestrator?.syncItems[row] {
            let infoView = ConfigurationInfoView(frame: NSRect(x: 0.0, y: 0.0, width: tableView.bounds.width, height: ConfigurationInfoView.defaultHeight))
            
            infoView.setName(item.configuration.name)
            infoView.setStatus(item.status)
            infoView.setLocation(item.configuration.from.path)
            infoView.setLastSynced(item.lastSynced)
            
            let statusSub = item.$status.sink { (newStatus) in
                infoView.setStatus(newStatus)
            }
            let syncedSub = item.$lastSynced.sink { (newSyncDate) in
                infoView.setLastSynced(newSyncDate)
            }
            subscriptions.append((statusSub, syncedSub))
            
            return infoView
        }
        
        // Return empty cell otherwise
        return NSView(frame: NSRect(x: 0.0, y: 0.0, width: tableView.bounds.width, height: ConfigurationInfoView.defaultHeight))
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return ConfigurationInfoView.defaultHeight
    }
}



extension SyncViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return syncOrchestrator?.syncItems.count ?? 0
    }
}




extension SyncViewController: SyncDirectionSelectorDelegate {
    func didSelectLeft() {
        print("did select left sync direction ...")
    }
    
    func didUnselectLeft() {
        print("did unselect left sync direction ...")
    }
    
    func didSelectRight() {
        print("did select right sync direction ...")
    }
    
    func didUnselectRight() {
        print("did unselect right sync direction ...")
    }
    
    
}
