//
//  RouteSequence.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public protocol RouteSequenceType {
    var items: [RouteSequenceItemType] { get }
    func validatedRouteSegmentsWithRouter(router: RouterType) -> [RouteSegmentType]?
}

public class RouteSequence : RouteSequenceType {

    public var items: [RouteSequenceItemType] = []

    public init(source: [Any]) {
        self.items = source.map { RouteSequenceItem.transform($0) }.flatMap { $0 }
    }

    public func validatedRouteSegmentsWithRouter(router: RouterType) -> [RouteSegmentType]? {
        let routeSegments: [RouteSegmentType?] = items.map { router.routeSegments[$0.segmentIdentifier] }
        let checkRouteSegments = routeSegments.flatMap { $0 }
        if routeSegments.count != checkRouteSegments.count {
            return nil // all the route segments must be registered
        }
        return checkRouteSegments
    }

}
