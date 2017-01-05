//
//  MockCompletionBlock.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/1/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import XCTest
import IVGRouter

class MockCompletionBlock : TrackableTestClass {

    init(expectation: XCTestExpectation? = nil) {
        self.expectation = expectation
    }

    var completion: (RoutingResult -> Void) {
        return {
            routingResult -> Void in

            switch routingResult {
            case .success(let viewController):
                self.track("completion", [String(true),String(viewController)])
            case .failure(_):
                self.track("completion", [String(false),"nil"])
            }
            if let expectation = self.expectation {
                expectation.fulfill()
            }
        }
    }

    let expectation: XCTestExpectation?
}
