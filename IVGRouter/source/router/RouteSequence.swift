//
//  RouteSequence.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

open class RouteSequence : Equatable, CustomStringConvertible {

    open var items: [RouteSequenceItem] = []

    public init(source: [Any]) {
        self.items = source.map { RouteSequenceItem.transform($0) }.flatMap { $0 }
    }

    open func validatedRouteSegmentsWithRouter(_ router: RouterType) -> [RouteSegmentType]? {
        let routeSegments: [RouteSegmentType?] = items.map { router.routeSegments[$0.segmentIdentifier] }
        let checkRouteSegments = routeSegments.flatMap { $0 }
        if routeSegments.count != checkRouteSegments.count {
            return nil // all the route segments must be registered
        }
        return checkRouteSegments
    }

    open var description: String {
        return String(describing: items)
    }

}

public func ==(lhs: RouteSequence, rhs: RouteSequence) -> Bool {
    return lhs.items == rhs.items
}
