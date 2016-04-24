//
//  RouterSpec.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/1/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class RouterSpec: QuickSpec {

    func buildMockVisualRouteSegment(segmentIdentifier: String, presenterIdentifier: Identifier, viewController:UIViewController?) -> MockVisualRouteSegment {
        return MockVisualRouteSegment(segmentIdentifier: Identifier(name: segmentIdentifier),
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

        describe("registering default presenters") {

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

        describe("registration") {

            var mockVisualRouteSegmentA: MockVisualRouteSegment!
            var mockVisualRouteSegmentB: MockVisualRouteSegment!
            var mockPresenterA: MockVisualRouteSegmentPresenter!
            var mockPresenterB: MockVisualRouteSegmentPresenter!
            var router: Router!

            beforeEach {
                mockPresenterA = MockVisualRouteSegmentPresenter(presenterIdentifier: "A", completionBlockArg: true)
                mockPresenterB = MockVisualRouteSegmentPresenter(presenterIdentifier: "B", completionBlockArg: true)
                mockVisualRouteSegmentA = self.buildMockVisualRouteSegment("A", presenterIdentifier: mockPresenterA.presenterIdentifier, viewController:MockViewController("A"))
                mockVisualRouteSegmentB = self.buildMockVisualRouteSegment("B", presenterIdentifier: mockPresenterB.presenterIdentifier, viewController:MockViewController("B"))
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

        describe("execute simple route") {

            var mockPresenterCompletionSucceeds: MockVisualRouteSegmentPresenter!
            var mockPresenterCompletionFails: MockVisualRouteSegmentPresenter!
            var mockVisualRouteSegmentValid: MockVisualRouteSegment!
            var mockVisualRouteSegmentNoViewController: MockVisualRouteSegment!
            var mockVisualRouteSegmentCompletionFails: MockVisualRouteSegment!
            var router: Router!

            beforeEach {
                mockPresenterCompletionSucceeds = MockVisualRouteSegmentPresenter(presenterIdentifier: "Success", completionBlockArg: true)
                mockPresenterCompletionFails = MockVisualRouteSegmentPresenter(presenterIdentifier: "Failure", completionBlockArg: false)
                mockVisualRouteSegmentValid = self.buildMockVisualRouteSegment("Valid", presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, viewController:MockViewController(""))
                mockVisualRouteSegmentNoViewController = self.buildMockVisualRouteSegment("NoViewController", presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, viewController:nil)
                mockVisualRouteSegmentCompletionFails = self.buildMockVisualRouteSegment("CompletionFails", presenterIdentifier: mockPresenterCompletionFails.presenterIdentifier, viewController:MockViewController(""))
                router = Router(window: nil)
                router.registerPresenter(mockPresenterCompletionSucceeds)
                router.registerPresenter(mockPresenterCompletionFails)
                router.registerRouteSegment(mockVisualRouteSegmentNoViewController)
                router.registerRouteSegment(mockVisualRouteSegmentCompletionFails)
                router.registerRouteSegment(mockVisualRouteSegmentValid)
                router.registerRouteSegment(mockVisualRouteSegmentNoViewController)
                router.registerRouteSegment(mockVisualRouteSegmentCompletionFails)
            }

            it("should succeed when segment produces a view controller and completion block arg is true") {
                let success = router.executeRoute([mockVisualRouteSegmentValid.segmentIdentifier])
                expect(success).to(beTrue())
            }

            it("should fail when segment does not produce a view controller") {
                let success = router.executeRoute([mockVisualRouteSegmentNoViewController.segmentIdentifier])
                expect(success).to(beFalse())
            }

            it("should fail when segment completion block arg is false") {
                let success = router.executeRoute([mockVisualRouteSegmentCompletionFails.segmentIdentifier])
                expect(success).to(beFalse())
            }
        }

        describe("execute simple sequence route") {

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
                mockVisualRouteSegmentA = self.buildMockVisualRouteSegment("A", presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, viewController:mockViewControllerA)
                mockVisualRouteSegmentB = self.buildMockVisualRouteSegment("B", presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, viewController:mockViewControllerB)
                mockVisualRouteSegmentC = self.buildMockVisualRouteSegment("C", presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, viewController:mockViewControllerC)
                mockVisualRouteSegmentInvalid = self.buildMockVisualRouteSegment("Invalid", presenterIdentifier: mockPresenterCompletionFails.presenterIdentifier, viewController:nil)
                router = Router(window: nil)
                router.registerPresenter(mockPresenterCompletionSucceeds)
                router.registerPresenter(mockPresenterCompletionFails)
                router.registerRouteSegment(mockVisualRouteSegmentA)
                router.registerRouteSegment(mockVisualRouteSegmentB)
                router.registerRouteSegment(mockVisualRouteSegmentC)
                validSequence = [mockVisualRouteSegmentA.segmentIdentifier,mockVisualRouteSegmentB.segmentIdentifier,mockVisualRouteSegmentC.segmentIdentifier]
                invalidSequence = [mockVisualRouteSegmentA.segmentIdentifier,mockVisualRouteSegmentInvalid.segmentIdentifier,mockVisualRouteSegmentC.segmentIdentifier]
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
