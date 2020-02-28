//
//  ZyncedUITests.swift
//  ZyncedUITests
//
//  Created by Pascal Braband on 27.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//
//  IMPORTANT: Doesn't work in full screen

import XCTest


class ZyncedUITests: XCTestCase {
    
    let C1F_Path = "C1F_Path"
    let C1T_Host = "C1T_Host"
    let C1T_User = "C1T_User"
    let C1T_Pass = "C1T_Pass"
    let C1T_Path = "C1T_Path"
    
    let C1T_Host_Mod = "C1T_Host_Mod"
    let C1T_User_Mod = "C1T_User_Mod"
    let C1T_Pass_Mod = "C1T_Pass_Mod"
    
    let C2F_Path = "C2F_Path"
    let C2T_Host = "C2T_Host"
    let C2T_User = "C2T_User"
    let C2T_Pass = "C2T_Pass"
    let C2T_Path = "C2T_Path"
    
    let C2T_Host_Mod = "C2T_Host_Mod"
    let C2T_User_Mod = "C2T_User_Mod"
    let C2T_Pass_Mod = "C2T_Pass_Mod"
    
    let C3F_Path = "C3F_Path"
    let C3T_Host = "C3T_Host"
    let C3T_User = "C3T_User"
    let C3T_Pass = "C3T_Pass"
    let C3T_Path = "C3T_Path"
    
    var app: XCUIApplication!
    var window: XCUIElement!
    var itemsTable: XCUIElementQuery!
    
    var localPathTextField: XCUIElement!
    var sftpHostTextField: XCUIElement!
    var sftpUserTextField: XCUIElement!
    var sftpPassTextField: XCUIElement!
    var sftpPathTextField: XCUIElement!

    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // Launch app
        app = XCUIApplication()
        app.launch()
        
        let statusItem = app.children(matching: .menuBar).element(boundBy: 1).children(matching: .statusItem).element
        
        statusItem.click()
        app.menuBars.menuItems["Einstellungen…"].click()

        window = app.windows["Window"]
        itemsTable = app.windows["Window"].tables
        
        // Register Textfields
        localPathTextField = window.textFields["stackedInputLeft.localPath"]
        sftpHostTextField = window.textFields["stackedInputRight.sftpHost"]
        sftpUserTextField = window.textFields["stackedInputRight.sftpUser"]
        sftpPassTextField = window.textFields["stackedInputRight.sftpPassword"]
        sftpPathTextField = window.textFields["stackedInputRight.sftpPath"]

        // Enter data for first configuration
        localPathTextField.click()
        localPathTextField.typeText(C1F_Path)

        sftpHostTextField.click()
        sftpHostTextField.typeText(C1T_Host)

        sftpUserTextField.click()
        sftpUserTextField.typeText(C1T_User)

        sftpPassTextField.click()
        sftpPassTextField.typeText(C1T_Pass)
        
        sftpPathTextField.click()
        sftpPathTextField.typeText(C1T_Path)

        // Save configuration and start new
        window.buttons["Save"].click()
        window.buttons["hinzufügen"].click()

        // Enter data for second configuration
        localPathTextField.click()
        localPathTextField.typeText(C2F_Path)

        sftpHostTextField.click()
        sftpHostTextField.typeText(C2T_Host)

        sftpUserTextField.click()
        sftpUserTextField.typeText(C2T_User)

        sftpPassTextField.click()
        sftpPassTextField.typeText(C2T_Pass)

        sftpPathTextField.click()
        sftpPathTextField.typeText(C2T_Path)

