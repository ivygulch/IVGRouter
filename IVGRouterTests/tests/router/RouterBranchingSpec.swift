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

            // MARK: branched segment route execution tests

            context("when executing simple, branched segment route") {

                let mockTabBarController = MockTabBarController("TBC")
                let mockViewController = MockViewController("VISUAL")
                var mockVisualRouteSegmentPresenter: MockVisualRouteSegmentPresenter!
                var mockBranchedRouteSegmentPresenter: MockBranchedRouteSegmentPresenter!
                var mockBranchingRouteSegment: MockBranchingRouteSegment!
                var mockBranchedRouteSegment: MockBranchedRouteSegment!
                var mockVisualRouteSegment: MockVisualRouteSegment!
                var router: Router!
                var validSequence:[Any]!

                beforeEach {
                    mockVisualRouteSegmentPresenter = MockVisualRouteSegmentPresenter(presenterIdentifier: "Success", completionBlockArg: true)
                    mockBranchedRouteSegmentPresenter = MockBranchedRouteSegmentPresenter(presenterIdentifier: "Success", completionBlockArg: true)
                    mockBranchingRouteSegment = MockBranchingRouteSegment(segmentIdentifier: Identifier(name: mockTabBarController.name), presenterIdentifier: mockVisualRouteSegmentPresenter.presenterIdentifier, presentedViewController: mockTabBarController)
                    mockBranchedRouteSegment = MockBranchedRouteSegment(segmentIdentifier: Identifier(name: "BRANCH"), presenterIdentifier: mockBranchedRouteSegmentPresenter.presenterIdentifier)
                    mockVisualRouteSegment = MockVisualRouteSegment(segmentIdentifier: Identifier(name: mockViewController.name), presenterIdentifier: mockVisualRouteSegmentPresenter.presenterIdentifier, presentedViewController: mockViewController)
                    router = Router(window: nil)
                    router.registerPresenter(mockVisualRouteSegmentPresenter)
                    router.registerPresenter(mockBranchedRouteSegmentPresenter)
                    router.registerRouteSegment(mockBranchingRouteSegment)
                    router.registerRouteSegment(mockBranchedRouteSegment)
                    router.registerRouteSegment(mockVisualRouteSegment)
                    validSequence = [mockBranchingRouteSegment.segmentIdentifier,mockBranchedRouteSegment.segmentIdentifier,mockVisualRouteSegment]
                }

                context("with a valid sequence") {
/*
                    it("should succeed") {
                        let success = router.executeRoute(validSequence)
                        expect(success).to(beTrue())
                    }

                    it("should produce full sequence") {
                        router.executeRoute(validSequence)
                        expect(router.viewControllers).to(equal([mockTabBarController,mockViewController]))
                    }

                    it("should have one tab on tabBarController") {
                        expect(mockTabBarController.viewControllers).to(equal([mockViewController]))
                    }
*/
                }

            }

        }
        
    }
}
