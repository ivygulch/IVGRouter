//
//  RouterBranchingSpec.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class RouterBranchingSpec: QuickSpec {

    override func spec() {

        describe("Router") {

            // MARK: branch segment route execution tests

            context("when executing simple, branch segment route") {

                let mockTabBarController = MockTabBarController("TBC")
                let mockViewController = MockViewController("VISUAL")
                var mockVisualRouteSegmentPresenter: MockVisualRouteSegmentPresenter!
                var mockBranchRouteSegmentPresenter: MockBranchRouteSegmentPresenter!
                var mockTrunkRouteSegment: MockTrunkRouteSegment!
                var mockBranchRouteSegment: MockBranchRouteSegment!
                var mockVisualRouteSegment: MockVisualRouteSegment!
                var router: Router!
                var validSequence:[Any]!

                beforeEach {
                    mockVisualRouteSegmentPresenter = MockVisualRouteSegmentPresenter(presenterIdentifier: "VISUAL", completionBlockArg: true)
                    mockBranchRouteSegmentPresenter = MockBranchRouteSegmentPresenter(presenterIdentifier: "BRANCH", completionBlockArg: true)
                    mockTrunkRouteSegment = MockTrunkRouteSegment(segmentIdentifier: Identifier(name: mockTabBarController.name), presenterIdentifier: mockVisualRouteSegmentPresenter.presenterIdentifier, trunkRouteController: mockTabBarController, presentedViewController: mockTabBarController)
                    mockBranchRouteSegment = MockBranchRouteSegment(segmentIdentifier: Identifier(name: "BRANCH"), presenterIdentifier: mockBranchRouteSegmentPresenter.presenterIdentifier)
                    mockVisualRouteSegment = MockVisualRouteSegment(segmentIdentifier: Identifier(name: mockViewController.name), presenterIdentifier: mockVisualRouteSegmentPresenter.presenterIdentifier, presentedViewController: mockViewController)
                    router = Router(window: nil)
                    router.registerPresenter(mockVisualRouteSegmentPresenter)
                    router.registerPresenter(mockBranchRouteSegmentPresenter)
                    router.registerRouteSegment(mockTrunkRouteSegment)
                    router.registerRouteSegment(mockBranchRouteSegment)
                    router.registerRouteSegment(mockVisualRouteSegment)
                    validSequence = [
                        mockTrunkRouteSegment.segmentIdentifier,
                        mockBranchRouteSegment.segmentIdentifier,
                        mockVisualRouteSegment.segmentIdentifier
                    ]
                }

                context("with a valid sequence") {

                    it("should succeed") {
                        let expectation = self.expectationWithDescription("executeRoute completion callback")
                        router.executeRoute(validSequence) {
                            routingResult in
                            switch routingResult {
                            case .Success(let finalViewController):
                                expect(finalViewController).to(equal(mockViewController))
                            case .Failure(let error):
                                fail("Did not expect error: \(error)")
                            }
                            expectation.fulfill()
                        }
                        self.waitForExpectationsWithTimeout(5, handler: nil)
                    }

//                    it("should produce full sequence") {
//                        router.executeRoute(validSequence) {
//                            _ in
//                        }
//                        expect(router.viewControllers).to(equal([mockTabBarController,mockViewController]))
//                    }
//
//                    it("should have one tab on tabBarController") {
//                        expect(mockTabBarController.viewControllers).to(equal([mockViewController]))
//                    }

                }

            }

        }
        
    }
}
