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

class MockRouter : TrackableTestClass, RouterType {

    let defaultRouteBranch: RouteBranchType = RouteBranch(branchIdentifier: Identifier(name: UUID().uuidString), routeSequence: RouteSequence(source: []))

    var window: UIWindow? { return track("window", andReturn: nil) }

    var routeSegments: [Identifier: RouteSegmentType] { return track("routeSegments", andReturn: [: ]) }
    var routeBranches: [Identifier: RouteBranchType] { return track("routeBranches", andReturn: [: ]) }
    var presenters: [Identifier: RouteSegmentPresenterType] { return track("presenters", andReturn: [: ]) }

    func registerPresenter(_ presenter: RouteSegmentPresenterType) {
        track("registerPresenter", [String(describing: presenter)])
    }

    func registerRouteSegment(_ routeSegment: RouteSegmentType) {
        track("registerRouteSegment", [String(describing: routeSegment)])
    }

    func registerRouteBranch(_ routeBranch: RouteBranchType) {
        track("registerRouteBranch", [String(describing: routeBranch)])
    }

    func appendRoute(_ source: [Any], routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void)) {
        track("appendRoute: appendRoute", [String(describing: source), String(describing: routeBranch)])
    }

    func clearHistory(_ routeBranch: RouteBranchType) {
        track("clearHistory", [String(describing: routeBranch)])
    }

    func previousRouteHistoryItem(_ routeBranch: RouteBranchType) -> RouteHistoryItemType? {
        track("previousRouteHistoryItem", [String(describing: routeBranch)])
        return nil
    }

    func nextRouteHistoryItem(_ routeBranch: RouteBranchType) -> RouteHistoryItemType? {
        track("nextRouteHistoryItem", [String(describing: routeBranch)])
        return nil
    }

    func goBack(_ routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void)) {
        track("goBack", [String(describing: routeBranch)])
    }

    func goForward(_ routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void)) {
        track("goForward", [String(describing: routeBranch)])
    }

    func executeRoute(_ source: [Any], routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void)) {
        track("executeRoute: routeBranch", [String(describing: source), String(describing: routeBranch)])
    }

    func executeRouteSequence(_ routeSequence: RouteSequence, routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void)) {
        track("executeRouteSequence", [String(describing: routeSequence), String(describing: routeBranch)])
    }

    func popRoute(_ routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void)) {
        track("popRoute: routeBranch", [String(describing: routeBranch)])
    }

    func registerDefaultPresenters() {
        track("registerDefaultPresenters", [])
    }

    func viewControllersForRouteBranchIdentifier(_ branchIdentifier: Identifier) -> [UIViewController] {
        track("viewControllersForRouteBranchIdentifier", [String(describing: branchIdentifier)])
        return []
    }

}
