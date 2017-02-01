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
                routerHistory = RouterHistory(historySize: 10)
            }

            context("when initialized") {

                it("should return nil for previousRouteHistoryItem") {
                    expect(routerHistory.previousRouteHistoryItem).to(beNil())
                }

            }

            context("after moving forward one step") {

                beforeEach {
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemA, ignoreDuplicates: false)
                }

                it("should return nil for previousRouteHistoryItem") {
                    expect(routerHistory.previousRouteHistoryItem).to(beNil())
                }

            }

            context("after moving forward two steps") {

                beforeEach {
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemA, ignoreDuplicates: false)
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemB, ignoreDuplicates: false)
                }

                it("should return A for previousRouteHistoryItem") {
                    expect(routerHistory.previousRouteHistoryItem as? RouteHistoryItem).to(equal(mockRouteHistoryItemA))
                }

            }

            context("after moving forward two steps, then back one") {

                beforeEach {
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemA, ignoreDuplicates: false)
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemB, ignoreDuplicates: false)
                    routerHistory.moveBackward()
                }

                it("should return nil for previousRouteHistoryItem") {
                    expect(routerHistory.previousRouteHistoryItem).to(beNil())
                }

            }

            context("after moving forward three steps, then back one") {

                beforeEach {
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemA, ignoreDuplicates: false)
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemB, ignoreDuplicates: false)
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemC, ignoreDuplicates: false)
                    routerHistory.moveBackward()
                }

                it("should return A for previousRouteHistoryItem") {
                    expect(routerHistory.previousRouteHistoryItem as? RouteHistoryItem).to(equal(mockRouteHistoryItemA))
                }

            }

            context("after moving forward four steps, then back two, then forward with same as before") {

                beforeEach {
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemA, ignoreDuplicates: false)
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemB, ignoreDuplicates: false)
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemC, ignoreDuplicates: false)
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemD, ignoreDuplicates: false)
                    routerHistory.moveBackward()
                    routerHistory.moveBackward()
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemC, ignoreDuplicates: false)
                }

                it("should return B for previousRouteHistoryItem") {
                    expect(routerHistory.previousRouteHistoryItem as? RouteHistoryItem).to(equal(mockRouteHistoryItemB))
                }

            }

            context("after moving forward four steps, then back two, then forward with different from before") {

                beforeEach {
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemA, ignoreDuplicates: false)
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemB, ignoreDuplicates: false)
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemC, ignoreDuplicates: false)
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemD, ignoreDuplicates: false)
                    routerHistory.moveBackward()
                    routerHistory.moveBackward()
                    routerHistory.recordRouteHistoryItem(mockRouteHistoryItemE, ignoreDuplicates: false)
                }

                it("should return B for previousRouteHistoryItem") {
                    expect(routerHistory.previousRouteHistoryItem as? RouteHistoryItem).to(equal(mockRouteHistoryItemB))
                }

            }

        }
    }
}

