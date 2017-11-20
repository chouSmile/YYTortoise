//
//  TortoiseXCTest.swift
//  YYTortoise
//
//  Created by NetEase on 2017/11/15.
//  Copyright © 2017年 YY. All rights reserved.
//

import Foundation
import XCTest

/**
 Extension using the public XCTest API to generate
 events.
 */
@available(iOS 9.0, *)
extension Tortoise {
    
    /**
     Add an action that checks, at a fixed interval,
     if an alert is being displayed, and if so, selects
     a random button on it.
     
     - parameter interval: How often to generate this
     event. One of these events will be generated after
     this many randomised events have been generated.
     - parameter application: The `XCUIApplication` object
     for the current application.
     */
    public func addXCTestTapAlertAction(interval: Int, application: XCUIApplication) {
        addAction(interval: interval) { [weak self] in
            // The test for alerts on screen and dismiss them if there are any.
            for i in 0 ..< application.alerts.count {
                let alert = application.alerts.element(boundBy: i)
                let buttons = alert.descendants(matching: .button)
                XCTAssertNotEqual(buttons.count, 0, "No buttons in alert")
                let index = UInt(self!.r.randomUInt32() % UInt32(buttons.count))
                let button = buttons.element(boundBy: index)
                button.tap()
            }
        }
    }
    
    /**
     Add an action that checks, at a fixed interval,
     if app is run in background, active app.
     if app is not running at all, launch app.
     
     - parameter interval: How often to generate this
     event. One of these events will be generated after
     this many randomised events have been generated.
     - parameter application: The `XCUIApplication` object
     for the current application.
     */
    public func addXCTestActiveAppAction(interval: Int, application: XCUIApplication) {
        addAction(interval: interval) {
            // active app if the test app is not running foreground.
            //2:runningBackgroundSuspended; 3:runningBackground
            if(application.state.rawValue == 2 || application.state.rawValue == 3)
            {
                application.activate()
            }
            //0:unknown; 1:notRunning
            if (application.state.rawValue == 0 || application.state.rawValue == 1 )
            {
                application.launch()
            }
        }
    }
    
   /**
     Add an action that checks, at a fixed interval,
     back to the last page.
     
     - parameter interval: How often to generate this
     event. One of these events will be generated after
     this many randomised events have been generated.
     - parameter application: The `XCUIApplication` object
     for the current application.
     */
    public func addXCTestTapBackAction(interval: Int, application: XCUIApplication){
        addAction(interval: interval){
            // back to the last page.
            let backButtonList = ["back","back ic normal","whitetheme back ic nor","lightyellowtheme back ic nor","greentheme back ic nor","graytheme back ic nor","darkyellowtheme back ic nor","darktheme back ic nor","top cancel ic normal"]
            let allButton = application.descendants(matching: XCUIElementType.button)
            for i in 0 ..< allButton.count {
                let button = allButton.element(boundBy: i)
                print("tu button title",button.label)
                if backButtonList.contains(button.label) {
                    button.forceTapElement()
                    break
                }
            }
        }
    }
    
    
    
    
}
