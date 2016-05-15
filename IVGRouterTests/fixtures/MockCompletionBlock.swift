//
//  MockCompletionBlock.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/1/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import XCTest

class MockCompletionBlock : TrackableTestClass {

    init(expectation: XCTestExpectation? = nil) {
        self.expectation = expectation
    }

    var completion: (Bool, UIViewController?) -> Void {
        return {
            (finished:Bool, viewController:UIViewController?) -> Void in
            let vcDesc = viewController == nil ? "nil" : String(viewController!)
            self.track("completion", ["\(finished)",vcDesc])
            if let expectation = self.expectation {
                expectation.fulfill()
            }
        }
    }

    let expectation: XCTestExpectation?
}