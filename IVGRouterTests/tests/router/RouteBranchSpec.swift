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
            let mockVisualRouteSegment = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "VISUAL"), presenterIdentifier: dummyIdentifier, presentedViewController: nil)
            let mockBranchingRouteSegment = MockBranchingRouteSegment(segmentIdentifier: Identifier(name: "BRANCHING"), presenterIdentifier: dummyIdentifier, presentedViewController: nil)
            let mockBranchedRouteSegment = MockBranchedRouteSegment(segmentIdentifier: Identifier(name: "BRANCHED"), presenterIdentifier: dummyIdentifier)

            beforeEach {
                router = Router(window: nil)
            }

            context("with valid registered segments") {

                var routeBranch: RouteBranch!
                var validatedRouteSegments: [RouteSegmentType]?

                beforeEach {
                    router = Router(window: nil)
                    router.registerRouteSegment(mockVisualRouteSegment)
                    router.registerRouteSegment(mockBranchingRouteSegment)
                    router.registerRouteSegment(mockBranchedRouteSegment)
                    routeBranch = RouteBranch(segmentIdentifiers: [
                        mockVisualRouteSegment.segmentIdentifier,
                        mockBranchingRouteSegment.segmentIdentifier,
                        mockBranchedRouteSegment.segmentIdentifier
                        ])
                    validatedRouteSegments = routeBranch.validatedRouteSegmentsWithRouter(router)
                }

                it("should have matching route segments") {
                    if let validatedRouteSegments = validatedRouteSegments {
                        expect(validatedRouteSegments).to(haveCount(routeBranch.segmentIdentifiers.count))
                        for index in 0..<routeBranch.segmentIdentifiers.count {
                            if index < validatedRouteSegments.count {
                                let segmentIdentifier = routeBranch.segmentIdentifiers[index]
                                let validatedRouteSegment = validatedRouteSegments[index]
                                expect(validatedRouteSegment.segmentIdentifier).to(equal(segmentIdentifier))
                            }
                        }
                    } else {
                        expect(validatedRouteSegments).toNot(beNil())
                    }
                }
                
            }

            context("with valid but unregistered segments") {

                var routeBranch: RouteBranch!
                var validatedRouteSegments: [RouteSegmentType]?

                beforeEach {
                    router = Router(window: nil)
                    routeBranch = RouteBranch(segmentIdentifiers: [
                        mockVisualRouteSegment.segmentIdentifier,
                        mockBranchingRouteSegment.segmentIdentifier,
                        mockBranchedRouteSegment.segmentIdentifier
                        ])
                    validatedRouteSegments = routeBranch.validatedRouteSegmentsWithRouter(router)
                }

                it("should not have validated route segments") {
                    expect(validatedRouteSegments).to(beNil())
                }
                
            }

            context("with missing branched segment") {

                var routeBranch: RouteBranch!
                var validatedRouteSegments: [RouteSegmentType]?

                beforeEach {
                    router = Router(window: nil)
                    routeBranch = RouteBranch(segmentIdentifiers: [
                        mockVisualRouteSegment.segmentIdentifier,
                        mockBranchingRouteSegment.segmentIdentifier,
                        ])
                    validatedRouteSegments = routeBranch.validatedRouteSegmentsWithRouter(router)
                }

                it("should not have validated route segments") {
                    expect(validatedRouteSegments).to(beNil())
                }
                
            }

            context("with missing branching segment") {

                var routeBranch: RouteBranch!
                var validatedRouteSegments: [RouteSegmentType]?

                beforeEach {
                    router = Router(window: nil)
                    routeBranch = RouteBranch(segmentIdentifiers: [
                        mockVisualRouteSegment.segmentIdentifier,
                        mockBranchingRouteSegment.segmentIdentifier,
                        ])
                    validatedRouteSegments = routeBranch.validatedRouteSegmentsWithRouter(router)
                }

                it("should not have validated route segments") {
                    expect(validatedRouteSegments).to(beNil())
                }
                
            }

            context("with out of order branching/branched segment") {

                var routeBranch: RouteBranch!
                var validatedRouteSegments: [RouteSegmentType]?

                beforeEach {
                    router = Router(window: nil)
                    routeBranch = RouteBranch(segmentIdentifiers: [
                        mockBranchingRouteSegment.segmentIdentifier,
                        mockBranchedRouteSegment.segmentIdentifier,
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
