//
//  RouteSegment.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/22/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public protocol RouteSegmentType {
    var segmentIdentifier: Identifier { get }
    var presenterIdentifier: Identifier { get }
    func viewController() -> UIViewController?
}

public class RouteSegment : RouteSegmentType {

    public init(segmentIdentifier: Identifier, presenterIdentifier: Identifier, isSingleton: Bool, loadViewController: (Void) -> ((Void) -> UIViewController?)) {
        self.segmentIdentifier = segmentIdentifier
        self.presenterIdentifier = presenterIdentifier
        self.isSingleton = isSingleton
        self.loadViewController = loadViewController
    }

    public func viewController() -> UIViewController? {
        return self.getViewController()
    }

    private func getViewController() -> UIViewController? {
        if isSingleton {
            if cachedViewController == nil {
                cachedViewController = loadViewController()()
            }
            return cachedViewController
        } else {
            return loadViewController()()
        }
    }

    public let segmentIdentifier: Identifier
    public let presenterIdentifier: Identifier
    private let isSingleton: Bool
    private let loadViewController: (Void) -> ((Void) -> UIViewController?)
    private var cachedViewController: UIViewController?

}
