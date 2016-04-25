//
//  RouteBranch.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public protocol RouteBranchType: RouteSequenceType {
}

public class RouteBranch: RouteSequence, RouteBranchType {

    public override func validatedRouteSegmentsWithRouter(router: RouterType) -> [RouteSegmentType]? {
        guard let routeSegments = super.validatedRouteSegmentsWithRouter(router) else {
            return nil // not a valid sequence
        }

        var routeSegmentStack = routeSegments
        guard let _ = routeSegmentStack.popLast() as? BranchedRouteSegmentType else {
            return nil // last segment must be Branched
        }
        guard let _ = routeSegmentStack.popLast() as? BranchingRouteSegmentType else {
            return nil // next to last segment must be Branching
        }
        return routeSegments
    }
}