        // Save configuration
        window.buttons["Save"].click()
    }
    

    override func tearDown() {
        // Remove first element
//        itemsTable.children(matching: .tableRow).element(boundBy: 0).children(matching: .cell).element.click()
//        let entfernenButton = window.buttons["entfernen"]
//        entfernenButton.click()
//        let deleteButton = window.sheets["Hinweis"].buttons["Delete"]
//        deleteButton.click()
//
//        // Remove second element
//        itemsTable.tableRows.children(matching: .cell).element.click()
//        entfernenButton.click()
//        deleteButton.click()
        deleteFirstItem()
        deleteFirstItem()
    }

    
    func testChangePasswordClickSave() {
        // Select first element
        itemsTable.children(matching: .tableRow).element(boundBy: 0).children(matching: .cell).element.click()
        
        // Select textfield to change
        sftpPassTextField.click()
        sftpPassTextField.typeKey(.delete, modifierFlags:.command)
        sftpPassTextField.typeText(C1T_Pass_Mod)

        // Save with clicking save button
        window.buttons["Save"].click()
        
        // Test if input fields are correct
        checkC1ModifiedPassword()
        checkC2Normal()
        
        // Check if Keychain Items are correct
        XCTAssertEqual(try KeychainHelper.getItem(user: C1T_User, host: C1T_Host), C1T_Pass_Mod)
        XCTAssertEqual(try KeychainHelper.getItem(user: C2T_User, host: C2T_Host), C2T_Pass)
    }
    
    
    func testChangeUserHostClickSave() {
        // Select first element
        itemsTable.children(matching: .tableRow).element(boundBy: 0).children(matching: .cell).element.click()
        
        // Select textfield to change
        sftpHostTextField.click()
        sftpHostTextField.typeKey(.delete, modifierFlags:.command)
        sftpHostTextField.typeText(C1T_Host_Mod)
        
        sftpUserTextField.click()
        sftpUserTextField.typeKey(.delete, modifierFlags:.command)
        sftpUserTextField.typeText(C1T_User_Mod)

        // Save with clicking save button
        window.buttons["Save"].click()
        
        // Test if input fields are correct
        checkC1ModifiedUserHost()
        checkC2Normal()
        
        // Check if Keychain Items are correct
        do {
            _ = try KeychainHelper.getItem(user: C1T_User, host: C1T_Host)
            XCTFail("Should throw .itemNotFound error.")
        } catch let error {
            XCTAssertEqual((error as! KeychainError), .itemNotFound)
        }
        XCTAssertEqual(try KeychainHelper.getItem(user: C1T_User_Mod, host: C1T_Host_Mod), C1T_Pass)
        XCTAssertEqual(try KeychainHelper.getItem(user: C2T_User, host: C2T_Host), C2T_Pass)
    }
    
    
    func testChangePasswordSelectItemSaveWithDialog() {
        // Select first element
        itemsTable.children(matching: .tableRow).element(boundBy: 0).children(matching: .cell).element.click()
        
        // Select textfield to change
        sftpPassTextField.click()
        sftpPassTextField.typeKey(.delete, modifierFlags:.command)
        sftpPassTextField.typeText(C1T_Pass_Mod)

        // Save with unsaved changes dialog by selecting another element in table
        itemsTable.children(matching: .tableRow).element(boundBy: 1).children(matching: .cell).element.click()
        let saveButton = window.sheets["Hinweis"].buttons["Save"]
        saveButton.click()
        
        // Test if input fields are correct
        checkC1ModifiedPassword()
        checkC2Normal()
        
        // Check if Keychain Items are correct
        XCTAssertEqual(try KeychainHelper.getItem(user: C1T_User, host: C1T_Host), C1T_Pass_Mod)
        XCTAssertEqual(try KeychainHelper.getItem(user: C2T_User, host: C2T_Host), C2T_Pass)
    }
    
    
    func testChangeUserHostSelectItemSaveWithDialog() {
        // Select first element
        itemsTable.children(matching: .tableRow).element(boundBy: 0).children(matching: .cell).element.click()
        
        // Select textfield to change
        sftpHostTextField.click()
        sftpHostTextField.typeKey(.delete, modifierFlags:.command)
        sftpHostTextField.typeText(C1T_Host_Mod)
        
        sftpUserTextField.click()
        sftpUserTextField.typeKey(.delete, modifierFlags:.command)
        sftpUserTextField.typeText(C1T_User_Mod)

        // Save with unsaved changes dialog by selecting another element in table
        itemsTable.children(matching: .tableRow).element(boundBy: 1).children(matching: .cell).element.click()
        let saveButton = window.sheets["Hinweis"].buttons["Save"]
        saveButton.click()
        
        // Test if input fields are correct
        checkC1ModifiedUserHost()
        checkC2Normal()
        
        // Check if Keychain Items are correct
        do {
            _ = try KeychainHelper.getItem(user: C1T_User, host: C1T_Host)
            XCTFail("Should throw .itemNotFound error.")
        } catch let error {
            XCTAssertEqual((error as! KeychainError), .itemNotFound)
        }
        XCTAssertEqual(try KeychainHelper.getItem(user: C1T_User_Mod, host: C1T_Host_Mod), C1T_Pass)
        XCTAssertEqual(try KeychainHelper.getItem(user: C2T_User, host: C2T_Host), C2T_Pass)
    }
    
    
    func testChangePasswordSelectEmptySaveWithDialog() {
        // Select first element
        itemsTable.children(matching: .tableRow).element(boundBy: 0).children(matching: .cell).element.click()
        
        // Select textfield to change
        sftpPassTextField.click()
        sftpPassTextField.typeKey(.delete, modifierFlags:.command)
        sftpPassTextField.typeText(C1T_Pass_Mod)

        // Save with unsaved changes dialog by selecting an empty row in table
        itemsTable.children(matching: .tableRow).element(boundBy: 1).children(matching: .cell).element.click()
        let saveButton = window.sheets["Hinweis"].buttons["Save"]
        saveButton.click()
        
        // Test if input fields are correct
        checkC1ModifiedPassword()
        checkC2Normal()
        
        // Check if Keychain Items are correct
        XCTAssertEqual(try KeychainHelper.getItem(user: C1T_User, host: C1T_Host), C1T_Pass_Mod)
        XCTAssertEqual(try KeychainHelper.getItem(user: C2T_User, host: C2T_Host), C2T_Pass)
    }
    
    
    func testChangeUserHostSelectEmptySaveWithDialog() {
        // Select first element
        itemsTable.children(matching: .tableRow).element(boundBy: 0).children(matching: .cell).element.click()
        
        // Select textfield to change
        sftpHostTextField.click()
        sftpHostTextField.typeKey(.delete, modifierFlags:.command)
        sftpHostTextField.typeText(C1T_Host_Mod)
        
        sftpUserTextField.click()
        sftpUserTextField.typeKey(.delete, modifierFlags:.command)
        sftpUserTextField.typeText(C1T_User_Mod)

        // Save with unsaved changes dialog by selecting an empty row in table
        itemsTable.containing(.tableColumn, identifier:"AutomaticTableColumnIdentifier.0").element.click()
        let saveButton = window.sheets["Hinweis"].buttons["Save"]
        saveButton.click()
        
        // Test if input fields are correct
        checkC1ModifiedUserHost()
        checkC2Normal()
        
        // Check if Keychain Items are correct
        do {
            _ = try KeychainHelper.getItem(user: C1T_User, host: C1T_Host)
            XCTFail("Should throw .itemNotFound error.")
        } catch let error {
            XCTAssertEqual((error as! KeychainError), .itemNotFound)
        }
        XCTAssertEqual(try KeychainHelper.getItem(user: C1T_User_Mod, host: C1T_Host_Mod), C1T_Pass)
        XCTAssertEqual(try KeychainHelper.getItem(user: C2T_User, host: C2T_Host), C2T_Pass)
    }
    
    
    func testAddItemClickSave() {
        addItem()
        
        // Save with clicking save button
        window.buttons["Save"].click()
        
        // Test if input fields are correct
        checkC1Normal()
        checkC2Normal()
        checkC3Normal()
        
        // Check if Keychain Items are correct
        XCTAssertEqual(try KeychainHelper.getItem(user: C1T_User, host: C1T_Host), C1T_Pass)
        XCTAssertEqual(try KeychainHelper.getItem(user: C2T_User, host: C2T_Host), C2T_Pass)
        XCTAssertEqual(try KeychainHelper.getItem(user: C3T_User, host: C3T_Host), C3T_Pass)
        
        // Delete added item for teardown
        deleteFirstItem()
    }
    
    
    func testAddItemSelectItemSaveWithDialog() {
        addItem()
        
        // Save with unsaved changes dialog by selecting another element in table
        itemsTable.children(matching: .tableRow).element(boundBy: 1).children(matching: .cell).element.click()
        let saveButton = window.sheets["Hinweis"].buttons["Save"]
        saveButton.click()
        
        // Test if input fields are correct
        checkC1Normal()
        checkC2Normal()
        checkC3Normal()
        
        // Check if Keychain Items are correct
        XCTAssertEqual(try KeychainHelper.getItem(user: C1T_User, host: C1T_Host), C1T_Pass)
        XCTAssertEqual(try KeychainHelper.getItem(user: C2T_User, host: C2T_Host), C2T_Pass)
        XCTAssertEqual(try KeychainHelper.getItem(user: C3T_User, host: C3T_Host), C3T_Pass)
        
        // Delete added item for teardown
        deleteFirstItem()
    }
    
    
    
    
    // MARK: - Common Actions
    
    func addItem() {
        window.buttons["hinzufügen"].click()
        localPathTextField.click()
        localPathTextField.typeText(C3F_Path)
        sftpHostTextField.click()
        sftpHostTextField.typeText(C3T_Host)
        sftpUserTextField.click()
        sftpUserTextField.typeText(C3T_User)
        sftpPassTextField.click()
        sftpPassTextField.typeText(C3T_Pass)
        sftpPathTextField.click()
        sftpPathTextField.typeText(C3T_Path)
    }
    
    
    func deleteFirstItem() {
        itemsTable.children(matching: .tableRow).element(boundBy: 0).children(matching: .cell).element.click()
        let entfernenButton = window.buttons["entfernen"]
        entfernenButton.click()
        let deleteButton = window.sheets["Hinweis"].buttons["Delete"]
        deleteButton.click()
    }
    
    
    
    
    // MARK: - Checking Inputs
    
    func checkC1Normal() {
        itemsTable.children(matching: .tableRow).element(boundBy: 0).children(matching: .cell).element.click()
        XCTAssertEqual(localPathTextField.value as! String, C1F_Path)
        XCTAssertEqual(sftpHostTextField.value as! String, C1T_Host)
        XCTAssertEqual(sftpUserTextField.value as! String, C1T_User)
        XCTAssertEqual(sftpPassTextField.value as! String, C1T_Pass)
        XCTAssertEqual(sftpPathTextField.value as! String, C1T_Path)
    }
    
    
    func checkC1ModifiedPassword() {
        itemsTable.children(matching: .tableRow).element(boundBy: 0).children(matching: .cell).element.click()
        XCTAssertEqual(localPathTextField.value as! String, C1F_Path)
        XCTAssertEqual(sftpHostTextField.value as! String, C1T_Host)
        XCTAssertEqual(sftpUserTextField.value as! String, C1T_User)
        XCTAssertEqual(sftpPassTextField.value as! String, C1T_Pass_Mod)
        XCTAssertEqual(sftpPathTextField.value as! String, C1T_Path)
    }
    
    
    func checkC1ModifiedUserHost() {
        itemsTable.children(matching: .tableRow).element(boundBy: 0).children(matching: .cell).element.click()
        XCTAssertEqual(localPathTextField.value as! String, C1F_Path)
        XCTAssertEqual(sftpHostTextField.value as! String, C1T_Host_Mod)
        XCTAssertEqual(sftpUserTextField.value as! String, C1T_User_Mod)
        XCTAssertEqual(sftpPassTextField.value as! String, C1T_Pass)
        XCTAssertEqual(sftpPathTextField.value as! String, C1T_Path)
    }
    
    
    func checkC2Normal() {
        itemsTable.children(matching: .tableRow).element(boundBy: 1).children(matching: .cell).element.click()
        XCTAssertEqual(localPathTextField.value as! String, C2F_Path)
        XCTAssertEqual(sftpHostTextField.value as! String, C2T_Host)
        XCTAssertEqual(sftpUserTextField.value as! String, C2T_User)
        XCTAssertEqual(sftpPassTextField.value as! String, C2T_Pass)
        XCTAssertEqual(sftpPathTextField.value as! String, C2T_Path)
    }
    
    
    func checkC2ModifiedPassword() {
        itemsTable.children(matching: .tableRow).element(boundBy: 1).children(matching: .cell).element.click()
        XCTAssertEqual(localPathTextField.value as! String, C2F_Path)
        XCTAssertEqual(sftpHostTextField.value as! String, C2T_Host)
        XCTAssertEqual(sftpUserTextField.value as! String, C2T_User)
        XCTAssertEqual(sftpPassTextField.value as! String, C2T_Pass_Mod)
        XCTAssertEqual(sftpPathTextField.value as! String, C2T_Path)
    }
    
    
    func checkC2ModifiedUserHost() {
        itemsTable.children(matching: .tableRow).element(boundBy: 1).children(matching: .cell).element.click()
        XCTAssertEqual(localPathTextField.value as! String, C2F_Path)
        XCTAssertEqual(sftpHostTextField.value as! String, C2T_Host_Mod)
        XCTAssertEqual(sftpUserTextField.value as! String, C2T_User_Mod)
        XCTAssertEqual(sftpPassTextField.value as! String, C2T_Pass)
        XCTAssertEqual(sftpPathTextField.value as! String, C2T_Path)
    }
    
    func checkC3Normal() {
        itemsTable.children(matching: .tableRow).element(boundBy: 2).children(matching: .cell).element.click()
        XCTAssertEqual(localPathTextField.value as! String, C3F_Path)
        XCTAssertEqual(sftpHostTextField.value as! String, C3T_Host)
        XCTAssertEqual(sftpUserTextField.value as! String, C3T_User)
        XCTAssertEqual(sftpPassTextField.value as! String, C3T_Pass)
        XCTAssertEqual(sftpPathTextField.value as! String, C3T_Path)
    }
}
