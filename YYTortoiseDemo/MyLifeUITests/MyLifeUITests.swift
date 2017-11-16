//
//  MyLifeUITests.swift
//  MyLifeUITests
//
//  Created by NetEase on 2017/11/15.
//  Copyright © 2017年 Apple Inc. All rights reserved.
//

import XCTest
import YYTortoise

class MyLifeUITests: XCTestCase {
        
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
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let application = XCUIApplication()
        
//        let allElements = application.descendants(matching: .any)
//        for i in 0..<allElements.count {
//            let element = allElements.element(boundBy: i)
//            print("*******chouchou\(element.debugDescription)")
//        }
        
        _ = application.descendants(matching: .any).element(boundBy: 0).frame
        
        let tortoise = Tortoise(frame: application.frame)
        tortoise.addDefaultXCTestPrivateActions()
        tortoise.addXCTestTapAlertAction(interval: 100, application: application)
        
        
        
        
        tortoise.addXCTestActiveAppAction(interval: 10, application: application)
        tortoise.addXCTestTapBackAction(interval: 20, application: application)
        
        
        
        
        // Run the monkey test indefinitely.
        //        monkey.monkeyAround()
        // Run the monkey test definitely.
        tortoise.tortoiseAround(iterations: 20)
//        let allElements1 = application.descendants(matching: .any)
//        for i in 0..<allElements.count {
//            let element = allElements1.element(boundBy: i)
//            print("*******chouchou\(element.debugDescription)")
//        }
    }
    
}
