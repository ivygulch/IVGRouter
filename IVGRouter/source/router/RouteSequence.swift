//
//  RouteSequence.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public class RouteSequence : Equatable, CustomStringConvertible {

    public var items: [RouteSequenceItem] = []

    public init(source: [Any]) {
        self.items = source.map { RouteSequenceItem.transform($0) }.flatMap { $0 }
    }

    public func validatedRouteSegmentsWithRouter(_ router: RouterType) -> [RouteSegmentType]? {
        let routeSegments: [RouteSegmentType?] = items.map { router.routeSegments[$0.segmentIdentifier] }
        let checkRouteSegments = routeSegments.flatMap { $0 }
        if routeSegments.count != checkRouteSegments.count {
            return nil // all the route segments must be registered
        }
        return checkRouteSegments
    }

    public var description: String {
        return String(describing: items)
    }

}

public func ==(lhs: RouteSequence, rhs: RouteSequence) -> Bool {
    return lhs.items == rhs.items
}
