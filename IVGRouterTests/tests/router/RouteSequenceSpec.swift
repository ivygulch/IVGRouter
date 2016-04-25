//
//  RouteSequenceSpec.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class RouteSequenceSpec: QuickSpec {

    override func spec() {

        describe("RouteSequence") {

            var router: Router = Router(window: nil)
            let dummyIdentifier = Identifier(name: "dummy")
            let mockVisualRouteSegmentA = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "A"), presenterIdentifier: dummyIdentifier, presentedViewController: nil)
            let mockVisualRouteSegmentB = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "B"), presenterIdentifier: dummyIdentifier, presentedViewController: nil)

            beforeEach {
                router = Router(window: nil)
            }

            context("with valid registered segments") {

                var routeSequence: RouteSequence!
                var validatedRouteSegments: [RouteSegmentType]?

                beforeEach {
                    router = Router(window: nil)
                    router.registerRouteSegment(mockVisualRouteSegmentA)
                    router.registerRouteSegment(mockVisualRouteSegmentB)
                    routeSequence = RouteSequence(source: [
                        mockVisualRouteSegmentA.segmentIdentifier,
                        mockVisualRouteSegmentB.segmentIdentifier
                        ])
                    validatedRouteSegments = routeSequence.validatedRouteSegmentsWithRouter(router)
                }

                it("should have matching route segments") {
                    if let validatedRouteSegments = validatedRouteSegments {
                        expect(validatedRouteSegments).to(haveCount(routeSequence.items.count))
                        for index in 0..<routeSequence.items.count {
                            if index < validatedRouteSegments.count {
                                let segmentIdentifier = routeSequence.items[index].segmentIdentifier
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

                var routeSequence: RouteSequence!
                var validatedRouteSegments: [RouteSegmentType]?

                beforeEach {
                    router = Router(window: nil)
                    routeSequence = RouteSequence(source: [
                        mockVisualRouteSegmentA.segmentIdentifier,
                        mockVisualRouteSegmentB.segmentIdentifier
                        ])
                    validatedRouteSegments = routeSequence.validatedRouteSegmentsWithRouter(router)
                }

                it("should not have validated route segments") {
                    expect(validatedRouteSegments).to(beNil())
                }
                
            }

        }

    }
}
