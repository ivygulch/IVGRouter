//
//  RouteBranch.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public protocol RouteBranchType {
    var segmentIdentifiers: [Identifier] { get }
    func validatedRouteSegmentsWithRouter(router: RouterType) -> [RouteSegmentType]?
}

public class RouteBranch : RouteBranchType {

    public let segmentIdentifiers: [Identifier]

    public init(segmentIdentifiers: [Identifier]) {
        self.segmentIdentifiers = segmentIdentifiers
    }

    public func validatedRouteSegmentsWithRouter(router: RouterType) -> [RouteSegmentType]? {
        let routeSegments: [RouteSegmentType?] = segmentIdentifiers.map { router.routeSegments[$0] }
        let checkRouteSegments = routeSegments.flatMap { $0 }
        if routeSegments.count != checkRouteSegments.count {
            return nil // all the route segments must be registered
        }
        var routeSegmentStack = checkRouteSegments
        guard let _ = routeSegmentStack.popLast() as? BranchedRouteSegmentType else {
            return nil // last segment must be Branched
        }
        guard let _ = routeSegmentStack.popLast() as? BranchingRouteSegmentType else {
            return nil // next to last segment must be Branching
        }
        return checkRouteSegments
    }
}
