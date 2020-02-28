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
    
    let C2F_Path = "C2F_Path"
    let C2T_Host = "C2T_Host"
    let C2T_User = "C2T_User"
    let C2T_Pass = "C2T_Pass"
    let C2T_Path = "C2T_Path"
    
    var app: XCUIApplication!

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

        let window = app.windows["Window"]

        // Enter data for first configuration
        let stackedinputleftLocalpathTextField = window.textFields["stackedInputLeft.localPath"]
        stackedinputleftLocalpathTextField.click()
        stackedinputleftLocalpathTextField.typeText(C1F_Path)

        let stackedinputrightSftphostTextField = window.textFields["stackedInputRight.sftpHost"]
        stackedinputrightSftphostTextField.click()
        stackedinputrightSftphostTextField.typeText(C1T_Host)

        let stackedinputrightSftpuserTextField = window.textFields["stackedInputRight.sftpUser"]
        stackedinputrightSftpuserTextField.click()
        stackedinputrightSftpuserTextField.typeText(C1T_User)

        let stackedinputrightSftppasswordTextField = window.textFields["stackedInputRight.sftpPassword"]
        stackedinputrightSftppasswordTextField.click()
        stackedinputrightSftppasswordTextField.typeText(C1T_Pass)

        let stackedinputrightSftppathTextField = window.textFields["stackedInputRight.sftpPath"]
        stackedinputrightSftppathTextField.click()
        stackedinputrightSftppathTextField.typeText(C1T_Path)

        // Save configuration and start new
        window.buttons["Save"].click()
        window.buttons["hinzufügen"].click()

        // Enter data for second configuration
        stackedinputleftLocalpathTextField.click()
        stackedinputleftLocalpathTextField.typeText(C2F_Path)

        stackedinputrightSftphostTextField.click()
        stackedinputrightSftphostTextField.typeText(C2T_Host)

        stackedinputrightSftpuserTextField.click()
        stackedinputrightSftpuserTextField.typeText(C2T_User)

        stackedinputrightSftppasswordTextField.click()
        stackedinputrightSftppasswordTextField.typeText(C2T_Pass)

        stackedinputrightSftppathTextField.click()
        stackedinputrightSftppathTextField.typeText(C2T_Path)

        // Save configuration
        window.buttons["Save"].click()
    }

    override func tearDown() {
        app.children(matching: .menuBar).element(boundBy: 1).children(matching: .statusItem).element.click()
        app.menuBars.menuItems["Einstellungen…"].click()

        let window = app.windows["Window"]
        let tablesQuery = app.windows["Window"].tables

        // Remove first element
        tablesQuery.children(matching: .tableRow).element(boundBy: 0).children(matching: .cell).element.click()
        let entfernenButton = window.buttons["entfernen"]
        entfernenButton.click()
        let deleteButton = window.sheets["Hinweis"].buttons["Delete"]
        deleteButton.click()
        
        // Remove second element
        tablesQuery.tableRows.children(matching: .cell).element.click()
        entfernenButton.click()
        deleteButton.click()
    }

    func testExample() {
        // UI tests must launch the application that they test.
                
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
