//
//  RouteSequence.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public typealias RouteSequenceOptions = [String: AnyObject]

public struct RouteSequenceItem: Equatable {
    public let segmentIdentifier: Identifier
    public let data: RouteSegmentDataType?
    public let options: RouteSequenceOptions

    public init(segmentIdentifier: Identifier, data: RouteSegmentDataType?, options: RouteSequenceOptions = [:]) {
        self.segmentIdentifier = segmentIdentifier
        self.data = data
        self.options = options
    }

    public static func transform(_ item: Any) -> RouteSequenceItem? {
        if let routeSequenceItem = item as? RouteSequenceItem {
            return routeSequenceItem
        } else if let segmentIdentifier = item as? Identifier {
            return RouteSequenceItem(segmentIdentifier: segmentIdentifier, data: nil, options: [: ])
        } else if let (segmentIdentifier, options) = item as? (Identifier, RouteSequenceOptions) {
            return RouteSequenceItem(segmentIdentifier: segmentIdentifier, data: nil, options: options)
        } else if let (name, options) = item as? (String, RouteSequenceOptions) {
            return RouteSequenceItem(segmentIdentifier: Identifier(name: name), data: nil, options: options)
        }
        print("Invalid sourceItem: \(item)")
        return nil
    }

}

public func ==(lhs: RouteSequenceItem, rhs: RouteSequenceItem) -> Bool {
    return lhs.segmentIdentifier == rhs.segmentIdentifier
        && String(describing: lhs.options) == String(describing: rhs.options)
}
