//
//  SyncViewController.swift
//  Zynced
//
//  Created by Pascal Braband on 18.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import Combine
import BoteCore

class SyncViewController: PreferencesViewController {
    
    @IBOutlet weak var itemsTable: NSTableView!
    @IBOutlet weak var syncDirectionSelector: SyncDirectionSelector!
    @IBOutlet weak var detailContainer: NSView!
    
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var startStopButton: NSButton!
    
    @IBOutlet weak var connectionSelectLeft: StackedInputView!
    @IBOutlet weak var connectionSelectRight: StackedInputView!
    private let connectionSelectLeftId = "connectionSelectLeft"
    private let connectionSelectRightId = "connectionSelectRight"
    private let connectionChoicesLeft: [ConnectionType] = [ConnectionType.local]
    private let connectionChoicesRight: [ConnectionType] = [ConnectionType.local, ConnectionType.sftp]
    
    @IBOutlet weak var stackedInputLeft: StackedInputView!
    @IBOutlet weak var stackedInputRight: StackedInputView!
    let stackedInputLeftId = "stackedInputLeft"
    let stackedInputRightId = "stackedInputRight"
    
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
        stackedInputLeft.identifier = NSUserInterfaceItemIdentifier(rawValue: stackedInputLeftId)
        stackedInputRight.identifier = NSUserInterfaceItemIdentifier(rawValue: stackedInputRightId)
        
