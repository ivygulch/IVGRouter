//
//  RouteBranchSpec.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class RouteBranchSpec: QuickSpec {

    override func spec() {

        describe("RouteBranch") {

            var router: Router = Router(window: nil)
            let dummyIdentifier = Identifier(name: "dummy")
            let mockTabBarController = MockTabBarController("TBC")
            let mockVisualRouteSegment = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "VISUAL"), presenterIdentifier: dummyIdentifier, presentedViewController: nil)
            let mockTrunkRouteSegment = MockTrunkRouteSegment(segmentIdentifier: Identifier(name: "Trunk"), presenterIdentifier: dummyIdentifier, trunkRouteController: mockTabBarController, presentedViewController: nil)
            let mockBranchRouteSegment = MockBranchRouteSegment(segmentIdentifier: Identifier(name: "Branch"), presenterIdentifier: dummyIdentifier)

            beforeEach {
                router = Router(window: nil)
            }

            context("with valid registered segments") {

                var routeBranch: RouteBranch!
                var validatedRouteSegments: [RouteSegmentType]?

                beforeEach {
                    router = Router(window: nil)
                    router.registerRouteSegment(mockVisualRouteSegment)
                    router.registerRouteSegment(mockTrunkRouteSegment)
                    router.registerRouteSegment(mockBranchRouteSegment)
                    routeBranch = RouteBranch(source: [
                        mockVisualRouteSegment.segmentIdentifier,
                        mockTrunkRouteSegment.segmentIdentifier,
                        mockBranchRouteSegment.segmentIdentifier
                        ])
                    validatedRouteSegments = routeBranch.validatedRouteSegmentsWithRouter(router)
                }

                it("should have matching route segments") {
                    if let validatedRouteSegments = validatedRouteSegments {
                        expect(validatedRouteSegments).to(haveCount(routeBranch.items.count))
                        for index in 0..<routeBranch.items.count {
                            if index < validatedRouteSegments.count {
                                let segmentIdentifier = routeBranch.items[index].segmentIdentifier
                                let validatedRouteSegment = validatedRouteSegments[index]
                                expect(validatedRouteSegment.segmentIdentifier).to(equal(segmentIdentifier))
                            }
                        }
                    } else {
                        expect(validatedRouteSegments).toNot(beNil())
                    }
                }
                
            }

            context("with missing branch segment") {

                var routeBranch: RouteBranch!
                var validatedRouteSegments: [RouteSegmentType]?

                beforeEach {
                    router = Router(window: nil)
                    routeBranch = RouteBranch(source: [
                        mockVisualRouteSegment.segmentIdentifier,
                        mockTrunkRouteSegment.segmentIdentifier,
                        ])
                    validatedRouteSegments = routeBranch.validatedRouteSegmentsWithRouter(router)
                }

                it("should not have validated route segments") {
                    expect(validatedRouteSegments).to(beNil())
                }
                
            }

            context("with missing trunk segment") {

                var routeBranch: RouteBranch!
                var validatedRouteSegments: [RouteSegmentType]?

                beforeEach {
                    router = Router(window: nil)
                    routeBranch = RouteBranch(source: [
                        mockVisualRouteSegment.segmentIdentifier,
                        mockTrunkRouteSegment.segmentIdentifier,
                        ])
                    validatedRouteSegments = routeBranch.validatedRouteSegmentsWithRouter(router)
                }

                it("should not have validated route segments") {
                    expect(validatedRouteSegments).to(beNil())
                }
                
            }

            context("with out of order trunk/branch segment") {

                var routeBranch: RouteBranch!
                var validatedRouteSegments: [RouteSegmentType]?

                beforeEach {
                    router = Router(window: nil)
                    routeBranch = RouteBranch(source: [
                        mockTrunkRouteSegment.segmentIdentifier,
                        mockBranchRouteSegment.segmentIdentifier,
                        mockVisualRouteSegment.segmentIdentifier
                        ])
                    validatedRouteSegments = routeBranch.validatedRouteSegmentsWithRouter(router)
                }

                it("should not have validated route segments") {
                    expect(validatedRouteSegments).to(beNil())
                }
                
            }

        }

    }
}
