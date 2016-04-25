//
//  RouteSequence.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public protocol RouteSequenceType {
    var items: [RouteSequenceItem] { get }
    func validatedRouteSegmentsWithRouter(router: RouterType) -> [RouteSegmentType]?
}

public typealias RouteSequenceOptions = [String:Any]

public struct RouteSequenceItem {
    public let segmentIdentifier: Identifier
    public let options: RouteSequenceOptions

    public init(segmentIdentifier: Identifier, options: RouteSequenceOptions) {
        self.segmentIdentifier = segmentIdentifier
        self.options = options
    }

    public static func routeSequenceItem(item: Any) -> RouteSequenceItem? {
        if let routeSequenceItem = item as? RouteSequenceItem {
            return routeSequenceItem
        } else if let segmentIdentifier = item as? Identifier {
            return RouteSequenceItem(segmentIdentifier: segmentIdentifier, options:[:])
        } else if let name = item as? String {
            return RouteSequenceItem(segmentIdentifier: Identifier(name: name), options:[:])
        }
        print("Invalid sourceItem: \(item)")
        return nil
    }

}


public class RouteSequence : RouteSequenceType {

    public var items: [RouteSequenceItem] = []

    public init(source: [Any]) {
        self.items = source.map { RouteSequenceItem.routeSequenceItem($0) }.flatMap { $0 }
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
