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
@testable import IVGRouter

class RouterHistorySpec: QuickSpec {

    override func spec() {

        describe("Router") {

            let mockRouteHistoryItemA = RouteHistoryItem(routeSequence: RouteSequence(source: ["A"]), title: "title A")
            let mockRouteHistoryItemB = RouteHistoryItem(routeSequence: RouteSequence(source: ["B"]), title: "title B")
            let mockRouteHistoryItemC = RouteHistoryItem(routeSequence: RouteSequence(source: ["C"]), title: "title C")
            let mockRouteHistoryItemD = RouteHistoryItem(routeSequence: RouteSequence(source: ["D"]), title: "title D")
            let mockRouteHistoryItemE = RouteHistoryItem(routeSequence: RouteSequence(source: ["E"]), title: "title E")
            var routerHistory: RouterHistory!

            beforeEach {
                routerHistory = RouterHistory()
            }

            context("when initialized") {

                it("should return nil for previousRouteHistoryItem") {
                    expect(routerHistory.previousRouteHistoryItem).to(beNil())
                }

                it("should return nil for nextRouteHistoryItem") {
                    expect(routerHistory.nextRouteHistoryItem).to(beNil())
                }

            }

            context("after moving forward one step") {

                beforeEach {
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemA)
                }

                it("should return nil for previousRouteHistoryItem") {
                    expect(routerHistory.previousRouteHistoryItem).to(beNil())
                }

                it("should return nil for nextRouteHistoryItem") {
                    expect(routerHistory.nextRouteHistoryItem).to(beNil())
                }
                
            }

            context("after moving forward two steps") {

                beforeEach {
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemA)
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemB)
                }

                it("should return A for previousRouteHistoryItem") {
                    expect(routerHistory.previousRouteHistoryItem as? RouteHistoryItem).to(equal(mockRouteHistoryItemA))
                }

                it("should return nil for nextRouteHistoryItem") {
                    expect(routerHistory.nextRouteHistoryItem).to(beNil())
                }
                
            }

            context("after moving forward two steps, then back one") {

                beforeEach {
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemA)
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemB)
                    routerHistory.moveBackward()
                }

                it("should return nil for previousRouteHistoryItem") {
                    expect(routerHistory.previousRouteHistoryItem).to(beNil())
                }

                it("should return B for nextRouteHistoryItem") {
                    expect(routerHistory.nextRouteHistoryItem as? RouteHistoryItem).to(equal(mockRouteHistoryItemB))
                }
                
            }

            context("after moving forward three steps, then back one") {

                beforeEach {
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemA)
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemB)
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemC)
                    routerHistory.moveBackward()
                }

                it("should return A for previousRouteHistoryItem") {
                    expect(routerHistory.previousRouteHistoryItem as? RouteHistoryItem).to(equal(mockRouteHistoryItemA))
                }

                it("should return C for nextRouteHistoryItem") {
                    expect(routerHistory.nextRouteHistoryItem as? RouteHistoryItem).to(equal(mockRouteHistoryItemC))
                }
                
            }

            context("after moving forward four steps, then back two, then forward with same as before") {

                beforeEach {
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemA)
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemB)
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemC)
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemD)
                    routerHistory.moveBackward()
                    routerHistory.moveBackward()
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemC)
                }

                it("should return B for previousRouteHistoryItem") {
                    expect(routerHistory.previousRouteHistoryItem as? RouteHistoryItem).to(equal(mockRouteHistoryItemB))
                }

                it("should return D for nextRouteHistoryItem") {
                    expect(routerHistory.nextRouteHistoryItem as? RouteHistoryItem).to(equal(mockRouteHistoryItemD))
                }
                
            }

            context("after moving forward four steps, then back two, then forward with different from before") {

                beforeEach {
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemA)
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemB)
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemC)
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemD)
                    routerHistory.moveBackward()
                    routerHistory.moveBackward()
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemE)
                }

                it("should return B for previousRouteHistoryItem") {
                    expect(routerHistory.previousRouteHistoryItem as? RouteHistoryItem).to(equal(mockRouteHistoryItemB))
                }

                it("should return nil for nextRouteHistoryItem") {
                    expect(routerHistory.nextRouteHistoryItem).to(beNil())
                }
                
            }

        }
    }
}