        // FIXME: Remove, only for TEST purpose
        do {
            let c1 = LocalConnection(path: "/Users/pascal/Documents/GPU/Projekt")
            let c2 = try SFTPConnection(path: "/home/pi/GPU", host: "192.168.0.94", port: 28, user: "pi", authentication: .password(value: "admin"))
            let conf = Configuration(from: c1, to: c2)
            setupInputsLocal(for: stackedInputLeft, configuration: conf)
            setupInputsSFTP(for: stackedInputRight, configuration: conf)
        } catch _ {
            print("ERRORORORO")
        }
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
        connectionSelectLeft.layout([InputItem(label: NSLocalizedString("Connection", comment: "Label for connection configuration input description."), type: .dropdown, inputIdentifier: connectionSelectLeftId, selector: #selector(SyncViewController.leftConnectionChanged(_:)), target: self)])
        connectionSelectRight.layout([InputItem(label: NSLocalizedString("Connection", comment: "Label for connection configuration input description."), type: .dropdown, inputIdentifier: connectionSelectRightId, selector: #selector(SyncViewController.rightConnectionChanged(_:)), target: self)])
        
        if let leftDropdown = connectionSelectLeft.inputStack.views.first(where: { $0.identifier!.rawValue ==  connectionSelectLeftId} ) as? NSPopUpButton {
            leftDropdown.addItems(withTitles: connectionChoicesLeft.map({ $0.toString() }))
        }
        if let rightDropdown = connectionSelectRight.inputStack.views.first(where: { $0.identifier!.rawValue ==  connectionSelectRightId} ) as? NSPopUpButton {
            rightDropdown.addItems(withTitles: connectionChoicesRight.map({ $0.toString() }))
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
        // Update detail view
        setupInputsDefault()
        // Deselect row in table
        itemsTable.selectRowIndexes(IndexSet(integer: -1), byExtendingSelection: false)
    }
    
    
    @IBAction func removeItem(_ sender: Any) {
        if itemsTable.selectedRow > -1 {
            // Alert: Ask if user really wants to delete
            // TDOD: Update detail view
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



// MARK: - NSTableViewDelegate
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
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let tableview = notification.object as? NSTableView {
            print("selected row index \(tableview.selectedRow)")
            // TODO: Update detail view
        }
    }
}



// MARK: - NSTableViewDataSource
extension SyncViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return syncOrchestrator?.syncItems.count ?? 0
    }
}




// MARK: - SyncDirectionSelectorDelegate
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




// MARK: - Stack Input Setup
extension SyncViewController {
    
    private func setupInputsDefault() {
        setupInputsLocal(for: stackedInputLeft, configuration: nil)
        setupInputsSFTP(for: stackedInputRight, configuration: nil)
    }
    
    
    private func setupInputs(for configuration: Configuration) {
        // Setup inputs for left side (from)
        setupInputs(for: configuration.fromType, configuration: configuration, stackView: stackedInputLeft)
        
        // Setup inputs for right side (to)
        setupInputs(for: configuration.toType, configuration: configuration, stackView: stackedInputRight)
    }
    
    
    /**
     Sets up input stacks.
     
     - parameters:
        - type: The type, which determines the stack input layout and fields.
        - configuration: An optional `Configuration`, which is filled in the input fields.
        - stackView: The corresponding `StackedInputView`, for which the setup should be performed
     */
    private func setupInputs(for type: ConnectionType, configuration: Configuration?, stackView: StackedInputView) {
        switch type {
        case .local:
            setupInputsLocal(for: stackView, configuration: configuration)
        case .sftp:
            setupInputsSFTP(for: stackView, configuration: configuration)
        }
    }
    
    
    /**
     Lays out inputs for a local connection.
     
     - parameters:
        - stackView: The `StackedInputView`, in which the inputs should be layed out.
        - configuration: Optional `Configuration`. If given, inputs are filled with these values. If not, inputs stay empty/default.
     */
    private func setupInputsLocal(for stackView: StackedInputView, configuration: Configuration?) {
        selectConnection(for: stackView, type: .local)
        let stackID = stackView.identifier?.rawValue ?? ""
        if stackID == "" { print("### stackID ist empty") }
        
        let layout = [InputItem(label: NSLocalizedString("Path", comment: "Label for path configuration input description."), type: .textfield, inputIdentifier: stackID + ".localPath")]
        
        stackView.layout(layout)
        
        // Fill with configuration
        if let conf = configuration {
            if let connection = getConnection(for: stackView, from: conf) as? LocalConnection {
                if stackView.inputStack.views.count == layout.count {
                    (stackView.inputStack.views[0] as? NSTextField)?.stringValue = connection.path
                }
            }
            ErrorLogger.write(for: conf.id, date: Date(), type: nil, message: "Coulnd't load Configuration, because Connection was not of type \(ConnectionType.local.toString()).")
        }
    }
    
    
    /**
    Lays out inputs for a SFTP connection.
    
    - parameters:
       - stackView: The `StackedInputView`, in which the inputs should be layed out.
       - configuration: Optional `Configuration`. If given, inputs are filled with these values. If not, inputs stay empty/default.
    */
    private func setupInputsSFTP(for stackView: StackedInputView, configuration: Configuration?) {
        selectConnection(for: stackView, type: .sftp)
        let stackID = stackView.identifier?.rawValue ?? ""
        if stackID == "" { print("### stackID ist empty") }
        
        let layout = [InputItem(label: NSLocalizedString("Host", comment: "Label for host configuration input description."), type: .textfield, inputIdentifier: stackID + ".sftpHost"),
                      InputItem(label: NSLocalizedString("User", comment: "Label for user configuration input description."), type: .textfield, inputIdentifier: stackID + ".sftpUser"),
                      InputItem(label: NSLocalizedString("Password", comment: "Label for password configuration input description."), type: .textfield, inputIdentifier: stackID + ".sftpPassword"),
                      InputItem(label: NSLocalizedString("Path", comment: "Label for path configuration input description."), type: .textfield, inputIdentifier: stackID + ".sftpPath")]
        
        stackView.layout(layout)
        
        // Fill with configuration
        if let conf = configuration {
            if let connection = getConnection(for: stackView, from: conf) as? SFTPConnection {
                if stackView.inputStack.views.count == layout.count {
                    (stackView.inputStack.views[0] as? NSTextField)?.stringValue = connection.host
                    (stackView.inputStack.views[1] as? NSTextField)?.stringValue = connection.user
                    (stackView.inputStack.views[3] as? NSTextField)?.stringValue = connection.path
                    
                    // Set password/keypath textfield
                    switch connection.authentication {
                    case .password(value: let password):
                        (stackView.inputStack.views[2] as? NSTextField)?.stringValue = password
                    case .key(path: let path):
                        (stackView.inputStack.views[2] as? NSTextField)?.stringValue = path
                    }
                }
            }
            ErrorLogger.write(for: conf.id, date: Date(), type: nil, message: "Coulnd't load Configuration, because Connection was not of type \(ConnectionType.sftp.toString()).")
        }
    }
    
    
    /**
     Selects the correct item for one of the connection selectors.
     
     - parameters:
        - stackView: The `StackedInputView`, which determines which connection selector should be set.
        - type: The `ConnectionType`, which determines which item should be selected
     
     Should only be called from the input setup methods.
     */
    private func selectConnection(for stackView: StackedInputView, type: ConnectionType) {
        // Determine correct connection selector
        var connectionSelect: StackedInputView! = connectionSelectLeft
        var connectionChoices = connectionChoicesLeft
        var connectionID = connectionSelectLeftId
        if stackView.identifier?.rawValue ?? "" == stackedInputRightId {
            connectionSelect = connectionSelectRight
            connectionChoices = connectionChoicesRight
            connectionID = connectionSelectRightId
        }
        
        // Select item corresponding to given type on connection selector,
        if let selectIndex = connectionChoices.firstIndex(where: { $0 == type }) {
            if let dropdown = connectionSelect.inputStack.views.first(where: { $0.identifier!.rawValue == connectionID } ) as? NSPopUpButton {
                dropdown.selectItem(at: selectIndex)
            }
        }
    }
    
    
    /**
     Returns either the from or to `Connection`.
     
     - parameters:
        - stackView: The `StackedInputView` instance, which determines, if should return from (left) or to (right)
        - configuration: The `Configuration`, from which the `Connection` is extracted
     */
    func getConnection(for stackView: StackedInputView, from configuration: Configuration) -> Connection {
        var connection = configuration.from
        if stackView.identifier?.rawValue ?? "" == stackedInputRightId {
            connection = configuration.to
        }
        return connection
    }
}




// MARK: - Input Callbacks
extension SyncViewController {
    
    @objc func leftConnectionChanged(_ sender: NSPopUpButton) {
        let type = connectionChoicesLeft[sender.indexOfSelectedItem]
        setupInputs(for: type, configuration: nil, stackView: stackedInputLeft)
    }
    
    
    @objc func rightConnectionChanged(_ sender: NSPopUpButton) {
        let type = connectionChoicesRight[sender.indexOfSelectedItem]
        setupInputs(for: type, configuration: nil, stackView: stackedInputRight)
    }
}
