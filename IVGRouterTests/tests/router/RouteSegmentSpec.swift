//
//  RouteSegmentSpec.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/1/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class RouteSegmentSpec: QuickSpec {

    override func spec() {

        describe("routeSegment") {
            var mockIdentifier: Identifier!
            var mockViewControllerB: MockViewController!

            var mockViewControllerBLoader: MockViewControllerLoader!
            var mockNilViewControllerLoader: MockViewControllerLoader!

            beforeEach {
                mockIdentifier = Identifier(name: "mockIdentifier")
                mockViewControllerB = MockViewController("mockViewControllerB")
                mockViewControllerBLoader = MockViewControllerLoader(viewController: mockViewControllerB)
                mockNilViewControllerLoader = MockViewControllerLoader(viewController: nil)
            }

            describe("present B from A once with singleton loading") {

                var routeSegment: RouteSegment!
                var loadedViewController: UIViewController?

                beforeEach {
                    routeSegment = RouteSegment(segmentIdentifier: mockIdentifier,
                        presenterIdentifier: mockIdentifier,
                        isSingleton: true,
                        loadViewController: mockViewControllerBLoader.load)
                    loadedViewController = routeSegment.viewController()
                }

                it("should load mockViewControllerB once") {
                    expect(mockViewControllerBLoader.trackerKeyValues).to(equal(["load":[[mockViewControllerB.description]]]))
                    expect(loadedViewController).to(equal(mockViewControllerB))
                }
            }

            describe("present B from A twice with singleton loading") {

                var routeSegment: RouteSegment!

                beforeEach {
                    routeSegment = RouteSegment(segmentIdentifier: mockIdentifier,
                        presenterIdentifier: mockIdentifier,
                        isSingleton: true,
                        loadViewController: mockViewControllerBLoader.load)
                    routeSegment.viewController()
                    routeSegment.viewController()
                }

                it("should load mockViewControllerB just once") {
                    expect(mockViewControllerBLoader.trackerKeyValues).to(equal(["load":[[mockViewControllerB.description]]]))
                }

            }

            describe("present B from A twice without singleton loading") {

                var routeSegment: RouteSegment!

                beforeEach {
                    routeSegment = RouteSegment(segmentIdentifier: mockIdentifier,
                        presenterIdentifier: mockIdentifier,
                        isSingleton: false,
                        loadViewController: mockViewControllerBLoader.load)
                    routeSegment.viewController()
                    routeSegment.viewController()
                }

                it("should load mockViewControllerB twice") {
                    expect(mockViewControllerBLoader.trackerKeyValues).to(equal(["load":[[mockViewControllerB.description],[mockViewControllerB.description]]]))
                }

            }

            describe("present nil from A") {

                var routeSegment: RouteSegment!

                beforeEach {
                    routeSegment = RouteSegment(segmentIdentifier: mockIdentifier,
                        presenterIdentifier: mockIdentifier,
                        isSingleton: false,
                        loadViewController: mockNilViewControllerLoader.load)
                    routeSegment.viewController()
                }

                it("load should return nil") {
                    expect(mockNilViewControllerLoader.trackerKeyValues).to(equal(["load":[["nil"]]]))
                }

            }
        }
        
    }
}