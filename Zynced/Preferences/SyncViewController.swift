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

enum ExecutionError: Error {
    case failedSave, failedCompose(String)
}

class SyncViewController: PreferencesViewController {
    
    // Main views
    @IBOutlet weak var itemsTable: NSTableView!
    @IBOutlet weak var detailContainer: NSView!
    @IBOutlet weak var inputsContainer: ProtectionView!
    
    // Detail view buttons
    @IBOutlet weak var syncDirectionSelector: SyncDirectionSelector!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var startStopButton: NSButton!
    
    // Connection Selectors
    @IBOutlet weak var connectionSelectLeft: StackedInputView!
    @IBOutlet weak var connectionSelectRight: StackedInputView!
    private let connectionSelectLeftId = "connectionSelectLeft"
    private let connectionSelectRightId = "connectionSelectRight"
    
    // Connection info views
    @IBOutlet weak var connectionInfoLeft: ConnectionInfoView!
    @IBOutlet weak var connectionInfoRight: ConnectionInfoView!
    
    /** Saves the `ConnectionType`'s that are available for the left (from) input section. */
    private let connectionChoicesLeft: [ConnectionType] = [ConnectionType.local]
    
    /** Saves the `ConnectionType`'s that are available for the right (to) input section. */
    private let connectionChoicesRight: [ConnectionType] = [ConnectionType.local, ConnectionType.sftp]
    
    // Stacked Inputs
    @IBOutlet weak var stackedInputLeft: StackedInputView!
    @IBOutlet weak var stackedInputRight: StackedInputView!
    let stackedInputLeftId = "stackedInputLeft"
    let stackedInputRightId = "stackedInputRight"
    
    // Detail view header
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var statusIndicator: StatusIndicatorView!
    
    
    /** Keeps track of changes in the input field, after last save. */
    var unsavedChanges = false
    
    /** Saves the subscriptions for status and date for the table items. */
    var subscriptions = [(AnyCancellable, AnyCancellable)]()
    
    /** Saves the status subscription for the item currently displayed in the detail view. */
    var statusSubscription: AnyCancellable?
    
    /** The currently selected `SyncItem` in the table. */
    func currentItem() -> SyncItem?  {
        let index = self.itemsTable.selectedRow
        if isIndexInRange(index) {
            return self.syncOrchestrator?.syncItems[index]
        }
        return nil
    }
    
    /** The previously selected item in the table. */
    var previousItem: SyncItem?
    
    /** Indicates, whether the currently displayed item is synchronizing at the moment. */
    func isCurrentItemSyncing() -> Bool {
        return currentItem()?.status.isRunningStatus() ?? false
    }
    
    
    
    
    // MARK: - View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeAllSubscriptions()
        
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
        
        // Report changes on nameTextField
        nameTextField.delegate = self
        
