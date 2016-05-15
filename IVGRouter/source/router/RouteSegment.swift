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

public protocol BranchRouteSegmentType: RouteSegmentType {
}

// view controllers that are presented via TrunkRouteSegmentType should implement this protocol
// UITabBarController would have extension that added tabs, selected, etc
// UISplitViewController would have extension that set master or detail, selected, etc.
public protocol TrunkRouteController {
    func configureBranch(branchIdentifier: Identifier) -> RoutingResult
    func selectBranch(branchIdentifier: Identifier) -> RoutingResult
}

public protocol TrunkRouteSegmentType: RouteSegmentType {
    var trunkRouteController: TrunkRouteController { get }
    var branches: [BranchRouteSegmentType] { get }
    func branchForIdentifier(segmentIdentifier: Identifier) -> BranchRouteSegmentType?
    func addBranch(branchRouteSegment: BranchRouteSegmentType)
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


extension UITabBarController: TrunkRouteController {

    private struct AssociatedKey {
        static var branchDictionary = "branchDictionary"
    }

    private var branches: NSMutableDictionary {
        get {
            if let result = objc_getAssociatedObject(self, &AssociatedKey.branchDictionary) as? NSMutableDictionary {
                return result
            }
            let result = NSMutableDictionary()
            objc_setAssociatedObject(self, &AssociatedKey.branchDictionary, result, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return result
        }
    }

    private func appendBranchIfNeeded(branchIdentifier: Identifier) -> RoutingResult {
        var localViewControllers: [UIViewController] = viewControllers ?? []

        if let index = branches[branchIdentifier.name] as? Int where index < localViewControllers.count {
            guard let result = localViewControllers[index] as? PlaceholderViewController else {
                return .Failure(RoutingErrors.InvalidRouteSegment(branchIdentifier, "TrunkRouteSegment viewControllers must use PlaceholderViewController as direct children"))
            }
            return .Success(result)
        }

        let result = PlaceholderViewController()
        localViewControllers.append(result)
        viewControllers = localViewControllers
        branches[branchIdentifier.name] = localViewControllers.count - 1
        return .Success(result)
    }

    public func configureBranch(branchIdentifier: Identifier) -> RoutingResult {
        return appendBranchIfNeeded(branchIdentifier)
    }

    public func selectBranch(branchIdentifier: Identifier) -> RoutingResult {
        let result = appendBranchIfNeeded(branchIdentifier)
        switch result {
        case .Success(let viewController):
            selectedViewController = viewController
        case .Failure(_):
            selectedViewController = nil
        }
        return result
    }


}