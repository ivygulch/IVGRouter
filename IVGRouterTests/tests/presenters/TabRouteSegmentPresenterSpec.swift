//
//  TabRouteSegmentPresenterSpec.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class TabRouteSegmentPresenterSpec: QuickSpec {

    override func spec() {

        let mockViewControllerA = MockViewController("A")
        let mockViewControllerB = MockViewController("B")
        var mockCompletionBlock: MockCompletionBlock!

        beforeEach {
            mockCompletionBlock = MockCompletionBlock()
        }

        describe("presentViewController") {

            it("should fail when presentingViewController is nil") {
                let presenter = TabRouteSegmentPresenter()
                let result = presenter.presentViewController(mockViewControllerB, from: nil, options:[:], window: nil, completion: mockCompletionBlock.completion)
                expect(result).to(beNil())
                expect(mockCompletionBlock.trackerKeyValues).to(equal(["completion":[["false"]]]))
            }

            it("should fail when presentingViewController is not a UITabBarController") {
                let presenter = TabRouteSegmentPresenter()
                let result = presenter.presentViewController(mockViewControllerB, from: mockViewControllerA, options:[:], window: nil, completion: mockCompletionBlock.completion)
                expect(result).to(beNil())
                expect(mockCompletionBlock.trackerKeyValues).to(equal(["completion":[["false"]]]))
            }

            it("should succeed when presentingViewController is a UITabBarController") {
                let presenter = TabRouteSegmentPresenter()
                let result = presenter.presentViewController(mockViewControllerB, from: UITabBarController(), options:[:], window: nil, completion: mockCompletionBlock.completion)
                expect(result).to(equal(mockViewControllerB))
                expect(mockCompletionBlock.trackerKeyValues).to(equal(["completion":[["true"]]]))
            }

        }
        
    }
    
}