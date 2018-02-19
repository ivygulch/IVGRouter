//
//  RouterHistory.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 7/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public protocol RouteHistoryItemType {
    var routeSequence: RouteSequence { get }
    var title: String? { get }
}

public protocol RouterHistoryType {
    var previousRouteHistoryItem: RouteHistoryItemType? { get }
    var historySize: Int { get }

    func moveBackward()
    func recordRouteHistoryItem(_ routeHistoryItem: RouteHistoryItemType, ignoreDuplicates: Bool)

    func debug(_ msg: String)
    func debugFull(_ msg: String)
}

open class RouterHistory: RouterHistoryType {

    // MARK: protocol methods

    public init(historySize: Int) {
        self.historySize = historySize
    }

    public var previousRouteHistoryItem: RouteHistoryItemType? {
        let previousIndex = history.count - 2
        return (previousIndex >= 0) && (previousIndex < history.count) ? history[previousIndex]: nil
    }

    public func moveBackward() {
        history.removeLast()
    }

    fileprivate func debugStr() -> String {
        var checkIndex = 0
        return history.map {
            routeHistoryItem in
            checkIndex += 1
            let itemStr = routeHistoryItem.routeSequence.items
                .map { item in item.segmentIdentifier.name }
                .joined(separator: ",")
            let title = (routeHistoryItem.title ?? "<null>")
            return "(" + itemStr + ", \"" + title + "\")"
            }.joined(separator: "|")
    }

    public func debug(_ msg: String) {
        print("DBG: \(msg)=\(debugStr())")
    }

    public func debugFull(_ msg: String) {
        print("DBG: \(msg), count=\(history.count)")
        for (checkIndex,routeHistoryItem) in history.enumerated() {
            let itemStr = routeHistoryItem.routeSequence.items
                .map { item in item.segmentIdentifier.name }
                .joined(separator: ",")
            let title = (routeHistoryItem.title ?? "<null>")
            print("DBG:   [\(checkIndex)] \"\(title)\", \(itemStr)")
        }
    }


    public func recordRouteHistoryItem(_ routeHistoryItem: RouteHistoryItemType, ignoreDuplicates: Bool) {
        if let lastHistory = history.last, ignoreDuplicates && lastHistory.routeSequence == routeHistoryItem.routeSequence {
            return
        }
        history.append(routeHistoryItem)
        while history.count > historySize {
            _ = history.removeFirst()
        }
    }

    public let historySize: Int

    // MARK: private variables

    fileprivate var history: [RouteHistoryItemType] = []

}

public struct RouteHistoryItem: Equatable, RouteHistoryItemType {
    public let routeSequence: RouteSequence
    public let title: String?
}

public func ==(lhs: RouteHistoryItem, rhs: RouteHistoryItem) -> Bool {
    return lhs.routeSequence == rhs.routeSequence
        && lhs.title == rhs.title
}
