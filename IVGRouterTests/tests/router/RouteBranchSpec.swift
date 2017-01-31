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
            let mockTrunkRouteSegment = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "Trunk"), presenterIdentifier: dummyIdentifier, presentedViewController: mockTabBarController)
            let mockBranchRouteSegment = MockBranchRouteSegment(segmentIdentifier: Identifier(name: "Branch"), presenterIdentifier: dummyIdentifier)

            beforeEach {
                router = Router(window: nil)
            }

            context("with valid registered segments") {

                var routeBranch: RouteBranch!

                beforeEach {
                    router = Router(window: nil)
                    router.register(routeSegment: mockVisualRouteSegment)
                    router.register(routeSegment: mockTrunkRouteSegment)
                    router.register(routeSegment: mockBranchRouteSegment)
                    routeBranch = RouteBranch(
                        branchIdentifier: Identifier(name: "branch"),
                        routeSequence: RouteSequence(source: [
                            mockVisualRouteSegment.segmentIdentifier,
                            mockTrunkRouteSegment.segmentIdentifier,
                            mockBranchRouteSegment.segmentIdentifier
                            ])
                    )
                }

                it("should validate routeSeqeuence") {
                    expect(routeBranch.validateRouteSequence(withRouter: router)).to(beTrue())
                }

            }

            context("with missing branch segment") {

                var routeBranch: RouteBranch!

                beforeEach {
                    router = Router(window: nil)
                    routeBranch = RouteBranch(
                        branchIdentifier: Identifier(name: "branch"),
                        routeSequence: RouteSequence(source: [
                            mockVisualRouteSegment.segmentIdentifier,
                            mockTrunkRouteSegment.segmentIdentifier
                            ])
                    )
                }

                it("should not validate routeSeqeuence") {
                    expect(routeBranch.validateRouteSequence(withRouter: router)).to(beFalse())
                }

            }

            context("with out of order trunk/branch segment") {

                var routeBranch: RouteBranch!

                beforeEach {
                    router = Router(window: nil)
                    routeBranch = RouteBranch(
                        branchIdentifier: Identifier(name: "branch"),
                        routeSequence: RouteSequence(source: [
                        mockTrunkRouteSegment.segmentIdentifier,
                        mockBranchRouteSegment.segmentIdentifier,
                        mockVisualRouteSegment.segmentIdentifier
                            ])
                    )
                }

                it("should not validate routeSeqeuence") {
                    expect(routeBranch.validateRouteSequence(withRouter: router)).to(beFalse())
                }

            }

        }

    }
}
