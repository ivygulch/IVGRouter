//
//  RootRouteSegmentPresenterSpec.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class RootRouteSegmentPresenterSpec: QuickSpec {

    override func spec() {

        let mockViewControllerA = MockViewController("A")
        let mockViewControllerB = MockViewController("B")
        var mockWindow: MockWindow!
        var mockCompletionBlock: MockCompletionBlock!

        beforeEach {
            mockWindow = MockWindow()
            mockCompletionBlock = MockCompletionBlock()
        }

        describe("presentIdentifier") {

            it("should get a default value") {
                let presenter = RootRouteSegmentPresenter()
                let defaultIdentifier = Identifier(name: String(presenter.dynamicType))
                expect(presenter.presenterIdentifier).to(equal(defaultIdentifier))
            }

            it("should allow a custom identifier") {
                let customIdentifier = Identifier(name: "Custom")
                let presenter = RootRouteSegmentPresenter(presenterIdentifier: customIdentifier)
                expect(presenter.presenterIdentifier).to(equal(customIdentifier))
            }

        }

        describe("presentViewController") {

            it("should fail when window is nil") {
                let presenter = RootRouteSegmentPresenter()
                presenter.presentViewController(mockViewControllerB, from: nil, withWindow: nil, completion: mockCompletionBlock.completion)
                expect(mockCompletionBlock.trackerKeyValues).to(equal(["completion":[["false"]]]))
            }

            it("should fail when presentingViewController is not nil") {
                let presenter = RootRouteSegmentPresenter()
                presenter.presentViewController(mockViewControllerB, from: mockViewControllerA, withWindow: mockWindow, completion: mockCompletionBlock.completion)
                expect(mockCompletionBlock.trackerKeyValues).to(equal(["completion":[["false"]]]))
                expect(mockWindow.trackerKeyValues).to(beEmpty())
            }

            it("should pass when window is not nil") {
                let presenter = RootRouteSegmentPresenter()
                presenter.presentViewController(mockViewControllerB, from: nil, withWindow: mockWindow, completion: mockCompletionBlock.completion)
                expect(mockCompletionBlock.trackerKeyValues).to(equal(["completion":[["true"]]]))
                expect(mockWindow.trackerKeyValues).to(equal(["makeKeyAndVisible":[[]],"setRootViewController":[[mockViewControllerB.description]]]))
            }

        }
        
    }
    
}