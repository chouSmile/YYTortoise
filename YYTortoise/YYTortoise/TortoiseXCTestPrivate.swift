//
//  TortoiseXCTestPrivate.swift
//  YYTortoise
//
//  Created by NetEase on 2017/11/15.
//  Copyright © 2017年 YY. All rights reserved.
//

import UIKit
import XCTest

var orientationValue: UIDeviceOrientation = .portrait

/**
 Extension using private funcctions from the XCTest API
 to generate events.
 
 The public XCTest API is far too slow for useful random testing,
 so currently using private APIs is the only option.
 
 As this code is only used in your tests, and never
 distributed, it will not cause problems with App Store
 approval.
 */
extension Tortoise {
    private var sharedXCEventGenerator: XCEventGenerator {
        let generatorClass = unsafeBitCast(NSClassFromString("XCEventGenerator"),to: XCEventGenerator.Type.self)
        return generatorClass.sharedGenerator()
    }
    
    /**
     Add a sane default set of event generation actions
     using the private XCTest API. Use this function if you
     just want to generate some events, and do not have
     strong requirements on exactly which ones you need.
     */
    public func addDefaultXCTestPrivateActions() {
        addXCTestTapAction(weight: 25)
        addXCTestLongPressAction(weight: 1)
        addXCTestDragAction(weight: 1)
        addXCTestPinchCloseAction(weight: 1)
        addXCTestPinchOpenAction(weight: 1)
        addXCTestRotateAction(weight: 1)
        //addXCTestOrientationAction(weight: 1) // TODO: Investigate why this does not work.
    }
    
    public func addPlayXCTestPrivateActions(trackActions: [NSDictionary]) {
        for action in trackActions {
            print("*** test ***: \(action)")
            print("*** test ***: \(type(of: action))")
            switch action["type"] as! String {
            case "tap":
                let locs: (Double, Double) = action["locations"] as! (Double, Double)
                let locsPoint = CGPoint(x:locs.0, y:locs.1)
                addPlayXCTestTapAction(locations: [locsPoint], numbersOfTaps: action["numbersOfTaps"] as! UInt)
            case "LongPress":
                let locs: (Double, Double) = action["location"] as! (Double, Double)
                let locsPoint = CGPoint(x:locs.0, y:locs.1)
                addPlayXCTestLongPressAction(location: locsPoint)
            case "Drag":
                let start: (Double, Double) = action["start"] as! (Double, Double)
                let startPoint = CGPoint(x:start.0, y:start.1)
                let end: (Double, Double) = action["end"] as! (Double, Double)
                let endPoint = CGPoint(x:end.0, y:end.1)
                addPlayXCTestDragAction(start: startPoint, end: endPoint)
            case "PinchOpen":
                let tuple: (CGFloat, CGFloat, CGFloat, CGFloat) = action["rect"] as! (CGFloat, CGFloat, CGFloat, CGFloat)
                let rect = CGRect(x: tuple.0, y: tuple.1, width: tuple.2, height: tuple.3)
                addPlayXCTestPinchOpenAction(rect: rect, scale: action["scale"] as! CGFloat)
            case "PinchClose":
                let tuple: (CGFloat, CGFloat, CGFloat, CGFloat) = action["rect"] as! (CGFloat, CGFloat, CGFloat, CGFloat)
                let rect = CGRect(x: tuple.0, y: tuple.1, width: tuple.2, height: tuple.3)
                addPlayXCTestPinchCloseAction(rect: rect, scale: action["scale"] as! CGFloat)
            case "":
                let tuple: (CGFloat, CGFloat, CGFloat, CGFloat) = action["rect"] as! (CGFloat, CGFloat, CGFloat, CGFloat)
                let rect = CGRect(x: tuple.0, y: tuple.1, width: tuple.2, height: tuple.3)
                addPlayXCTestRotateAction(rect: rect, angle: action["angle"] as! CGFloat)
            default:
                print("*** error ***")
            }
        }
    }

