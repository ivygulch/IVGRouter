//
//  RouteSequence.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public typealias RouteSequenceOptions = [String:AnyObject]

public struct RouteSequenceItem: Equatable {

    public static func transform(item: Any) -> RouteSequenceItem? {
        if let routeSequenceItem = item as? RouteSequenceItem {
            return routeSequenceItem
        } else if let segmentIdentifier = item as? Identifier {
            return RouteSequenceItem(segmentIdentifier: segmentIdentifier, options:[:])
        } else if let (segmentIdentifier,options) = item as? (Identifier,RouteSequenceOptions) {
            return RouteSequenceItem(segmentIdentifier: segmentIdentifier, options:options)
        } else if let (name,options) = item as? (String,RouteSequenceOptions) {
            return RouteSequenceItem(segmentIdentifier: Identifier(name: name), options:options)
        } else if let value = item as? String {
            let values = value.componentsSeparatedByString(";")
            let name = values.first!
            var options: RouteSequenceOptions = [:]
            for index in 1..<values.count {
                let value = values[index]
                let pieces = value.componentsSeparatedByString("=")
                if pieces.count > 1 {
                    options[pieces[0]] = pieces[1]
                } else {
                    options[value] = ""
                }
            }
            return RouteSequenceItem(segmentIdentifier: Identifier(name: name), options:options)
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

public func ==(lhs: RouteSequenceItem, rhs: RouteSequenceItem) -> Bool {
    return lhs.segmentIdentifier == rhs.segmentIdentifier
        && String(lhs.options) == String(rhs.options)
}