        // Setup protection for inputs
        inputsContainer.protectedControls = [connectionSelectLeft, connectionSelectRight, stackedInputLeft, stackedInputRight]
        inputsContainer.target = self
        inputsContainer.action = #selector(SyncViewController.showInputProtectionAlert)
    }
    
    
    override func viewDidDisappear() {
        removeAllSubscriptions()
    }
    
    
    override func viewWillAppear() {
        itemsTable.reloadData()
        // Select first item in table when presenting view
        if itemsTable.numberOfRows > 0 {
            itemsTable.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        } else {
            // Show default input fields
            resetDetailView()
        }
    }
    
    
    
    
    // MARK: - Setup/Cleanup methods
    
    func setupConnectionSelect() {
        connectionSelectLeft.layout([InputItem(label: NSLocalizedString("Connection", comment: "Label for connection configuration input description."), type: .dropdown, inputIdentifier: connectionSelectLeftId, selector: #selector(SyncViewController.leftConnectionChanged(_:)), target: self)])
        connectionSelectRight.layout([InputItem(label: NSLocalizedString("Connection", comment: "Label for connection configuration input description."), type: .dropdown, inputIdentifier: connectionSelectRightId, selector: #selector(SyncViewController.rightConnectionChanged(_:)), target: self)])
        
        if let leftDropdown = connectionSelectLeft.inputStack.views.first(where: { $0.identifier!.rawValue == connectionSelectLeftId} ) as? NSPopUpButton {
            leftDropdown.addItems(withTitles: connectionChoicesLeft.map({ $0.toString() }))
        }
        if let rightDropdown = connectionSelectRight.inputStack.views.first(where: { $0.identifier!.rawValue == connectionSelectRightId} ) as? NSPopUpButton {
            rightDropdown.addItems(withTitles: connectionChoicesRight.map({ $0.toString() }))
        }
    }
    
    
    /**
     Cancels and cleans all subscription for whole view controller. **IMPORTATNT:** Use with caution!
     */
    func removeAllSubscriptions() {
        removeTableSubscriptions()
        removeDetailSubscriptions()
    }
    
    
    /**
     Cancels and cleans all subscriptions for the table view.
     */
    func removeTableSubscriptions() {
        // Remove subscriptions for table
        for (statusSub, syncedSub) in subscriptions {
            statusSub.cancel()
            syncedSub.cancel()
        }
        subscriptions.removeAll()
    }
    
    
    /**
    Cancels and cleans all subscriptions for the detail view.
    */
    func removeDetailSubscriptions() {
        statusSubscription?.cancel()
        statusSubscription = nil
    }
    
    
    /**
     Does UI setup for the detail view, with the given `SyncItem`
     */
    func setupDetailView(for item: SyncItem) {
        removeDetailSubscriptions()
        
        // Setup input fields
        setupInputs(for: item.configuration)
        
        // Setup name text field
        nameTextField.stringValue = item.configuration.name
        
        // Setup status subscription (updates status indicator and start/stop button)
        statusSubscription = item.$status.receive(on: OperationQueue.main).sink(receiveValue: { (status) in
            self.statusIndicator.update(status: status)
            self.updateStartStopButton(status: status)
            self.updateInputProtection(status: status)
        })
        
        // Setup connection info
        updateConnectionInfo()
        
        startStopButton.isEnabled = true
        self.view.window?.recalculateKeyViewLoop()
    }
    
    
    /**
     Resets the detail view to default input fields
     */
    func resetDetailView() {
        removeDetailSubscriptions()
        
        setupInputsDefault()
        nameTextField.stringValue = NSLocalizedString("Default Configuration Name", comment: "The default title presented in a configuration.")
        statusIndicator.update(status: .inactive)
        updateStartStopButton(status: .inactive)
        startStopButton.isEnabled = false
        inputsContainer.disableProtection()
        resetConnectionInfo()

        self.view.window?.recalculateKeyViewLoop()
    }
    
    
    
    
    // MARK: - IBOutlet modification
    
    func updateStartStopButton(status: SyncStatus) {
        if status.isRunningStatus() {
            setButtonStop()
        } else {
            setButtonStart()
        }
    }
    
    
    func setButtonStart() {
        startStopButton.title = NSLocalizedString("Start", comment: "Stop title for the Start/Stop button.")
        startStopButton.keyEquivalent = "\r"
    }
    
    
    func setButtonStop() {
        startStopButton.title = NSLocalizedString("Stop", comment: "Stop title for the Start/Stop button.")
        startStopButton.keyEquivalent = ""
    }
    
    
    func updateInputProtection(status: SyncStatus) {
        if status.isRunningStatus() {
            inputsContainer.enableProtection()
        } else {
            inputsContainer.disableProtection()
        }
    }
    
    
    func updateConnectionInfo() {
        connectionInfoLeft.update(with: currentItem()?.configuration.from)
        connectionInfoRight.update(with: currentItem()?.configuration.to)
    }
    
    
    func resetConnectionInfo() {
        connectionInfoLeft.update(with: nil)
        connectionInfoRight.update(with: nil)
    }
    
    
    func updateUIAfterSave() {
        reloadTable()
        updateConnectionInfo()
    }
    
    
    
    
    // MARK: - IBActions/UI Actions
    
    @IBAction func addItem(_ sender: Any) {
        checkForUnsavedChanges(currentItem: self.currentItem()) {
            // Deselect row in table, this will also update the detail view
            self.itemsTable.deselectAll(self)
        }
    }
    
    
    @IBAction func deleteItem(_ sender: Any) {
        deleteDialog()
    }
    
    
    @IBAction func showErrorLog(_ sender: NSButton) {
        performSegue(withIdentifier: "ErrorLogSegue", sender: self)
    }
    
    
    @IBAction func saveClicked(_ sender: NSButton) {
        save(overrideItem: self.currentItem())
    }
    
    
    @IBAction func startStopSyncClicked(_ sender: NSButton) {
        // Start/stop sync for current item
        if let currentItem = self.currentItem() {
            if isCurrentItemSyncing() {
                // Stop synchronization
                syncOrchestrator?.stopSynchronizing(for: currentItem)
                setButtonStart()
            } else {
                // Check if there are any unsaved changes and present unsaved changes dialog first
                checkForUnsavedChanges(currentItem: currentItem) {
                    // Try to start synchronization and write any errors to ErrorLogger
                    do {
                        try self.syncOrchestrator?.startSynchronizing(for: currentItem, errorHandler: { (item, error) in
                            ErrorLogger.write(for: item.configuration.id, date: Date(), type: error, message: error.localizedDescription)
                        })
                        self.setButtonStop()
                    } catch let error {
                        ErrorLogger.write(for: currentItem.configuration.id, date: Date(), type: error, message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "ErrorLogSegue" {
            let vc = segue.destinationController as! ErrorLogViewController
            vc.syncItem = currentItem()
        }
    }
    
    
    /** Indicates whether the input protection alert is currently displayed. */
    var isInputProtectionAlertDisplayed = false
    
    /** Presents the input protection alert. */
    @objc func showInputProtectionAlert() {
        if !isInputProtectionAlertDisplayed {
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("Input Protection Warning", comment: "Alert message telling that input is disabled.")
            alert.informativeText = NSLocalizedString("Input Protection Warning Text", comment: "Alert text telling that input is disabled.")
            alert.alertStyle = NSAlert.Style.warning
            alert.addButton(withTitle: NSLocalizedString("OK", comment: "Title for ok button."))
            if let window = self.view.window {
                isInputProtectionAlertDisplayed = true
                alert.beginSheetModal(for: window) { (response) in
                    self.isInputProtectionAlertDisplayed = false
                }
            }
        }
    }
    
    
    
    
    // MARK: - Save/Delete
    
    /**
     Saves a `Configuration` based on the data, that is currently in the input fields.
     
     - parameters:
        - configuration: The `Configuration`, which should be saved.
        - overrideItem: An optional `SyncItem`. If provided, this item will be overriden by the new data.
     */
    func save(overrideItem: SyncItem?) {
        do {
            unsavedChanges = false
            
            var overrideConfiguration = overrideItem?.configuration
            guard var configuration = composeConfiguration(from: &overrideConfiguration) else { throw ExecutionError.failedSave }
            
            let isNewConfiguration = overrideItem == nil
            
            if isNewConfiguration {
                // Create new item otherwise
                try configManager?.add(configuration)
                _ = try syncOrchestrator?.register(configuration: configuration)
            } else {
                // Override: Important to call update before, because it also sets the correct id for the new Configuration
                try configManager?.update(&configuration, for: overrideItem!.configuration.id)
                overrideItem!.configuration = configuration
            }
            
            // Update UI
            updateUIAfterSave()
            
            // Select last item in table, if new item was created
            if isNewConfiguration {
                itemsTable.selectRowIndexes(IndexSet(integer: itemsTable.numberOfRows-1), byExtendingSelection: false)
            }
            
        } catch let error {
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("Save Failed", comment: "Alert message telling that saving failed.")
            alert.informativeText = NSLocalizedString("Save Failed Text", comment: "Alert text telling that saving failed.")
            alert.alertStyle = NSAlert.Style.warning
            alert.addButton(withTitle: NSLocalizedString("OK", comment: "Title for ok button."))
            if let window = self.view.window {
                alert.beginSheetModal(for: window, completionHandler: nil)
            }
            ErrorLogger.writeDefault(date: Date(), type: error, message: error.localizedDescription)
        }
    }
    
    
    /**
     Composes a `Configuration` object using the data, that is currently in the input fields.
     */
    func composeConfiguration(from current: inout Configuration?) -> Configuration? {
        // Create Configuration from input labels
        guard let leftDropdown = connectionSelectLeft.inputStack.views.first(where: { $0.identifier!.rawValue == connectionSelectLeftId} ) as? NSPopUpButton else { return nil }
        let typeFrom = connectionChoicesLeft[leftDropdown.indexOfSelectedItem]
        var currentFrom = current?.from
        let fromConnection = try? createConnection(type: typeFrom, override: &currentFrom, stackView: stackedInputLeft)
        
        guard let rightDropdown = connectionSelectRight.inputStack.views.first(where: { $0.identifier!.rawValue == connectionSelectRightId} ) as? NSPopUpButton else { return nil }
        let typeTo = connectionChoicesRight[rightDropdown.indexOfSelectedItem]
        var currentTo = current?.to
        let toConnection = try? createConnection(type: typeTo, override: &currentTo, stackView: stackedInputRight)
        
        if fromConnection != nil && toConnection != nil {
            return Configuration(from: fromConnection!, to: toConnection!, name: nameTextField.stringValue)
        } else {
            return nil
        }
    }
    
    
    /**
     Creates a connection for a given type using the input fields from the stackView.
     
     - parameters:
        - type: The `ConnectionType`, that should be created.
        - override: A `Connection` object, which will be updated if given. If this parameter is given, a new `Connection` is not created but instead is the `override` object updated and returned.
        - stackView: The `StackedInputView` which input fields should be use to create/update the `Connection`.
     */
    func createConnection(type: ConnectionType, override: inout Connection?, stackView: StackedInputView) throws -> Connection {
        let inputs = stackView.inputStack.views
        if override == nil || type != override?.type {
            // Create new connection
            switch type {
            case .local:
                return LocalConnection(path: (inputs[0] as! PathInputField).stringValue)
            case .sftp:
                return try SFTPConnection(path: (inputs[3] as! PathInputField).stringValue,
                                          host: (inputs[0] as! NSTextField).stringValue,
                                          port: nil,
                                          user: (inputs[1] as! NSTextField).stringValue,
                                          authentication: .password(value: (inputs[2] as! NSTextField).stringValue))
            }
        } else {
            // Update override connection
            switch type {
            case .local:
                if let localConnection = override as? LocalConnection {
                    localConnection.path = (inputs[0] as! PathInputField).stringValue
                    return localConnection
                } else { throw ExecutionError.failedCompose("While updating a Connection from user inputs, the given type \(type) and the type \(String(describing: override?.type)) of the existing Connection didn't match") }
            case .sftp:
                if let sftpConnection = override as? SFTPConnection {
                    sftpConnection.path = (inputs[3] as! PathInputField).stringValue
                    try sftpConnection.setHost((inputs[0] as! NSTextField).stringValue)
                    try sftpConnection.setUser((inputs[1] as! NSTextField).stringValue)
                    try sftpConnection.setAuthentication(.password(value: (inputs[2] as! NSTextField).stringValue))
                    return sftpConnection
                } else { throw ExecutionError.failedCompose("While updating a Connection from user inputs, the given type \(type) and the type \(String(describing: override?.type)) of the existing Connection didn't match") }
            }
        }
    }
    
    
    /**
     Presents delete dialog and performs deletion if the user asks to do so.
     */
    func deleteDialog() {
        if itemsTable.selectedRow > -1 {
            // Alert: Ask if user really wants to delete
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("Delete Confimation", comment: "Alert message asking for delete confirmation.")
            alert.informativeText = NSLocalizedString("Delete Confirmation Text", comment: "Alert text asking for delete confirmation.")
            alert.alertStyle = NSAlert.Style.warning
            alert.addButton(withTitle: NSLocalizedString("Delete", comment: "Title for delete button."))
            alert.addButton(withTitle: NSLocalizedString("Cancel", comment: "Title for cancel button."))
            if let window = self.view.window {
                alert.beginSheetModal(for: window) { (response) in
                    if response == .alertFirstButtonReturn {
                        self.delete(configuration: self.currentItem()?.configuration)
                    }
                }
            }
        } else {
            // Alert: No item selected
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("No Item Selected", comment: "Alert message telling that no item was selected.")
            alert.informativeText = NSLocalizedString("No Item Selected Text", comment: "Alert text telling that no item was selected.")
            alert.alertStyle = NSAlert.Style.warning
            alert.addButton(withTitle: NSLocalizedString("OK", comment: "Title for ok button."))
            if let window = self.view.window {
                alert.beginSheetModal(for: window, completionHandler: nil)
            }
        }
    }
    
    
    func delete(configuration: Configuration?) {
        if let currentConfiguration = configuration {
            do {
                syncOrchestrator?.unregister(configuration: currentConfiguration)
                try configManager?.remove(id: currentConfiguration.id)
                reloadTable()
                
                // If the last item was deleted, show default inputs
                if syncOrchestrator?.syncItems.count ?? 0 <= 0 {
                    resetDetailView()
                }
            } catch let error {
                let alert = NSAlert()
                alert.messageText = NSLocalizedString("Delete Failed", comment: "Alert message telling that deleting failed.")
                alert.informativeText = NSLocalizedString("Delete Failed Text", comment: "Alert text telling that deleting failed.")
                alert.alertStyle = NSAlert.Style.warning
                alert.addButton(withTitle: NSLocalizedString("OK", comment: "Title for ok button."))
                if let window = self.view.window {
                    alert.beginSheetModal(for: window, completionHandler: nil)
                }
                ErrorLogger.writeDefault(date: Date(), type: error, message: error.localizedDescription)
            }
        }
    }
    
    
    /** Discards changes for the current item. */
    func discardChanges() {
        unsavedChanges = false
        
        // Reset inputs. Only needed, when detail view stays on the same item as before discard was called.
        if let current = currentItem(),
            previousItem?.configuration.id == current.configuration.id {
            setupDetailView(for: current)
        }
    }
    
    
    /**
     Checks if there are unsaved changes. If so, then presents user an alert, asking if the changes should be saved or discarded. The requested action is then performed.
     */
    func checkForUnsavedChanges(currentItem: SyncItem?, completion: @escaping () -> ()) {
        if unsavedChanges {            
            // Present dialog
            saveUnsavedChanges { (saveChanges) in
                // Save changes if result is true
                if saveChanges {
                    self.save(overrideItem: currentItem)
                }
                // Discard
                else {
                    self.discardChanges()
                }
                // Call completion when finished
                completion()
            }
        } else {
            completion()
        }
        
    }
    
    
    /**
     Presents alert, asking if changes should be discarded.
     
     - returns:
     `true` if changes should be saved, and `false` if they should be discarded.
     */
    func saveUnsavedChanges(completion: @escaping (Bool) -> ()) {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Unsaved Changes", comment: "Alert message aksing what to do with unsaved changes.")
        alert.informativeText = NSLocalizedString("Unsaved Changes Text", comment: "Alert text aksing what to do with unsaved changes.")
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: NSLocalizedString("Save", comment: "Title for save button."))
        alert.addButton(withTitle: NSLocalizedString("Discard", comment: "Title for no button."))
        if let window = self.view.window {
            alert.beginSheetModal(for: window) { (response) in
                if response == .alertFirstButtonReturn {
                    completion(true)
                } else if response == .alertSecondButtonReturn {
                    completion(false)
                }
            }
        }
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
            
            let statusSub = item.$status.receive(on: OperationQueue.main).sink { (newStatus) in
                infoView.setStatus(newStatus)
            }
            let syncedSub = item.$lastSynced.receive(on: OperationQueue.main).sink { (newSyncDate) in
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
            // Update detail view
            // Check if selection changed to an item in the syncItems array
            let currentItem = previousItem
            checkForUnsavedChanges(currentItem: currentItem) {
                if self.isIndexInRange(tableview.selectedRow) {
                    if let item = self.syncOrchestrator?.syncItems[tableview.selectedRow] {
                        // Setup detail view for the selected SyncItem
                        self.setupDetailView(for: item)
                    }
                } else {
                    // Setup inputs for creating new Configuration
                    self.resetDetailView()
                }
                
                self.previousItem = self.currentItem()
            }
        }
        
    }
    
    
    func reloadTable() {
        let selectedRow = itemsTable.selectedRow
        removeTableSubscriptions()
        itemsTable.reloadData()
        if itemsTable.numberOfRows > 0 {
            itemsTable.selectRowIndexes(IndexSet(integer: selectedRow), byExtendingSelection: false)
        }
    }
    
    
    func isIndexInRange(_ index: Int) -> Bool {
        return index >= 0 && index < syncOrchestrator?.syncItems.count ?? 0
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
        
        let layout = [InputItem(label: NSLocalizedString("Path", comment: "Label for path configuration input description."), placeholder: NSLocalizedString("Path Placeholder", comment: "Placeholder for path configuration input."), type: .filetextfield, inputIdentifier: stackID + ".localPath", selector: #selector(SyncViewController.didChangeInput(_:)), target: self)]
        
        stackView.layout(layout)
        
        // Fill with configuration
        if let conf = configuration {
            if let connection = getConnection(for: stackView, from: conf) as? LocalConnection {
                if stackView.inputStack.views.count == layout.count {
                    (stackView.inputStack.views[0] as? PathInputField)?.stringValue = connection.path
                }
            } else {
                ErrorLogger.write(for: conf.id, date: Date(), type: nil, message: "Coulnd't load Configuration, because Connection was not of type \(ConnectionType.local.toString()).")
            }
        }
        
        // Recalculate keyViewLoop
        self.view.window?.recalculateKeyViewLoop()
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
        
        let layout = [InputItem(label: NSLocalizedString("Host", comment: "Label for host configuration input description."), placeholder: NSLocalizedString("Host Placeholder", comment: "Placeholder for host configuration input."), type: .textfield, inputIdentifier: stackID + ".sftpHost", selector: #selector(SyncViewController.didChangeInput(_:)), target: self),
                      InputItem(label: NSLocalizedString("User", comment: "Label for user configuration input description."), placeholder: NSLocalizedString("User Placeholder", comment: "Placeholder for user configuration input."), type: .textfield, inputIdentifier: stackID + ".sftpUser", selector: #selector(SyncViewController.didChangeInput(_:)), target: self),
                      InputItem(label: NSLocalizedString("Password", comment: "Label for password configuration input description."), placeholder: NSLocalizedString("Password Placeholder", comment: "Placeholder for password configuration input."), type: .textfield, inputIdentifier: stackID + ".sftpPassword", selector: #selector(SyncViewController.didChangeInput(_:)), target: self),
                      InputItem(label: NSLocalizedString("Path", comment: "Label for path configuration input description."), placeholder: NSLocalizedString("Path Placeholder", comment: "Placeholder for path configuration input."), type: .filetextfield, inputIdentifier: stackID + ".sftpPath", selector: #selector(SyncViewController.didChangeInput(_:)), target: self)]
        
        stackView.layout(layout)
        
        // Fill with configuration
        if let conf = configuration {
            if let connection = getConnection(for: stackView, from: conf) as? SFTPConnection {
                if stackView.inputStack.views.count == layout.count {
                    (stackView.inputStack.views[0] as? NSTextField)?.stringValue = connection.host
                    (stackView.inputStack.views[1] as? NSTextField)?.stringValue = connection.user
                    (stackView.inputStack.views[3] as? PathInputField)?.stringValue = connection.path
                    
                    // Set password/keypath textfield
                    switch connection.authentication {
                    case .password(value: _):
                        (stackView.inputStack.views[2] as? NSTextField)?.stringValue = (try? connection.getPassword()) ?? ""
                    case .key(path: _):
                        (stackView.inputStack.views[2] as? NSTextField)?.stringValue = connection.getKeyPath() ?? ""
                    }
                }
            } else {
                ErrorLogger.write(for: conf.id, date: Date(), type: nil, message: "Coulnd't load Configuration, because Connection was not of type \(ConnectionType.sftp.toString()).")
            }
        }
        
        // Recalculate keyViewLoop
        self.view.window?.recalculateKeyViewLoop()
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
     Returns either the `from` or `to` `Connection`.
     
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
        unsavedChanges = true
    }
    
    
    @objc func rightConnectionChanged(_ sender: NSPopUpButton) {
        let type = connectionChoicesRight[sender.indexOfSelectedItem]
        setupInputs(for: type, configuration: nil, stackView: stackedInputRight)
        unsavedChanges = true
    }
    
    
    @objc func didChangeInput(_ sender: Any) {
        unsavedChanges = true
    }
}




// MARK: - NSTextFieldDelegate
extension SyncViewController: NSTextFieldDelegate {

    func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            didChangeInput(textField)
        }
    }
}
