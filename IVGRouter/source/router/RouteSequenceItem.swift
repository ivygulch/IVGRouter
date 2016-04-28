//
//  RouteSequence.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public typealias RouteSequenceOptions = [String:Any]

public protocol RouteSequenceItemType {
    var segmentIdentifier: Identifier { get }
    var options: RouteSequenceOptions { get }
}

public struct RouteSequenceItem: RouteSequenceItemType {

    public static func transform(item: Any) -> RouteSequenceItem? {
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

    public let segmentIdentifier: Identifier
    public let options: RouteSequenceOptions

    public init(segmentIdentifier: Identifier, options: RouteSequenceOptions) {
        self.segmentIdentifier = segmentIdentifier
        self.options = options
    }

}

