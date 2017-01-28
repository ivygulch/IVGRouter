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
    func recordRouteHistoryItem(_ routeHistoryItem: RouteHistoryItemType, ignoreDuplicates: Bool)

    func debug(_ msg: String)
    func debugFull(_ msg: String)
}

open class RouterHistory: RouterHistoryType {

    // MARK: protocol methods

    public init() {
    }

    open var previousRouteHistoryItem: RouteHistoryItemType? {
        let previousIndex = currentIndex - 1
        return (previousIndex >= 0) && (previousIndex < history.count) ? history[previousIndex] : nil
    }

    open var nextRouteHistoryItem: RouteHistoryItemType? {
        let nextIndex = currentIndex + 1
        return nextIndex < history.count ? history[nextIndex] : nil
    }

    open func moveBackward() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }

    open func moveForward() {
        if currentIndex < (history.count-1) {
            currentIndex += 1
        }
    }

    fileprivate func debugStr() -> String {
        var checkIndex = 0
        return history.map {
            routeHistoryItem in
            let flag = (checkIndex == currentIndex) ? "**" : ""
            checkIndex += 1
            let itemStr = routeHistoryItem.routeSequence.items
                .map { item in item.segmentIdentifier.name }
                .joined(separator: ",")
            let title = (routeHistoryItem.title ?? "<null>")
            return "(" + flag + itemStr + ", \"" + title + "\", " + flag + ")"
            }.joined(separator: "|")
    }

    open func debug(_ msg: String) {
        print("DBG: \(msg)=\(debugStr())")
    }

    open func debugFull(_ msg: String) {
        print("DBG: \(msg), count=\(history.count), currentIndex=\(currentIndex)")
        for (checkIndex,routeHistoryItem) in history.enumerated() {
            let flag = (checkIndex == currentIndex) ? "**" : "  "
            let itemStr = routeHistoryItem.routeSequence.items
                .map { item in item.segmentIdentifier.name }
                .joined(separator: ",")
            let title = (routeHistoryItem.title ?? "<null>")
            print("DBG:   \(flag) \"\(title)\", \(itemStr)")
        }
    }


    open func recordRouteHistoryItem(_ routeHistoryItem: RouteHistoryItemType, ignoreDuplicates: Bool) {
        if let lastHistory = history.last, ignoreDuplicates && lastHistory.routeSequence == routeHistoryItem.routeSequence {
            currentIndex = history.count - 1
            return
        }
        let nextIndex = currentIndex + 1
        if nextIndex < history.count {
            if routeHistoryItem.routeSequence != history[nextIndex].routeSequence {
                let range = Range(nextIndex..<history.count)
                history.removeSubrange(range)
                history.append(routeHistoryItem)
            }
            currentIndex = nextIndex
        } else {
            history.append(routeHistoryItem)
            currentIndex = history.count - 1
        }
    }

    // MARK: private variables

    fileprivate var history: [RouteHistoryItemType] = []
    fileprivate var currentIndex: Int = 0
}

public struct RouteHistoryItem: Equatable, RouteHistoryItemType {
    public let routeSequence: RouteSequence
    public let title: String?
}

public func ==(lhs: RouteHistoryItem, rhs: RouteHistoryItem) -> Bool {
    return lhs.routeSequence == rhs.routeSequence
        && lhs.title == rhs.title
}
