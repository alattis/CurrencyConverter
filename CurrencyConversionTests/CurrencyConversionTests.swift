//
//  CurrencyConversionTests.swift
//  CurrencyConversionTests
//
//  Created by andrew lattis on 3/2/17.
//  Copyright © 2017 andrew lattis. All rights reserved.
//

import XCTest
@testable import CurrencyConversion

class CurrencyConversionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        ConversionManager.shared.refreshRates()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    func testValidJson() {
        let validJson = "{\"base\":\"USD\",\"date\":\"2017-03-03\",\"rates\":{\"AUD\":1.321,\"BGN\":1.8512}}"
        let jsonData = validJson.data(using: .utf8)
        
        XCTAssertTrue(ConversionManager.shared.parseRateJson(jsonData:jsonData!))
    }

    func testInvalidJson() {
        let validJson = "{\"date\":\"2017-03-03\",\"rates\":{\"AUD\":1.321,\"BGN\":1.8512}}"
        let jsonData = validJson.data(using: .utf8)
        
        XCTAssertFalse(ConversionManager.shared.parseRateJson(jsonData:jsonData!))
    }

    
    func testBrokenJson() {
        let validJson = "{\"date\":\"2017-03-03\",\"rates\":"
        let jsonData = validJson.data(using: .utf8)
        
        XCTAssertFalse(ConversionManager.shared.parseRateJson(jsonData:jsonData!))
    }

    
    func testValidConversion() {
        let validJson = "{\"base\":\"USD\",\"date\":\"2017-03-03\",\"rates\":{\"AUD\":1.321,\"BGN\":1.8512}}"
        let jsonData = validJson.data(using: .utf8)
        
        XCTAssertTrue(ConversionManager.shared.parseRateJson(jsonData:jsonData!))

        XCTAssertEqual(ConversionManager.shared.convert(amount: 3.0, from: "USD", to: "AUD"), 3.96299982)
    }
    
    func testMissingToConversion() {
        let validJson = "{\"base\":\"USD\",\"date\":\"2017-03-03\",\"rates\":{\"AUD\":1.321,\"BGN\":1.8512}}"
        let jsonData = validJson.data(using: .utf8)
        
        XCTAssertTrue(ConversionManager.shared.parseRateJson(jsonData:jsonData!))
        
        XCTAssertEqual(ConversionManager.shared.convert(amount: 3.0, from: "USD", to: "ABC"), -1.0)
    }

    func testMissingFromConversion() {
        let validJson = "{\"base\":\"USD\",\"date\":\"2017-03-03\",\"rates\":{\"AUD\":1.321,\"BGN\":1.8512}}"
        let jsonData = validJson.data(using: .utf8)
        
        XCTAssertTrue(ConversionManager.shared.parseRateJson(jsonData:jsonData!))
        
        XCTAssertEqual(ConversionManager.shared.convert(amount: 3.0, from: "ABC", to: "USD"), -1.0)
    }

}
