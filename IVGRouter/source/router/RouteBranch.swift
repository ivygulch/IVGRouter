//
//  RouteBranch.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public protocol RouteBranchType {
    var branchIdentifier: Identifier { get }
    var routeSequence: RouteSequence { get }
    func validateRouteSequenceWithRouter(_ router: RouterType) -> Bool
}

open class RouteBranch: RouteBranchType {

    open func validateRouteSequenceWithRouter(_ router: RouterType) -> Bool {
        guard let routeSegments = routeSequence.validatedRouteSegmentsWithRouter(router) else {
            return false // not a valid sequence
        }

        var routeSegmentStack = routeSegments
        guard let _ = routeSegmentStack.popLast() as? BranchRouteSegmentType else {
            return false // last segment must be Branch
        }

        return true
    }

    public init(branchIdentifier: Identifier, routeSequence: RouteSequence) {
        self.branchIdentifier = branchIdentifier
        self.routeSequence = routeSequence
    }

    open let branchIdentifier: Identifier
    open let routeSequence: RouteSequence
}
