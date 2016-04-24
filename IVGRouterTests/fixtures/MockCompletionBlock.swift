//
//  MockCompletionBlock.swift
//  IVGAppContainer
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

    var completion: (Bool) -> Void {
        return {
            (finished:Bool) -> Void in
            self.track("completion", ["\(finished)"])
            if let expectation = self.expectation {
                expectation.fulfill()
            }
        }
    }

    let expectation: XCTestExpectation?
}