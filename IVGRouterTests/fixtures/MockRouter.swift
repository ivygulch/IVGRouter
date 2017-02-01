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

    let historySize = 10
    let defaultRouteBranch: RouteBranchType = RouteBranch(branchIdentifier: Identifier(name: UUID().uuidString), routeSequence: RouteSequence(source: []))

    var window: UIWindow? { return track("window", andReturn: nil) }

    var routeSegments: [Identifier: RouteSegmentType] { return track("routeSegments", andReturn: [: ]) }
    var routeBranches: [Identifier: RouteBranchType] { return track("routeBranches", andReturn: [: ]) }
    var presenters: [Identifier: RouteSegmentPresenterType] { return track("presenters", andReturn: [: ]) }

    func register(routeSegmentPresenter: RouteSegmentPresenterType) {
        track("registerPresenter", [String(describing: routeSegmentPresenter)])
    }

    func register(routeSegment: RouteSegmentType) {
        track("registerRouteSegment", [String(describing: routeSegment)])
    }

    func register(routeBranch: RouteBranchType) {
        track("registerRouteBranch", [String(describing: routeBranch)])
    }

    func append(route source: [Any], toRouteBranch routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void)) {
        track("appendRoute: appendRoute", [String(describing: source), String(describing: routeBranch)])
    }

    func clearHistory(onRouteBranch routeBranch: RouteBranchType) {
        track("clearHistory", [String(describing: routeBranch)])
    }

    func previousRouteHistoryItem(onRouteBranch routeBranch: RouteBranchType) -> RouteHistoryItemType? {
        track("previousRouteHistoryItem", [String(describing: routeBranch)])
        return nil
    }

    func nextRouteHistoryItem(onRouteBranch routeBranch: RouteBranchType) -> RouteHistoryItemType? {
        track("nextRouteHistoryItem", [String(describing: routeBranch)])
        return nil
    }

    func goBack(onRouteBranch routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void)) {
        track("goBack", [String(describing: routeBranch)])
    }

    func execute(route source: [Any], toRouteBranch routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void)) {
        track("executeRoute: routeBranch", [String(describing: source), String(describing: routeBranch)])
    }

    func execute(routeSequence: RouteSequence, routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void)) {
        track("executeRouteSequence", [String(describing: routeSequence), String(describing: routeBranch)])
    }

    func pop(fromRouteBranch routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void)) {
        track("popRoute: routeBranch", [String(describing: routeBranch)])
    }

    func registerDefaultPresenters() {
        track("registerDefaultPresenters", [])
    }

    func viewControllers(forRouteBranchIdentifier branchIdentifier: Identifier) -> [UIViewController] {
        track("viewControllersForRouteBranchIdentifier", [String(describing: branchIdentifier)])
        return []
    }

}
