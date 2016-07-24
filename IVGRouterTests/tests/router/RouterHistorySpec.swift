//
//  RouterHistorySpec.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 7/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class RouterHistorySpec: QuickSpec {

    override func spec() {

        describe("Router") {

            let mockRouterSequenceA = RouteSequence(source: ["A"])
            let mockRouterSequenceB = RouteSequence(source: ["B"])
            let mockRouterSequenceC = RouteSequence(source: ["C"])
            let mockRouterSequenceD = RouteSequence(source: ["D"])
            let mockRouterSequenceE = RouteSequence(source: ["E"])
            var routerHistory: RouterHistory!

            beforeEach {
                routerHistory = RouterHistory()
            }

            context("when initialized") {

                it("should return nil for previousSequence") {
                    expect(routerHistory.previousSequence).to(beNil())
                }

                it("should return nil for nextSequence") {
                    expect(routerHistory.nextSequence).to(beNil())
                }

            }

            context("after moving forward one step") {

                beforeEach {
                    routerHistory.recordRouteSequence(mockRouterSequenceA)
                }

                it("should return nil for previousSequence") {
                    expect(routerHistory.previousSequence).to(beNil())
                }

                it("should return nil for nextSequence") {
                    expect(routerHistory.nextSequence).to(beNil())
                }
                
            }

            context("after moving forward two steps") {

                beforeEach {
                    routerHistory.recordRouteSequence(mockRouterSequenceA)
                    routerHistory.recordRouteSequence(mockRouterSequenceB)
                }

                it("should return A for previousSequence") {
                    expect(routerHistory.previousSequence).to(equal(mockRouterSequenceA))
                }

                it("should return nil for nextSequence") {
                    expect(routerHistory.nextSequence).to(beNil())
                }
                
            }

            context("after moving forward two steps, then back one") {

                beforeEach {
                    routerHistory.recordRouteSequence(mockRouterSequenceA)
                    routerHistory.recordRouteSequence(mockRouterSequenceB)
                    routerHistory.moveBackward()
                }

                it("should return nil for previousSequence") {
                    expect(routerHistory.previousSequence).to(beNil())
                }

                it("should return B for nextSequence") {
                    expect(routerHistory.nextSequence).to(equal(mockRouterSequenceB))
                }
                
            }

            context("after moving forward three steps, then back one") {

                beforeEach {
                    routerHistory.recordRouteSequence(mockRouterSequenceA)
                    routerHistory.recordRouteSequence(mockRouterSequenceB)
                    routerHistory.recordRouteSequence(mockRouterSequenceC)
                    routerHistory.moveBackward()
                }

                it("should return A for previousSequence") {
                    expect(routerHistory.previousSequence).to(equal(mockRouterSequenceA))
                }

                it("should return C for nextSequence") {
                    expect(routerHistory.nextSequence).to(equal(mockRouterSequenceC))
                }
                
            }

            context("after moving forward four steps, then back two, then forward with same as before") {

                beforeEach {
                    routerHistory.recordRouteSequence(mockRouterSequenceA)
                    routerHistory.recordRouteSequence(mockRouterSequenceB)
                    routerHistory.recordRouteSequence(mockRouterSequenceC)
                    routerHistory.recordRouteSequence(mockRouterSequenceD)
                    routerHistory.moveBackward()
                    routerHistory.moveBackward()
                    routerHistory.recordRouteSequence(mockRouterSequenceC)
                }

                it("should return B for previousSequence") {
                    expect(routerHistory.previousSequence).to(equal(mockRouterSequenceB))
                }

                it("should return D for nextSequence") {
                    expect(routerHistory.nextSequence).to(equal(mockRouterSequenceD))
                }
                
            }

            context("after moving forward four steps, then back two, then forward with different from before") {

                beforeEach {
                    routerHistory.recordRouteSequence(mockRouterSequenceA)
                    routerHistory.recordRouteSequence(mockRouterSequenceB)
                    routerHistory.recordRouteSequence(mockRouterSequenceC)
                    routerHistory.recordRouteSequence(mockRouterSequenceD)
                    routerHistory.moveBackward()
                    routerHistory.moveBackward()
                    routerHistory.recordRouteSequence(mockRouterSequenceE)
                }

                it("should return B for previousSequence") {
                    expect(routerHistory.previousSequence).to(equal(mockRouterSequenceB))
                }

                it("should return nil for nextSequence") {
                    expect(routerHistory.nextSequence).to(beNil())
                }
                
            }

        }
    }
}

