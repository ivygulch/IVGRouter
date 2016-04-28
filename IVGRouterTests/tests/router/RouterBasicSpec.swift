//
//  RouterBasicSpec.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/1/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class RouterBasicSpec: QuickSpec {

    override func spec() {

        describe("Router") {

            // MARK: intialization tests

            context("when initialized") {

                it("should allow for a nil window") {
                    let router = Router(window: nil)
                    expect(router.window).to(beNil())
                }

                it("should have an empty set of routeSegments") {
                    let router = Router(window: nil)
                    expect(router.routeSegments).to(beEmpty())
                }

                it("should have an empty set of presenters") {
                    let router = Router(window: nil)
                    expect(router.presenters).to(beEmpty())
                }

                it("should have an empty set of viewControllers") {
                    let router = Router(window: nil)
                    expect(router.viewControllers).to(beEmpty())
                }

                it("should allow for a non-nil window") {
                    let mockWindow = UIWindow()
                    let router = Router(window: mockWindow)
                    expect(router.window).to(equal(mockWindow))
                }

            }

            // MARK: presenter registration tests

            context("when registering default presenters") {

                var router: Router!

                beforeEach {
                    router = Router(window: nil)
                    router.registerDefaultPresenters()
                }

                it("should include RootRouteSegmentPresenter") {
                    expect(router.presenters[Identifier(name: String(RootRouteSegmentPresenter))]).toNot(beNil())
                }

                it("should include TabRouteSegmentPresenter") {
                    expect(router.presenters[Identifier(name: String(TabRouteSegmentPresenter))]).toNot(beNil())
                }

                it("should include PushRouteSegmentPresenter") {
                    expect(router.presenters[Identifier(name: String(PushRouteSegmentPresenter))]).toNot(beNil())
                }

            }

            // MARK: route segment registration tests

            context("when registering route segments") {

                var mockVisualRouteSegmentA: MockVisualRouteSegment!
                var mockVisualRouteSegmentB: MockVisualRouteSegment!
                var mockPresenterA: MockVisualRouteSegmentPresenter!
                var mockPresenterB: MockVisualRouteSegmentPresenter!
                var router: Router!

                beforeEach {
                    mockPresenterA = MockVisualRouteSegmentPresenter(presenterIdentifier: "A", completionBlockArg: true)
                    mockPresenterB = MockVisualRouteSegmentPresenter(presenterIdentifier: "B", completionBlockArg: true)
                    mockVisualRouteSegmentA = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "A"), presenterIdentifier: mockPresenterA.presenterIdentifier, presentedViewController: MockViewController("A"))
                    mockVisualRouteSegmentB = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "B"), presenterIdentifier: mockPresenterB.presenterIdentifier, presentedViewController: MockViewController("B"))
                    router = Router(window: nil)
                }

                it("should be able to register and recall single routes") {
                    router.registerRouteSegment(mockVisualRouteSegmentA)
                    let actualRouteSegmentA = router.routeSegments[mockVisualRouteSegmentA.segmentIdentifier] as? MockVisualRouteSegment
                    expect(actualRouteSegmentA).to(beIdenticalTo(mockVisualRouteSegmentA))
                }

                it("should be able to register and recall multiple routes") {
                    router.registerRouteSegment(mockVisualRouteSegmentA)
                    router.registerRouteSegment(mockVisualRouteSegmentB)
                    let actualRouteSegmentA = router.routeSegments[mockVisualRouteSegmentA.segmentIdentifier] as? MockVisualRouteSegment
                    expect(actualRouteSegmentA).to(beIdenticalTo(mockVisualRouteSegmentA))
                    let actualRouteSegmentB = router.routeSegments[mockVisualRouteSegmentB.segmentIdentifier] as? MockVisualRouteSegment
                    expect(actualRouteSegmentB).to(beIdenticalTo(mockVisualRouteSegmentB))
                }

                it("should be able to register and recall single presenter") {
                    router.registerPresenter(mockPresenterA)
                    let actualPresenterA = router.presenters[mockPresenterA.presenterIdentifier] as? MockVisualRouteSegmentPresenter
                    expect(actualPresenterA).to(beIdenticalTo(mockPresenterA))
                }

                it("should be able to register and recall multiple presenters") {
                    router.registerPresenter(mockPresenterA)
                    router.registerPresenter(mockPresenterB)
                    let actualPresenterA = router.presenters[mockPresenterA.presenterIdentifier] as? MockVisualRouteSegmentPresenter
                    expect(actualPresenterA).to(beIdenticalTo(mockPresenterA))
                    let actualPresenterB = router.presenters[mockPresenterB.presenterIdentifier] as? MockVisualRouteSegmentPresenter
                    expect(actualPresenterB).to(beIdenticalTo(mockPresenterB))
                }
            }

            // MARK: single segment route execution tests

            context("when executing single segment route") {

                let identifierNoViewController = Identifier(name: "NoViewController")
                let identifierCompletionFails = Identifier(name: "CompletionFails")
                let identifierValid = Identifier(name: "Valid")
                let mockViewControllerA = MockViewController("A")
                let mockViewControllerB = MockViewController("B")
                var mockPresenterCompletionSucceeds: MockVisualRouteSegmentPresenter!
                var mockPresenterCompletionFails: MockVisualRouteSegmentPresenter!
                var mockVisualRouteSegmentValid: MockVisualRouteSegment!
                var mockVisualRouteSegmentNoViewController: MockVisualRouteSegment!
                var mockVisualRouteSegmentCompletionFails: MockVisualRouteSegment!
                var router: Router!

                beforeEach {
                    mockPresenterCompletionSucceeds = MockVisualRouteSegmentPresenter(presenterIdentifier: "Success", completionBlockArg: true)
                    mockPresenterCompletionFails = MockVisualRouteSegmentPresenter(presenterIdentifier: "Failure", completionBlockArg: false)
                    mockVisualRouteSegmentValid = MockVisualRouteSegment(segmentIdentifier: identifierValid, presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: mockViewControllerA)
                    mockVisualRouteSegmentNoViewController = MockVisualRouteSegment(segmentIdentifier: identifierNoViewController, presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: nil)
                    mockVisualRouteSegmentCompletionFails = MockVisualRouteSegment(segmentIdentifier: identifierCompletionFails, presenterIdentifier: mockPresenterCompletionFails.presenterIdentifier, presentedViewController: mockViewControllerB)
                    router = Router(window: nil)
                    router.registerPresenter(mockPresenterCompletionSucceeds)
                    router.registerPresenter(mockPresenterCompletionFails)
                    router.registerRouteSegment(mockVisualRouteSegmentNoViewController)
                    router.registerRouteSegment(mockVisualRouteSegmentCompletionFails)
                    router.registerRouteSegment(mockVisualRouteSegmentValid)
                    router.registerRouteSegment(mockVisualRouteSegmentNoViewController)
                    router.registerRouteSegment(mockVisualRouteSegmentCompletionFails)
                }

                context("with segment that produces a view controller and completion block arg is true") {

                    it("should succeed") {
                        let routeSequence: [Any] = [mockVisualRouteSegmentValid.segmentIdentifier]
                        let expectation = self.expectationWithDescription("executeRoute completion callback")
                        router.executeRoute2(routeSequence) {
                            routingResult in
                            switch routingResult {
                            case .Success(let finalViewController):
                                expect(finalViewController).to(equal(mockViewControllerA))
                            case .Failure(let error):
                                fail("Did not expect error: \(error)")
                            }
                            expectation.fulfill()
                        }
                        self.waitForExpectationsWithTimeout(5, handler: nil)
                    }

                }

                context("with segment that does not produce a view controller") {

                    it("should fail") {
                        let routeSequence: [Any] = [mockVisualRouteSegmentNoViewController.segmentIdentifier]
                        let expectation = self.expectationWithDescription("executeRoute completion callback")
                        router.executeRoute2(routeSequence) {
                            routingResult in
                            switch routingResult {
                            case .Success(let finalViewController):
                                fail("Did not expect success: \(finalViewController)")
                            case .Failure(let error):
                                expect(error as? RoutingErrors).toNot(beNil())
                                if let error = error as? RoutingErrors {
                                    switch error {
                                    case .NoViewControllerProduced(let identifier):
                                        expect(identifier).to(equal(identifierNoViewController))
                                    default:
                                        fail("Did not expect: \(error)")
                                    }
                                }
                            }
                            expectation.fulfill()
                        }
                        self.waitForExpectationsWithTimeout(5, handler: nil)
                    }

                }

                context("with segment completion block that returns false") {

                    it("should fail") {
                        let routeSequence: [Any] = [mockVisualRouteSegmentCompletionFails.segmentIdentifier]
                        let expectation = self.expectationWithDescription("executeRoute completion callback")
                        router.executeRoute2(routeSequence) {
                            routingResult in
                            switch routingResult {
                            case .Success(let finalViewController):
                                fail("Did not expect success: \(finalViewController)")
                            case .Failure(let error):
                                expect(error as? RoutingErrors).toNot(beNil())
                                if let error = error as? RoutingErrors {
                                    switch error {
                                    case .NoViewControllerProduced(let identifier):
                                        expect(identifier).to(equal(identifierCompletionFails))
                                    default:
                                        fail("Did not expect: \(error)")
                                    }
                                }
                            }
                            expectation.fulfill()
                        }
                        self.waitForExpectationsWithTimeout(5, handler: nil)
                    }

                }
            }

            // MARK: single segment route execution tests

            context("when executing simple, multiple segment route") {

                let identifierInvalid = Identifier(name: "Invalid")
                let mockViewControllerA = MockViewController("A")
                let mockViewControllerB = MockViewController("B")
                let mockViewControllerC = MockViewController("C")
                var mockPresenterCompletionSucceeds: MockVisualRouteSegmentPresenter!
                var mockPresenterCompletionFails: MockVisualRouteSegmentPresenter!
                var mockVisualRouteSegmentA: MockVisualRouteSegment!
                var mockVisualRouteSegmentB: MockVisualRouteSegment!
                var mockVisualRouteSegmentC: MockVisualRouteSegment!
                var mockVisualRouteSegmentInvalid: MockVisualRouteSegment!
                var router: Router!
                var validSequence:[Any]!
                var invalidSequence:[Any]!

                beforeEach {
                    mockPresenterCompletionSucceeds = MockVisualRouteSegmentPresenter(presenterIdentifier: "Success", completionBlockArg: true)
                    mockPresenterCompletionFails = MockVisualRouteSegmentPresenter(presenterIdentifier: "Failure", completionBlockArg: false)
                    mockVisualRouteSegmentA = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "A"), presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: mockViewControllerA)
                    mockVisualRouteSegmentB = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "B"), presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: mockViewControllerB)
                    mockVisualRouteSegmentC = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "C"), presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: mockViewControllerC)
                    mockVisualRouteSegmentInvalid = MockVisualRouteSegment(segmentIdentifier: identifierInvalid, presenterIdentifier: mockPresenterCompletionFails.presenterIdentifier, presentedViewController: nil)
                    router = Router(window: nil)
                    router.registerPresenter(mockPresenterCompletionSucceeds)
                    router.registerPresenter(mockPresenterCompletionFails)
                    router.registerRouteSegment(mockVisualRouteSegmentA)
                    router.registerRouteSegment(mockVisualRouteSegmentB)
                    router.registerRouteSegment(mockVisualRouteSegmentC)
                    validSequence = [mockVisualRouteSegmentA.segmentIdentifier,mockVisualRouteSegmentB.segmentIdentifier,mockVisualRouteSegmentC.segmentIdentifier]
                    invalidSequence = [mockVisualRouteSegmentA.segmentIdentifier,mockVisualRouteSegmentInvalid.segmentIdentifier,mockVisualRouteSegmentC.segmentIdentifier]
                }

                context("with a valid sequence") {

                    it("should succeed") {
                        let expectation = self.expectationWithDescription("executeRoute completion callback")
                        router.executeRoute2(validSequence) {
                            routingResult in
                            switch routingResult {
                            case .Success(let finalViewController):
                                expect(finalViewController).to(equal(mockViewControllerC))
                            case .Failure(let error):
                                fail("Did not expect error: \(error)")
                            }
                            expectation.fulfill()
                        }
                        self.waitForExpectationsWithTimeout(5, handler: nil)
                    }

                    it("should produce full sequence") {
                        let expectation = self.expectationWithDescription("executeRoute completion callback")
                        router.executeRoute2(validSequence) {
                            _ in
                            expectation.fulfill()
                        }
                        self.waitForExpectationsWithTimeout(5, handler: nil)
                        expect(router.viewControllers).to(equal([mockViewControllerA,mockViewControllerB,mockViewControllerC]))
                    }

                }

                context("with an invalid sequence") {

                    it("should fail") {
                        let expectation = self.expectationWithDescription("executeRoute completion callback")
                        router.executeRoute2(invalidSequence) {
                            routingResult in
                            switch routingResult {
                            case .Success(let finalViewController):
                                fail("Did not expect success: \(finalViewController)")
                            case .Failure(let error):
                                expect(error as? RoutingErrors).toNot(beNil())
                                if let error = error as? RoutingErrors {
                                    switch error {
                                    case .SegmentNotRegistered(let identifier):
                                        expect(identifier).to(equal(identifierInvalid))
                                    default:
                                        fail("Did not expect: \(error)")
                                    }
                                }
                            }
                            expectation.fulfill()
                        }
                        self.waitForExpectationsWithTimeout(5, handler: nil)
                    }

                    it("should produce partial sequence") {
                        let expectation = self.expectationWithDescription("executeRoute completion callback")
                        router.executeRoute2(invalidSequence) {
                            _ in
                            expectation.fulfill()
                        }
                        self.waitForExpectationsWithTimeout(5, handler: nil)
                        expect(router.viewControllers).to(equal([mockViewControllerA]))
                    }
                    
                }
                
            }

        }
        
    }
}
