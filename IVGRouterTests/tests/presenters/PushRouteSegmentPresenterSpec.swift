//
//  PushRouteSegmentPresenterSpec.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class PushRouteSegmentPresenterSpec: QuickSpec {

    override func spec() {

        let mockViewControllerA = MockViewController("A")
        let mockViewControllerB = MockViewController("B")
        let mockViewControllerC = MockViewController("C")

        describe("class definition") {

            it("should have default identifier") {
                expect(PushRouteSegmentPresenter.defaultPresenterIdentifier).to(equal(Identifier(name: String(PushRouteSegmentPresenter))))
            }

        }

        describe("when presentingViewController is nil") {

            it("should fail") {
                let mockCompletionBlock = MockCompletionBlock()
                let presenter = PushRouteSegmentPresenter()
                presenter.presentViewController(mockViewControllerC, from: nil, options:[:], window: nil, completion: mockCompletionBlock.completion)
                expect(mockCompletionBlock.trackerKeyValues).to(equal(["completion":[["false","nil"]]]))
            }

        }

        describe("when presentingViewController is not part of a navigationController stack") {

            it("should fail") {
                let mockCompletionBlock = MockCompletionBlock()
                let presenter = PushRouteSegmentPresenter()
                presenter.presentViewController(mockViewControllerC, from: mockViewControllerA, options:[:], window: nil, completion: mockCompletionBlock.completion)
                expect(mockCompletionBlock.trackerKeyValues).to(equal(["completion":[["false","nil"]]]))
            }

        }
        
        describe("when presentedViewController is already part of a navigationController stack") {

            it("should fail") {
                let mockCompletionBlock = MockCompletionBlock(expectation: self.expectationWithDescription("completion"))
                let presenter = PushRouteSegmentPresenter()
                let navigationController = UINavigationController()
                navigationController.viewControllers = [mockViewControllerA, mockViewControllerB]

                // test environment does not work with animated pushes
                let options:RouteSequenceOptions = [PushRouteSegmentPresenterOptions.AnimatedKey:false]

                presenter.presentViewController(mockViewControllerA, from: mockViewControllerB, options:options, window: nil, completion: mockCompletionBlock.completion)
                expect(mockCompletionBlock.trackerKeyValues).to(equal(["completion":[["false","nil"]]]))
            }

        }
        
        describe("when presentingViewController is a UINavigationController") {
            
            it("should succeed when navigation stack is empty") {
                let mockCompletionBlock = MockCompletionBlock(expectation: self.expectationWithDescription("completion"))
                let presenter = PushRouteSegmentPresenter()
                let navigationController = UINavigationController()
                expect(navigationController.viewControllers).to(beEmpty())
                
                presenter.presentViewController(mockViewControllerC, from: navigationController, options:[:], window: nil, completion: mockCompletionBlock.completion)
                self.waitForExpectationsWithTimeout(5, handler: nil)
                expect(navigationController.viewControllers).to(equal([mockViewControllerC]))
                expect(mockCompletionBlock.trackerKeyValues).to(equal(["completion":[["true",String(mockViewControllerC)]]]))
            }

            it("should replace stack when navigation stack already has values") {
                let mockCompletionBlock = MockCompletionBlock(expectation: self.expectationWithDescription("completion replace statck"))
                let presenter = PushRouteSegmentPresenter()
                let navigationController = UINavigationController()
                navigationController.viewControllers = [mockViewControllerA,mockViewControllerB]
                expect(navigationController.viewControllers).toNot(beEmpty())

                // test environment does not work with animated pushes
                let options:RouteSequenceOptions = [PushRouteSegmentPresenterOptions.AnimatedKey:false]

                presenter.presentViewController(mockViewControllerC, from: navigationController, options:options, window: nil, completion: mockCompletionBlock.completion)
                self.waitForExpectationsWithTimeout(5, handler: nil)
                expect(navigationController.viewControllers).to(equal([mockViewControllerC]))
                expect(mockCompletionBlock.trackerKeyValues).to(equal(["completion":[["true",String(mockViewControllerC)]]]))
            }

        }

        describe("when presentingViewController has a navigationController") {

            it("should succeed") {
                let mockCompletionBlock = MockCompletionBlock(expectation: self.expectationWithDescription("completion"))
                let presenter = PushRouteSegmentPresenter()
                let navigationController = UINavigationController()
                navigationController.viewControllers = [mockViewControllerA]

                // test environment does not work with animated pushes
                let options:RouteSequenceOptions = [PushRouteSegmentPresenterOptions.AnimatedKey:false]

                presenter.presentViewController(mockViewControllerC, from: mockViewControllerA, options:options, window: nil, completion: mockCompletionBlock.completion)
                self.waitForExpectationsWithTimeout(5, handler: nil)
                expect(navigationController.viewControllers).to(equal([mockViewControllerA, mockViewControllerC]))
                expect(mockCompletionBlock.trackerKeyValues).to(equal(["completion":[["true",String(mockViewControllerC)]]]))
            }

        }

    }
    
}