//
//  VisualRouteSegmentSpec.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/1/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class VisualRouteSegmentSpec: QuickSpec {

    override func spec() {

        describe("visualRouteSegment") {
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

                var visualRouteSegment: VisualRouteSegment!
                var loadedViewController: UIViewController?

                beforeEach {
                    visualRouteSegment = VisualRouteSegment(segmentIdentifier: mockIdentifier,
                        presenterIdentifier: mockIdentifier,
                        titleProducer: {
                            _ -> String in
                            return mockIdentifier.name
                        },
                        isSingleton: true,
                        loadViewController: mockViewControllerBLoader.load)
                    loadedViewController = visualRouteSegment.viewController()
                }

                it("should load mockViewControllerB once") {
                    expect(mockViewControllerBLoader.trackerKeyValues).to(equal(["load":[[mockViewControllerB.description]]]))
                    expect(loadedViewController).to(equal(mockViewControllerB))
                }
            }

            describe("present B from A twice with singleton loading") {

                var visualRouteSegment: VisualRouteSegment!

                beforeEach {
                    visualRouteSegment = VisualRouteSegment(segmentIdentifier: mockIdentifier,
                        presenterIdentifier: mockIdentifier,
                        titleProducer: {
                            _ -> String in
                            return mockIdentifier.name
                        },
                        isSingleton: true,
                        loadViewController: mockViewControllerBLoader.load)
                    visualRouteSegment.viewController()
                    visualRouteSegment.viewController()
                }

                it("should load mockViewControllerB just once") {
                    expect(mockViewControllerBLoader.trackerKeyValues).to(equal(["load":[[mockViewControllerB.description]]]))
                }

            }

            describe("present B from A twice without singleton loading") {

                var visualRouteSegment: VisualRouteSegment!

                beforeEach {
                    visualRouteSegment = VisualRouteSegment(segmentIdentifier: mockIdentifier,
                        presenterIdentifier: mockIdentifier,
                        titleProducer: {
                            _ -> String in
                            return mockIdentifier.name
                        },
                        isSingleton: false,
                        loadViewController: mockViewControllerBLoader.load)
                    visualRouteSegment.viewController()
                    visualRouteSegment.viewController()
                }

                it("should load mockViewControllerB twice") {
                    expect(mockViewControllerBLoader.trackerKeyValues).to(equal(["load":[[mockViewControllerB.description],[mockViewControllerB.description]]]))
                }

            }

            describe("present nil from A") {

                var visualRouteSegment: VisualRouteSegment!

                beforeEach {
                    visualRouteSegment = VisualRouteSegment(segmentIdentifier: mockIdentifier,
                        presenterIdentifier: mockIdentifier,
                        titleProducer: {
                            _ -> String in
                            return mockIdentifier.name
                        },
                        isSingleton: false,
                        loadViewController: mockNilViewControllerLoader.load)
                    visualRouteSegment.viewController()
                }

                it("load should return nil") {
                    expect(mockNilViewControllerLoader.trackerKeyValues).to(equal(["load":[["nil"]]]))
                }

            }
        }
        
    }
}