//
//  RouteSegment.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 3/22/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public typealias ViewControllerLoaderFunction = (Void) -> ((Void) -> UIViewController?)

public protocol RouteSegmentType {
    var segmentIdentifier: Identifier { get }
    var presenterIdentifier: Identifier { get }
}

public protocol VisualRouteSegmentType: RouteSegmentType {
    func viewController() -> UIViewController?
}

public protocol BranchRouteSegmentType: RouteSegmentType {
}

// view controllers that will present via BranchRouteSegmentType must implement this protocol
// UITabBarController would have extension that added tabs, selected, etc
// UISplitViewController would have extension that set master or detail, selected, etc.
public protocol TrunkRouteController {
    func configureBranch(branchIdentifier: Identifier, completion: (RoutingResult -> Void))
    func selectBranch(branchIdentifier: Identifier, completion: (RoutingResult -> Void))
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

    public init(segmentIdentifier: Identifier, presenterIdentifier: Identifier, isSingleton: Bool, loadViewController: ViewControllerLoaderFunction) {
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

    private func callLoadViewController() -> UIViewController? {
        return loadViewController()()
    }

    private let isSingleton: Bool
    private let loadViewController: ViewControllerLoaderFunction
    private var cachedViewController: UIViewController?
    
}

public class BranchRouteSegment : RouteSegment, BranchRouteSegmentType {
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

    private func appendBranchIfNeeded(branchIdentifier: Identifier, selectViewController: Bool, completion: (RoutingResult -> Void)) {
        var localViewControllers: [UIViewController] = viewControllers ?? []

        if let index = branches[branchIdentifier.name] as? Int where index < localViewControllers.count {
            guard let result = localViewControllers[index] as? PlaceholderViewController else {
                completion(.Failure(RoutingErrors.InvalidRouteSegment(branchIdentifier, "TrunkRouteControllers must use PlaceholderViewController as direct children")))
                return
            }
            if selectViewController {
                selectedViewController = result
            }
            completion(.Success(result))
        }

        let result = PlaceholderViewController()
        localViewControllers.append(result)
        viewControllers = localViewControllers
        branches[branchIdentifier.name] = localViewControllers.count - 1
        if selectViewController {
            selectedViewController = result
        }
        completion(.Success(result))
    }

    public var asViewController: UIViewController {
        return self
    }

    public func configureBranch(branchIdentifier: Identifier, completion: (RoutingResult -> Void)) {
        return appendBranchIfNeeded(branchIdentifier, selectViewController: false, completion: completion)
    }

    public func selectBranch(branchIdentifier: Identifier, completion: (RoutingResult -> Void)) {
        appendBranchIfNeeded(branchIdentifier, selectViewController: true, completion: completion)
    }
    
}

extension UISplitViewController: TrunkRouteController {

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


    private func appendBranchIfNeeded(branchIdentifier: Identifier, completion: (RoutingResult -> Void)) {
        var localViewControllers: [UIViewController] = viewControllers ?? []

        if let index = branches[branchIdentifier.name] as? Int where index < localViewControllers.count {
            guard let result = localViewControllers[index] as? PlaceholderViewController else {
                completion(.Failure(RoutingErrors.InvalidRouteSegment(branchIdentifier, "TrunkRouteControllers must use PlaceholderViewController as direct children")))
                return
            }
            completion(.Success(result))
        }

        let result = PlaceholderViewController()
        localViewControllers.append(result)
        viewControllers = localViewControllers
        branches[branchIdentifier.name] = localViewControllers.count - 1
        completion(.Success(result))
    }

    public var asViewController: UIViewController {
        return self
    }

    public func configureBranch(branchIdentifier: Identifier, completion: (RoutingResult -> Void)) {
        return appendBranchIfNeeded(branchIdentifier, completion: completion)
    }

    public func selectBranch(branchIdentifier: Identifier, completion: (RoutingResult -> Void)) {
        appendBranchIfNeeded(branchIdentifier, completion: completion)
    }
    
}