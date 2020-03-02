//
//  ErrorLogViewController.swift
//  Zynced
//
//  Created by Pascal Braband on 29.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import BoteCore

class ErrorLogViewController: NSViewController {
    
    @IBOutlet weak var logTable: NSTableView!
    @IBOutlet weak var scrollView: NSScrollView!
    
    /** The `SyncItem`, for which the error log should be displayed. */
    var syncItem: SyncItem?
    
    /** */
    var itemId: String? {
        return syncItem?.configuration.id
    }
    
    var logData: [ErrorLogItem]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load error log
        if let id = itemId {
            logData = try? ErrorLogger.read(for: id)
        }
        
        // Setup scroll view
        scrollView.documentView?.frame = scrollView.frame
        
        // Setup table
        logTable.delegate = self
        logTable.dataSource = self
        logTable.tableColumns[0].headerCell.stringValue = NSLocalizedString("Date", comment: "Date header title for error log table.")
        logTable.tableColumns[1].headerCell.stringValue = NSLocalizedString("Type", comment: "Type header title for error log table.")
        logTable.tableColumns[2].headerCell.stringValue = NSLocalizedString("Description", comment: "Description header title for error log table.")
        logTable.usesAlternatingRowBackgroundColors = true
        
        // Setup table column widths
        autoSizeTableColumns()
    }
    
    
    // FIXME: REMOVE, only for demo
    override func viewDidAppear() {
        if let id = itemId {
            ErrorLogger.write(for: id, date: Date(), type: ExecutionError.failedCompose("Bla"), message: "Coulnd't load Configuration, because Connection was not of type \(ConnectionType.local.toString()).")
        }
    }
    
    
    @IBAction func closeWindowClicked(_ sender: Any) {
        //self.view.window?.close()
        self.dismiss(self)
    }
    
    
    @IBAction func clearLogClicked(_ sender: Any) {
        if let id = itemId {
            ErrorLogger.clean(for: id)
        }
        logTable.reloadData()
    }
    
    
    func autoSizeTableColumns() {
        for column in 0...logTable.tableColumns.count-1 {
            sizeToFit(column: column, padding: 10.0)
        }
        logTable.reloadData()
    }
    

    func sizeToFit(column: Int, padding: CGFloat) {
        if logTable.numberOfRows > 0 {
            if let view = logTable.view(atColumn: column, row: 0, makeIfNecessary: true) as? NSTableCellView {
                var width = logTable.tableColumns[column].minWidth
                if let data = logData {
                    for item in data {
                        view.textField?.stringValue = getDataFor(item: item, column: column)
                        let size = view.fittingSize
                        width = max(width, size.width + padding)
                    }
                    logTable.tableColumns[column].minWidth = width
                }
            }
        }
    }
    
    
    func getDataFor(item: ErrorLogItem, column: Int) -> String {
        if column == 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS Z"
            return formatter.string(from: item.date)
        } else if column == 1 {
            return item.type
        } else if column == 2 {
            return item.message
        }
        return ""
    }
}




extension ErrorLogViewController: NSTableViewDelegate {
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let data = logData {
            let cell = tableView.makeView(withIdentifier: tableColumn?.identifier ?? .init(rawValue: "cellId-\(row)"), owner: self) as? NSTableCellView
            let item = data[row]
            
            // Get text for cell and assign to textfield
            var text = ""
            if tableColumn == tableView.tableColumns[0] {
                text = getDataFor(item: item, column: 0)
            } else if tableColumn == tableView.tableColumns[1] {
                text = getDataFor(item: item, column: 1)
            } else if tableColumn == tableView.tableColumns[2] {
                text = getDataFor(item: item, column: 2)
            }
            cell?.textField?.stringValue = text
            cell?.textField?.font = NSFont.monospacedSystemFont(ofSize: 12.0, weight: .regular)
            
            return cell
        }
        return nil
    }
    
    
    func tableView(_ tableView: NSTableView, shouldReorderColumn columnIndex: Int, toColumn newColumnIndex: Int) -> Bool {
        return false
    }
}




extension ErrorLogViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        if let id = itemId {
            return (try? ErrorLogger.read(for: id)?.count) ?? 0
        } else {
            return 0
        }
    }
}
