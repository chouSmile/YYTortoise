//
//  XCUIElement+ForceTap.swift
//  YYTortoise
//
//  Created by 自由作家 on 2017/11/16.
//  Copyright © 2017年 YY. All rights reserved.
//

import Foundation
import XCTest

/*Sends a tap event to a hittable/unhittable element.*/
@available(iOS 9.0, *)
extension XCUIElement {
    func forceTapElement() {
        if self.isHittable {
            self.tap()
        }
        else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx:0.0, dy:0.0))
            coordinate.tap()
        }
    }
}



//test to  chouchou
//hello,beauty.
