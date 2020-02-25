//
//  ErrorLoggerTests.swift
//  ErrorLoggerTests
//
//  Created by Pascal Braband on 18.02.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import XCTest
@testable import Zynced
import BoteCore

class ErrorLoggerTests: XCTestCase {
    
    
    let uuid1 = "5222489D-5931-42EF-951A-BA64BF84FD51"
    let uuid2 = "D6E2CC60-428D-4B54-B337-470960D33179"
    let uuid3 = "36DB30B9-F919-4C70-B1C3-D0FCD64971BA"
    
    enum DemoError: Error {
        case runtime, compile, other
    }

    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        ErrorLogger.removeAll()
    }

    func testWriteReadClean() throws {
        let errorDate1 = Date()
        let errorType1 = DemoError.runtime
        let errorMessage1 = "This is an error message1"
        ErrorLogger.write(for: uuid1, date: errorDate1, type: errorType1, message: errorMessage1)
        let error1 = ErrorLogItem(date: errorDate1, type: String(describing: type(of: errorType1)) + "." + String(describing: errorType1.self), message: errorMessage1)
        
        let errorDate2 = Date()
        let errorType2 = DemoError.compile
        let errorMessage2 = "This is an error messag2"
        ErrorLogger.write(for: uuid1, date: errorDate2, type: errorType2, message: errorMessage2)
        let error2 = ErrorLogItem(date: errorDate2, type: String(describing: type(of: errorType2)) + "." + String(describing: errorType2.self), message: errorMessage2)
        
        let errorDate3 = Date()
        let errorType3 = DemoError.other
        let errorMessage3 = "This is an error message3"
        ErrorLogger.write(for: uuid2, date: errorDate3, type: errorType3, message: errorMessage3)
        let error3 = ErrorLogItem(date: errorDate3, type: String(describing: type(of: errorType3)) + "." + String(describing: errorType3.self), message: errorMessage3)
        
        // Test if everything was written correctly
        XCTAssertEqual(try ErrorLogger.read(for: uuid1), [error1, error2])
        XCTAssertEqual(try ErrorLogger.read(for: uuid2), [error3])
        XCTAssertEqual(try ErrorLogger.read(for: uuid3), nil)
        
        // Clean
        ErrorLogger.clean(for: uuid1)
        XCTAssertEqual(try ErrorLogger.read(for: uuid1), nil)
        XCTAssertEqual(try ErrorLogger.read(for: uuid2), [error3])
        XCTAssertEqual(try ErrorLogger.read(for: uuid3), nil)
        
        ErrorLogger.clean(for: uuid2)
        XCTAssertEqual(try ErrorLogger.read(for: uuid1), nil)
        XCTAssertEqual(try ErrorLogger.read(for: uuid2), nil)
        XCTAssertEqual(try ErrorLogger.read(for: uuid3), nil)
    }

    
    func testReadErrors() throws {
        //dump(try ErrorLogger.readAll())
        print(try ErrorLogger.readAll() as AnyObject)
    }
}
