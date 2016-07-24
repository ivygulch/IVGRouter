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
    func recordForward(routeSequence: RouteSequence)
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

    public func recordForward(routeSequence: RouteSequence) {
        let nextIndex = currentIndex + 1
        if nextIndex < history.count {
            if routeSequence != history[nextIndex] {
                history.removeRange(Range(nextIndex..<history.count))
                history.append(routeSequence)
            }
            currentIndex = nextIndex
        } else {
            history.append(routeSequence)
            currentIndex = history.count - 1
        }
    }

    // MARK: private variables

    private var history: [RouteSequence] = []
    private var currentIndex: Int = 0
}