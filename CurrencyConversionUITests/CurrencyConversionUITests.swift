//
//  CurrencyConversionUITests.swift
//  CurrencyConversionUITests
//
//  Created by andrew lattis on 3/5/17.
//  Copyright © 2017 andrew lattis. All rights reserved.
//

import XCTest

class CurrencyConversionUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testFromButton() {
        let app = XCUIApplication()
        app.buttons["fromButton"].tap()
        
        
        let picker = app.pickerWheels.element(boundBy: 0)
        XCTAssertTrue(picker.isHittable)
    }
    
    func testToButton() {
        let app = XCUIApplication()
        app.buttons["toButton"].tap()
        
        
        let picker = app.pickerWheels.element(boundBy: 0)
        XCTAssertTrue(picker.isHittable)
    }

}
