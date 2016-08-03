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
    var nextRouteHistoryItem: RouteHistoryItemType? { get }

    func moveBackward()
    func moveForward()
    func recordRouteHistoryItem(routeHistoryItem: RouteHistoryItemType)

    func debug(msg: String)
}

public class RouterHistory: RouterHistoryType {

    // MARK: protocol methods

    public init() {
    }

    public var previousRouteHistoryItem: RouteHistoryItemType? {
        let previousIndex = currentIndex - 1
        return (previousIndex >= 0) && (previousIndex < history.count) ? history[previousIndex] : nil
    }

    public var nextRouteHistoryItem: RouteHistoryItemType? {
        let nextIndex = currentIndex + 1
        return nextIndex < history.count ? history[nextIndex] : nil
    }

    public func moveBackward() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }

    public func moveForward() {
        if currentIndex < (history.count-1) {
            currentIndex += 1
        }
    }

    private func debugStr() -> String {
        var checkIndex = 0
        return history.map {
            routeHistoryItem in
            let flag = (checkIndex == currentIndex) ? "**" : ""
            checkIndex += 1
            let itemStr = routeHistoryItem.routeSequence.items
                .map { item in item.segmentIdentifier.name }
                .joinWithSeparator(",")
            let title = (routeHistoryItem.title ?? "<null>")
            return "(" + flag + itemStr + ", \"" + title + "\", " + flag + ")"
            }.joinWithSeparator("|")
    }

    public func debug(msg: String) {
        print("DBG: \(msg)=\(debugStr())")
    }

    public func recordRouteHistoryItem(routeHistoryItem: RouteHistoryItemType) {
        let nextIndex = currentIndex + 1
        if nextIndex < history.count {
            if routeHistoryItem.routeSequence != history[nextIndex].routeSequence {
                let range = Range(nextIndex..<history.count)
                history.removeRange(range)
                history.append(routeHistoryItem)
            }
            currentIndex = nextIndex
        } else {
            history.append(routeHistoryItem)
            currentIndex = history.count - 1
        }
    }

    // MARK: private variables

    private var history: [RouteHistoryItemType] = []
    private var currentIndex: Int = 0
}

public struct RouteHistoryItem: Equatable, RouteHistoryItemType {
    public let routeSequence: RouteSequence
    public let title: String?
}

public func ==(lhs: RouteHistoryItem, rhs: RouteHistoryItem) -> Bool {
    return lhs.routeSequence == rhs.routeSequence
        && lhs.title == rhs.title
}
