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

    var window: UIWindow? { return track("window", andReturn: nil) }

    var routeSegments: [Identifier: RouteSegmentType] { return track("routeSegments", andReturn: [:]) }
    var routeBranches: [Identifier: RouteBranchType] { return track("routeBranches", andReturn: [:]) }
    var presenters: [Identifier: RouteSegmentPresenterType] { return track("presenters", andReturn: [:]) }

    func registerPresenter(presenter: RouteSegmentPresenterType) {
        track("registerPresenter", [String(presenter)])
    }

    func registerRouteSegment(routeSegment: RouteSegmentType) {
        track("registerRouteSegment", [String(routeSegment)])
    }

    func registerRouteBranch(routeBranch: RouteBranchType) {
        track("registerRouteBranch", [String(routeBranch)])
    }

    func appendRoute(source: [Any], completion:(RoutingResult -> Void)) {
        track("appendRoute", [String(source)])
    }

    func appendRoute(source: [Any], routeBranch: RouteBranchType, completion:(RoutingResult -> Void)) {
        track("appendRoute:appendRoute", [String(source), String(routeBranch)])
    }

    func previousRouteHistoryItem() -> RouteHistoryItemType? {
        track("previousRouteHistoryItem", [])
        return nil
    }

    func previousRouteHistoryItem(routeBranch: RouteBranchType) -> RouteHistoryItemType? {
        track("previousRouteHistoryItem", [String(routeBranch)])
        return nil
    }

    func nextRouteHistoryItem() -> RouteHistoryItemType? {
        track("nextRouteHistoryItem", [])
        return nil
    }

    func nextRouteHistoryItem(routeBranch: RouteBranchType) -> RouteHistoryItemType? {
        track("nextRouteHistoryItem", [String(routeBranch)])
        return nil
    }

    func goBack(completion:(RoutingResult -> Void)) {
        track("goBack", [])
    }

    func goBack(routeBranch: RouteBranchType, completion:(RoutingResult -> Void)) {
        track("goBack", [String(routeBranch)])
    }

    func goForward(completion:(RoutingResult -> Void)) {
        track("goForward", [])
    }

    func goForward(routeBranch: RouteBranchType, completion:(RoutingResult -> Void)) {
        track("goForward", [String(routeBranch)])
    }

    func executeRoute(source: [Any], completion:(RoutingResult -> Void)) {
        track("executeRoute", [String(source)])
    }

    func executeRoute(source: [Any], routeBranch: RouteBranchType, completion:(RoutingResult -> Void)) {
        track("executeRoute:routeBranch", [String(source), String(routeBranch)])
    }

    func executeRouteSequence(routeSequence: RouteSequence, routeBranch: RouteBranchType, completion:(RoutingResult -> Void)) {
        track("executeRouteSequence", [String(routeSequence), String(routeBranch)])
    }

    func popRoute(completion:(RoutingResult -> Void)) {
        track("popRoute", [])
    }

    func popRoute(routeBranch: RouteBranchType, completion:(RoutingResult -> Void)) {
        track("popRoute:routeBranch", [String(routeBranch)])
    }

    func registerDefaultPresenters() {
        track("registerDefaultPresenters", [])
    }

    func viewControllersForRouteBranchIdentifier(branchIdentifier: Identifier) -> [UIViewController] {
        track("viewControllersForRouteBranchIdentifier", [String(branchIdentifier)])
        return []
    }

}