    // 回放Tap操作
    public func addPlayXCTestTapAction(locations: [CGPoint], numbersOfTaps: UInt) {
        addPlayAction(actType: "Tap") { [weak self] in
            let semaphore = DispatchSemaphore(value: 0)
            self!.sharedXCEventGenerator.tapAtTouchLocations(locations, numberOfTaps: numbersOfTaps, orientation: orientationValue) {
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
    
    
    // 回放LongPress操作
    public func addPlayXCTestLongPressAction(location: CGPoint) {
        addPlayAction(actType: "Press") { [weak self] in
            let semaphore = DispatchSemaphore(value: 0)
            self!.sharedXCEventGenerator.pressAtPoint(location, forDuration: 0.5, orientation: orientationValue) {
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
    
    
    // 回放Drag操作
    public func addPlayXCTestDragAction(start: CGPoint, end: CGPoint) {
        addPlayAction(actType: "Drag") { [weak self] in
            let semaphore = DispatchSemaphore(value: 0)
            self!.sharedXCEventGenerator.pressAtPoint(start, forDuration: 0, liftAtPoint: end, velocity: 1000, orientation: orientationValue, name: "Monkey drag" as NSString) {
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
    
    
    // 回放PinchClose操作
    public func addPlayXCTestPinchCloseAction(rect: CGRect, scale: CGFloat) {
        addPlayAction(actType: "PinchClose") { [weak self] in
            let semaphore = DispatchSemaphore(value: 0)
            self!.sharedXCEventGenerator.pinchInRect(rect, withScale: scale, velocity: 1, orientation: orientationValue) {
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
    
    
    // 回放PinchOpen操作
    public func addPlayXCTestPinchOpenAction(rect: CGRect, scale: CGFloat) {
        addPlayAction(actType: "PinchOpen") { [weak self] in
            let semaphore = DispatchSemaphore(value: 0)
            self!.sharedXCEventGenerator.pinchInRect(rect, withScale: scale, velocity: 3, orientation: orientationValue) {
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
    
    
    // 回放Rotate操作
    public func addPlayXCTestRotateAction(rect: CGRect, angle: CGFloat) {
        addPlayAction(actType: "Rotate") { [weak self] in
            let semaphore = DispatchSemaphore(value: 0)
            self!.sharedXCEventGenerator.rotateInRect(rect, withRotation: angle, velocity: 5, orientation: orientationValue) {
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
    
    /**
     Add an action that generates a tap, with a possibility for
     multiple taps with multiple fingers, using the private
     XCTest API.
     
     - parameter weight: The relative probability of this
     event being generated. Can be any value larger than
     zero. Probabilities will be normalised to the sum
     of all relative probabilities.
     - parameter multipleTapProbability: Probability that
     the tap event will tap multiple times. Between 0 and 1.
     - parameter multipleTouchProbability: Probability that
     the tap event will use multiple fingers. Between 0 and 1.
     */
    public func addXCTestTapAction(weight: Double, multipleTapProbability: Double = 0.05,
                                   multipleTouchProbability: Double = 0.05) {
        addAction(weight: weight) { [weak self] in
            let numberOfTaps: UInt
            if self!.r.randomDouble() < multipleTapProbability {
                numberOfTaps = UInt(self!.r.randomUInt32() % 2) + 2
            } else {
                numberOfTaps = 1
            }
            
            let locations: [CGPoint]
            if self!.r.randomDouble() < multipleTouchProbability {
                let numberOfTouches = Int(self!.r.randomUInt32() % 3) + 2
                let rect = self!.randomRect()
                locations = (1...numberOfTouches).map { _ in
                    self!.randomPoint(inRect: rect)
                }
            } else {
                locations = [ self!.randomPoint() ]
            }
            
            let semaphore = DispatchSemaphore(value: 0)
            print("*** tap args ***: locations = \(locations) numberOfTaps = \(numberOfTaps)")
            self!.sharedXCEventGenerator.tapAtTouchLocations(locations, numberOfTaps: numberOfTaps, orientation: orientationValue) {
                LogUtils.CHULog(["type":"Tap", "locations":"\(locations)", "numberOfTaps":"\(numberOfTaps)"])
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
    
    /**
     Add an action that generates a long press event
     using the private XCTest API.
     
     - Parameter weight: The relative probability of this
     event being generated. Can be any value larger than
     zero. Probabilities will be normalised to the sum
     of all relative probabilities.
     */
    public func addXCTestLongPressAction(weight: Double) {
        addAction(weight: weight) { [weak self] in
            let point = self!.randomPoint()
            let semaphore = DispatchSemaphore(value: 0)
            print("*** LongPress agrs ***: point = \(point)")
            self!.sharedXCEventGenerator.pressAtPoint(point, forDuration: 0.5, orientation: orientationValue) {
                LogUtils.CHULog(["type":"LongPress", "point":"\(point)"])
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
    
    /**
     Add an action that generates a drag event from one random
     screen position to another using the private XCTest API.
     
     - Parameter weight: The relative probability of this
     event being generated. Can be any value larger than
     zero. Probabilities will be normalised to the sum
     of all relative probabilities.
     */
    public func addXCTestDragAction(weight: Double) {
        addAction(weight: weight) { [weak self] in
            let start = self!.randomPointAvoidingPanelAreas()
            let end = self!.randomPoint()
            
            let semaphore = DispatchSemaphore(value: 0)
            print("*** Drag agrs ***: start = \(start) end = \(end)")
            self!.sharedXCEventGenerator.pressAtPoint(start, forDuration: 0, liftAtPoint: end, velocity: 1000, orientation: orientationValue, name: "Tortoise drag" as NSString) {
                LogUtils.CHULog(["type":"Drag", "start":"\(start)", "end":"\(end)"])
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
    
    /**
     Add an action that generates a pinch close gesture
     at a random screen position using the private XCTest API.
     
     - Parameter weight: The relative probability of this
     event being generated. Can be any value larger than
     zero. Probabilities will be normalised to the sum
     of all relative probabilities.
     */
    public func addXCTestPinchCloseAction(weight: Double) {
        addAction(weight: weight) { [weak self] in
            let rect = self!.randomRect(sizeFraction: 2)
            let scale = 1 / CGFloat(self!.r.randomDouble() * 4 + 1)
            
            let semaphore = DispatchSemaphore(value: 0)
            print("*** PinchClose agrs ***: rect = \(rect) scale = \(scale)")
            self!.sharedXCEventGenerator.pinchInRect(rect, withScale: scale, velocity: 1, orientation: orientationValue) {
                LogUtils.CHULog(["type":"PinchClose", "rect":"\(rect)", "scale":"\(scale)"])
                
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
    
    /**
     Add an action that generates a pinch open gesture
     at a random screen position using the private XCTest API.
     
     - Parameter weight: The relative probability of this
     event being generated. Can be any value larger than
     zero. Probabilities will be normalised to the sum
     of all relative probabilities.
     */
    public func addXCTestPinchOpenAction(weight: Double) {
        addAction(weight: weight) { [weak self] in
            let rect = self!.randomRect(sizeFraction: 2)
            let scale = CGFloat(self!.r.randomDouble() * 4 + 1)
            
            let semaphore = DispatchSemaphore(value: 0)
            print("*** PinchOpen agrs ***: rect = \(rect) scale = \(scale)")
            self!.sharedXCEventGenerator.pinchInRect(rect, withScale: scale, velocity: 3, orientation: orientationValue) {
                LogUtils.CHULog(["type":"PinchOpen", "rect":"\(rect)", "scale":"\(scale)"])
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
    
    /**
     Add an action that generates a rotation gesture
     at a random screen position over a random angle
     using the private XCTest API.
     
     - Parameter weight: The relative probability of this
     event being generated. Can be any value larger than
     zero. Probabilities will be normalised to the sum
     of all relative probabilities.
     */
    public func addXCTestRotateAction(weight: Double) {
        addAction(weight: weight) { [weak self] in
            let rect = self!.randomRect(sizeFraction: 2)
            let angle = CGFloat(self!.r.randomDouble() * 2 * 3.141592)
            let semaphore = DispatchSemaphore(value: 0)
            print("*** Rotate agrs ***: rect = \(rect) angle = \(angle)")
            self!.sharedXCEventGenerator.rotateInRect(rect, withRotation: angle, velocity: 5, orientation: orientationValue) {
                LogUtils.CHULog(["type":"Rotate", "rect":"\(rect)", "angle":"\(angle)"])
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
    
    /**
     Add an action that generates a device rotation event
     using the private XCTest API. Does not currently work!
     
     - Parameter weight: The relative probability of this
     event being generated. Can be any value larger than
     zero. Probabilities will be normalised to the sum
     of all relative probabilities.
     */
    public func addXCTestOrientationAction(weight: Double) {
        addAction(weight: weight) { [weak self] in
            let orientations: [UIDeviceOrientation] = [
                .portrait,
                .portraitUpsideDown,
                .landscapeLeft,
                .landscapeRight,
                .faceUp,
                .faceDown,
                ]
            
            let index = Int(self!.r.randomUInt32() % UInt32(orientations.count))
            orientationValue = orientations[index]
        }
    }
}

@objc protocol XCEventGenerator {
    static func sharedGenerator() -> XCEventGenerator
    
    var generation: UInt64 { get set }
    //@property(readonly) NSObject<OS_dispatch_queue> *eventQueue; // @synthesize eventQueue=_eventQueue;
    
    @discardableResult func rotateInRect(_: CGRect, withRotation: CGFloat, velocity: CGFloat, orientation: UIDeviceOrientation, handler: @escaping () -> Void) -> CGFloat
    @discardableResult func pinchInRect(_: CGRect, withScale: CGFloat, velocity: CGFloat, orientation: UIDeviceOrientation, handler: @escaping () -> Void) -> CGFloat
    @discardableResult func pressAtPoint(_: CGPoint, forDuration: TimeInterval, liftAtPoint: CGPoint, velocity: CGFloat, orientation: UIDeviceOrientation, name: AnyObject, handler: @escaping () -> Void) -> CGFloat
    @discardableResult func pressAtPoint(_: CGPoint, forDuration: TimeInterval, orientation: UIDeviceOrientation, handler: @escaping () -> Void) -> CGFloat
    @discardableResult func tapAtTouchLocations(_: [CGPoint], numberOfTaps: UInt, orientation: UIDeviceOrientation, handler: @escaping () -> Void) -> CGFloat
    func _startEventSequenceWithSteppingCallback(_: () -> Void)
    func _scheduleCallback(_: () -> Void, afterInterval: TimeInterval)
    
    init()
}
