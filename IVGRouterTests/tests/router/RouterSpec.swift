//
//  RouterSpec.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/1/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class RouterSpec: QuickSpec {

    func buildMockRouteSegment(segmentIdentifier: String, presenterIdentifier: Identifier, viewController:UIViewController?) -> MockRouteSegment {
        return MockRouteSegment(segmentIdentifier: Identifier(name: segmentIdentifier),
                                presenterIdentifier: presenterIdentifier,
                                presentedViewController : viewController)
    }

    override func spec() {

        describe("initialization") {

            it("should allow for a nil window") {
                let router = Router(window: nil)
                expect(router.window).to(beNil())
            }

            it("should have an empty set of routeSegments") {
                let router = Router(window: nil)
                expect(router.routeSegments).to(beEmpty())
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

        describe("registration") {

            var mockRouteSegmentA: MockRouteSegment!
            var mockRouteSegmentB: MockRouteSegment!
            var mockPresenterA: MockRouteSegmentPresenter!
            var mockPresenterB: MockRouteSegmentPresenter!
            var router: Router!

            beforeEach {
                mockPresenterA = MockRouteSegmentPresenter(presenterIdentifier: "A", completionBlockArg: true)
                mockPresenterB = MockRouteSegmentPresenter(presenterIdentifier: "B", completionBlockArg: true)
                mockRouteSegmentA = self.buildMockRouteSegment("A", presenterIdentifier: mockPresenterA.presenterIdentifier, viewController:MockViewController("A"))
                mockRouteSegmentB = self.buildMockRouteSegment("B", presenterIdentifier: mockPresenterB.presenterIdentifier, viewController:MockViewController("B"))
                router = Router(window: nil)
            }

            it("should be able to register and recall single routes") {
                router.registerRouteSegment(mockRouteSegmentA)
                let actualRouteSegmentA = router.routeSegments[mockRouteSegmentA.segmentIdentifier] as? MockRouteSegment
                expect(actualRouteSegmentA).to(beIdenticalTo(mockRouteSegmentA))
            }

            it("should be able to register and recall multiple routes") {
                router.registerRouteSegment(mockRouteSegmentA)
                router.registerRouteSegment(mockRouteSegmentB)
                let actualRouteSegmentA = router.routeSegments[mockRouteSegmentA.segmentIdentifier] as? MockRouteSegment
                expect(actualRouteSegmentA).to(beIdenticalTo(mockRouteSegmentA))
                let actualRouteSegmentB = router.routeSegments[mockRouteSegmentB.segmentIdentifier] as? MockRouteSegment
                expect(actualRouteSegmentB).to(beIdenticalTo(mockRouteSegmentB))
            }

            it("should be able to register and recall single presenter") {
                router.registerPresenter(mockPresenterA)
                let actualPresenterA = router.presenters[mockPresenterA.presenterIdentifier] as? MockRouteSegmentPresenter
                expect(actualPresenterA).to(beIdenticalTo(mockPresenterA))
            }

            it("should be able to register and recall multiple presenters") {
                router.registerPresenter(mockPresenterA)
                router.registerPresenter(mockPresenterB)
                let actualPresenterA = router.presenters[mockPresenterA.presenterIdentifier] as? MockRouteSegmentPresenter
                expect(actualPresenterA).to(beIdenticalTo(mockPresenterA))
                let actualPresenterB = router.presenters[mockPresenterB.presenterIdentifier] as? MockRouteSegmentPresenter
                expect(actualPresenterB).to(beIdenticalTo(mockPresenterB))
            }
        }

        describe("execute simple route") {

            var mockPresenterCompletionSucceeds: MockRouteSegmentPresenter!
            var mockPresenterCompletionFails: MockRouteSegmentPresenter!
            var mockRouteSegmentValid: MockRouteSegment!
            var mockRouteSegmentNoViewController: MockRouteSegment!
            var mockRouteSegmentCompletionFails: MockRouteSegment!
            var router: Router!

            beforeEach {
                mockPresenterCompletionSucceeds = MockRouteSegmentPresenter(presenterIdentifier: "Success", completionBlockArg: true)
                mockPresenterCompletionFails = MockRouteSegmentPresenter(presenterIdentifier: "Failure", completionBlockArg: false)
                mockRouteSegmentValid = self.buildMockRouteSegment("Valid", presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, viewController:MockViewController(""))
                mockRouteSegmentNoViewController = self.buildMockRouteSegment("NoViewController", presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, viewController:nil)
                mockRouteSegmentCompletionFails = self.buildMockRouteSegment("CompletionFails", presenterIdentifier: mockPresenterCompletionFails.presenterIdentifier, viewController:MockViewController(""))
                router = Router(window: nil)
                router.registerPresenter(mockPresenterCompletionSucceeds)
                router.registerPresenter(mockPresenterCompletionFails)
                router.registerRouteSegment(mockRouteSegmentNoViewController)
                router.registerRouteSegment(mockRouteSegmentCompletionFails)
                router.registerRouteSegment(mockRouteSegmentValid)
                router.registerRouteSegment(mockRouteSegmentNoViewController)
                router.registerRouteSegment(mockRouteSegmentCompletionFails)
            }

            it("should succeed when segment produces a view controller and completion block arg is true") {
                let success = router.executeRoute([mockRouteSegmentValid.segmentIdentifier])
                expect(success).to(beTrue())
            }

            it("should fail when segment does not produce a view controller") {
                let success = router.executeRoute([mockRouteSegmentNoViewController.segmentIdentifier])
                expect(success).to(beFalse())
            }

            it("should fail when segment completion block arg is false") {
                let success = router.executeRoute([mockRouteSegmentCompletionFails.segmentIdentifier])
                expect(success).to(beFalse())
            }
        }

        describe("execute simple sequence route") {

            let mockViewControllerA = MockViewController("A")
            let mockViewControllerB = MockViewController("B")
            let mockViewControllerC = MockViewController("C")
            var mockPresenterCompletionSucceeds: MockRouteSegmentPresenter!
            var mockPresenterCompletionFails: MockRouteSegmentPresenter!
            var mockRouteSegmentA: MockRouteSegment!
            var mockRouteSegmentB: MockRouteSegment!
            var mockRouteSegmentC: MockRouteSegment!
            var mockRouteSegmentInvalid: MockRouteSegment!
            var router: Router!
            var validSequence:[Any]!
            var invalidSequence:[Any]!

            beforeEach {
                mockPresenterCompletionSucceeds = MockRouteSegmentPresenter(presenterIdentifier: "Success", completionBlockArg: true)
                mockPresenterCompletionFails = MockRouteSegmentPresenter(presenterIdentifier: "Failure", completionBlockArg: false)
                mockRouteSegmentA = self.buildMockRouteSegment("A", presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, viewController:mockViewControllerA)
                mockRouteSegmentB = self.buildMockRouteSegment("B", presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, viewController:mockViewControllerB)
                mockRouteSegmentC = self.buildMockRouteSegment("C", presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, viewController:mockViewControllerC)
                mockRouteSegmentInvalid = self.buildMockRouteSegment("Invalid", presenterIdentifier: mockPresenterCompletionFails.presenterIdentifier, viewController:nil)
                router = Router(window: nil)
                router.registerPresenter(mockPresenterCompletionSucceeds)
                router.registerPresenter(mockPresenterCompletionFails)
                router.registerRouteSegment(mockRouteSegmentA)
                router.registerRouteSegment(mockRouteSegmentB)
                router.registerRouteSegment(mockRouteSegmentC)
                validSequence = [mockRouteSegmentA.segmentIdentifier,mockRouteSegmentB.segmentIdentifier,mockRouteSegmentC.segmentIdentifier]
                invalidSequence = [mockRouteSegmentA.segmentIdentifier,mockRouteSegmentInvalid.segmentIdentifier,mockRouteSegmentC.segmentIdentifier]
            }

            describe("when a valid sequence is used") {

                it("should succeed") {
                    let success = router.executeRoute(validSequence)
                    expect(success).to(beTrue())
                }

                it("should produce full sequence") {
                    router.executeRoute(validSequence)
                    expect(router.viewControllers).to(equal([mockViewControllerA,mockViewControllerB,mockViewControllerC]))
                }
                
            }

            describe("when a invalid sequence is used") {

                it("should fail") {
                    let success = router.executeRoute(invalidSequence)
                    expect(success).to(beFalse())
                }

                it("should produce partial sequence") {
                    router.executeRoute(invalidSequence)
                    expect(router.viewControllers).to(equal([mockViewControllerA]))
                }
                
            }

        }

    }

}