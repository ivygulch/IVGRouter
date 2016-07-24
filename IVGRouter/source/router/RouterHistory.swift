//
//  RouterHistory.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 7/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public protocol RouterHistoryType {
    var previousSequence: RouteSequence? { get }
    var nextSequence: RouteSequence? { get }

    func moveBackward()
    func moveForward()
    func recordRouteSequence(routeSequence: RouteSequence)

    func debug(msg: String)
}

public class RouterHistory: RouterHistoryType {

    // MARK: protocol methods

    public init() {
    }

    public var previousSequence: RouteSequence? {
        let previousIndex = currentIndex - 1
        return (previousIndex >= 0) && (previousIndex < history.count) ? history[previousIndex] : nil
    }

    public var nextSequence: RouteSequence? {
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
            let flag = (checkIndex == currentIndex) ? "**" : ""
            checkIndex += 1
            return "(" + flag + $0.items
                .map { item in item.segmentIdentifier.name }
                .joinWithSeparator(",") + flag + ")"
            }.joinWithSeparator("|")
    }

    public func debug(msg: String) {
        print("DBG: \(msg)=\(debugStr())")
    }

    public func recordRouteSequence(routeSequence: RouteSequence) {
        print("DBG: recordRouteSequence(\(routeSequence.items.map { $0.segmentIdentifier.name }.joinWithSeparator(",") ))")
        let nextIndex = currentIndex + 1
        if nextIndex < history.count {
            if routeSequence != history[nextIndex] {
                let range = Range(nextIndex..<history.count)
                history.removeRange(range)
                print("DBG: removeRange(\(range))=\(debugStr())")
                history.append(routeSequence)
            }
            currentIndex = nextIndex
        } else {
            history.append(routeSequence)
            currentIndex = history.count - 1
        }
        print("DBG: result=\(debugStr())")
    }

    // MARK: private variables

    private var history: [RouteSequence] = []
    private var currentIndex: Int = 0
}