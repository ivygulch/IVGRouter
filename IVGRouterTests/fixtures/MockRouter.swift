//
//  MockRouter.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 7/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Quick
import Nimble
import IVGRouter

class MockRouter: TrackableTestClass, RouterContextType, RouterType {

    let historySize = 10

    var routerContext: RouterContextType { return self }
    var window: UIWindow? { return track("window", andReturn: nil) }

    var routeSegments: [Identifier: RouteSegmentType] { return track("routeSegments", andReturn: [: ]) }
    var presenters: [Identifier: RouteSegmentPresenterType] { return track("presenters", andReturn: [: ]) }

    func register(routeSegmentPresenter: RouteSegmentPresenterType) {
        track("registerPresenter", [String(describing: routeSegmentPresenter)])
    }

    func register(routeSegment: RouteSegmentType) {
        track("registerRouteSegment", [String(describing: routeSegment)])
    }

    func append(route source: [Any], completion: @escaping ((RoutingResult) -> Void)) {
        track("appendRoute: appendRoute", [String(describing: source)])
    }

    func clearHistory() {
        track("clearHistory", [])
    }

    func previousRouteHistoryItem() -> RouteHistoryItemType? {
        track("previousRouteHistoryItem", [])
        return nil
    }

    func nextRouteHistoryItem() -> RouteHistoryItemType? {
        track("nextRouteHistoryItem", [])
        return nil
    }

    func goBack(completion: @escaping ((RoutingResult) -> Void)) {
        track("goBack", [])
    }

    func execute(route source: [Any], completion: @escaping ((RoutingResult) -> Void)) {
        track("executeRoute", [String(describing: source)])
    }

    func execute(routeSequence: RouteSequence, completion: @escaping ((RoutingResult) -> Void)) {
        track("executeRouteSequence", [String(describing: routeSequence)])
    }

    func pop(completion: @escaping ((RoutingResult) -> Void)) {
        track("popRoute", [])
    }

    func registerDefaultPresenters() {
        track("registerDefaultPresenters", [])
    }

    func viewControllers() -> [UIViewController] {
        track("viewControllers", [])
        return []
    }

}
