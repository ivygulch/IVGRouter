//
//  RouteSegment.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 3/22/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public protocol RouteSegmentType {
    var segmentIdentifier: Identifier { get }
    var presenterIdentifier: Identifier { get }
}

public protocol VisualRouteSegmentType: RouteSegmentType {
    func viewController() -> UIViewController?
}

public protocol BranchedRouteSegmentType: RouteSegmentType {
}

public protocol BranchingRouteSegmentType: RouteSegmentType {
    var branches:[BranchedRouteSegmentType] { get }
    func branchForIdentifier(segmentIdentifier: Identifier) -> BranchedRouteSegmentType?
    func addBranch(branchedRouteSegment: BranchedRouteSegmentType)
}

public class RouteSegment : RouteSegmentType {

    public init(segmentIdentifier: Identifier, presenterIdentifier: Identifier) {
        self.segmentIdentifier = segmentIdentifier
        self.presenterIdentifier = presenterIdentifier
    }

    public let segmentIdentifier: Identifier
    public let presenterIdentifier: Identifier

}

public class VisualRouteSegment : RouteSegment, VisualRouteSegmentType {

    public init(segmentIdentifier: Identifier, presenterIdentifier: Identifier, isSingleton: Bool, loadViewController: (Void) -> ((Void) -> UIViewController?)) {
        self.isSingleton = isSingleton
        self.loadViewController = loadViewController
        super.init(segmentIdentifier: segmentIdentifier, presenterIdentifier: presenterIdentifier)
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

    private let isSingleton: Bool
    private let loadViewController: (Void) -> ((Void) -> UIViewController?)
    private var cachedViewController: UIViewController?
    
}
