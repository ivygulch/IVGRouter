//
//  RouteSegment.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 3/22/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public typealias RouteSegmentDataType = Any

public typealias ViewControllerLoaderFunction = () -> (() -> UIViewController?)
public typealias ViewControllerSetDataFunction = () -> ((_ presented: UIViewController, _ presenting: UIViewController?, _ data: RouteSegmentDataType?, _ router: RouterType) -> Void)

public protocol RouteSegmentType {
    var segmentIdentifier: Identifier { get }
    var presenterIdentifier: Identifier { get }
    var shouldBeRecorded: Bool { get }
}

public protocol RefreshableRouteSegmentType {
    func refresh()
}

public protocol VisualRouteSegmentType: RouteSegmentType, RefreshableRouteSegmentType {
    func viewController() -> UIViewController?
    func set(data: RouteSegmentDataType?, withRouter router: RouterType, on presented: UIViewController, from presenting: UIViewController?)
}

public protocol BranchRouteSegmentType: RouteSegmentType {
}

// view controllers that will present via BranchRouteSegmentType must implement this protocol
// UITabBarController would have extension that added tabs, selected, etc
// UISplitViewController would have extension that set master or detail, selected, etc.
public protocol TrunkRouteController {
    func configureBranch(_ branchIdentifier: Identifier, completion: ((RoutingResult) -> Void))
    func selectBranch(_ branchIdentifier: Identifier, completion: ((RoutingResult) -> Void))
}

open class RouteSegment: RouteSegmentType {

    public init(segmentIdentifier: Identifier, presenterIdentifier: Identifier, shouldBeRecorded: Bool = true) {
        self.segmentIdentifier = segmentIdentifier
        self.presenterIdentifier = presenterIdentifier
        self.shouldBeRecorded = shouldBeRecorded
    }

    public let segmentIdentifier: Identifier
    public let presenterIdentifier: Identifier
    public let shouldBeRecorded: Bool
}

open class VisualRouteSegment: RouteSegment, VisualRouteSegmentType {

    private var lastRouteSegmentData: RouteSegmentDataType?
    private var lastRouter: RouterType?
    private weak var lastPresentedViewController: UIViewController?
    private weak var lastPresentingViewController: UIViewController?

    public init(segmentIdentifier: Identifier, presenterIdentifier: Identifier, shouldBeRecorded: Bool = true, isSingleton: Bool, loadViewController: @escaping ViewControllerLoaderFunction, setData: ViewControllerSetDataFunction? = nil, refreshData: ViewControllerSetDataFunction? = nil) {
        self.isSingleton = isSingleton
        self.loadViewController = loadViewController
        self.setData = setData
        self.refreshData = refreshData
        super.init(segmentIdentifier: segmentIdentifier, presenterIdentifier: presenterIdentifier, shouldBeRecorded: shouldBeRecorded)
    }

    open func viewController() -> UIViewController? {
        return getViewController()
    }

    open func set(data: RouteSegmentDataType?, withRouter router: RouterType, on presented: UIViewController, from presenting: UIViewController?) {
        lastRouteSegmentData = data
        lastRouter = router
        lastPresentedViewController = presented
        lastPresentingViewController = presenting
        setData?()(presented, presenting, data, router)
    }

    open func refresh() {
        guard let lastPresentedViewController = lastPresentedViewController, let lastRouter = lastRouter else { return }
        refreshData?()(lastPresentedViewController, lastPresentingViewController, lastRouteSegmentData, lastRouter)
    }

    fileprivate func getViewController() -> UIViewController? {
        if isSingleton {
            // TODO: need method to provide fresh data for cached controllers
            if cachedViewController == nil {
                cachedViewController = loadViewController()()
            }
            return cachedViewController
        } else {
            return loadViewController()()
        }
    }

    fileprivate let isSingleton: Bool
    fileprivate let loadViewController: ViewControllerLoaderFunction
    fileprivate let setData: ViewControllerSetDataFunction?
    fileprivate let refreshData: ViewControllerSetDataFunction?
    fileprivate var cachedViewController: UIViewController?
    
}

open class AlertRouteSegment: VisualRouteSegment {

    public init(segmentIdentifier: Identifier, preferredStyle: UIAlertControllerStyle, setData: ViewControllerSetDataFunction?) {
        super.init(segmentIdentifier: segmentIdentifier,
                   presenterIdentifier: PresentRouteSegmentPresenter.autoDismissPresenterIdentifier,
                   shouldBeRecorded: false, // alerts are self dismissing and should not be put on the history stack or current route
            isSingleton: false, // must not be a singleton, need a fresh copy each time
            loadViewController: { return { return UIAlertController(title: nil, message: nil, preferredStyle: preferredStyle) } },
            setData: setData)
    }

}

open class BranchRouteSegment: RouteSegment, BranchRouteSegmentType {
}

extension UITabBarController: TrunkRouteController {

    fileprivate struct AssociatedKey {
        static var branchDictionary = "branchDictionary"
    }

    fileprivate var branches: NSMutableDictionary {
        get {
            if let result = objc_getAssociatedObject(self, &AssociatedKey.branchDictionary) as? NSMutableDictionary {
                return result
            }
            let result = NSMutableDictionary()
            objc_setAssociatedObject(self, &AssociatedKey.branchDictionary, result, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return result
        }
    }

    fileprivate func appendBranchIfNeeded(_ branchIdentifier: Identifier, selectViewController: Bool, completion: ((RoutingResult) -> Void)) {
        var localViewControllers: [UIViewController] = viewControllers ?? []

        if let index = branches[branchIdentifier.name] as? Int, index < localViewControllers.count {
            guard let result = localViewControllers[index] as? PlaceholderViewController else {
                completion(.failure(RoutingErrors.invalidRouteSegment(branchIdentifier, "TrunkRouteControllers must use PlaceholderViewController as direct children")))
                return
            }
            if selectViewController {
                selectedViewController = result
            }
            completion(.success(result))
        }

        let result = PlaceholderViewController()
        localViewControllers.append(result)
        viewControllers = localViewControllers
        branches[branchIdentifier.name] = localViewControllers.count - 1
        if selectViewController {
            selectedViewController = result
        }
        completion(.success(result))
    }

    public func configureBranch(_ branchIdentifier: Identifier, completion: ((RoutingResult) -> Void)) {
        return appendBranchIfNeeded(branchIdentifier, selectViewController: false, completion: completion)
    }

    public func selectBranch(_ branchIdentifier: Identifier, completion: ((RoutingResult) -> Void)) {
        appendBranchIfNeeded(branchIdentifier, selectViewController: true, completion: completion)
    }
    
}

extension UISplitViewController: TrunkRouteController {

    fileprivate struct AssociatedKey {
        static var branchDictionary = "branchDictionary"
    }

    fileprivate var branches: NSMutableDictionary {
        get {
            if let result = objc_getAssociatedObject(self, &AssociatedKey.branchDictionary) as? NSMutableDictionary {
                return result
            }
            let result = NSMutableDictionary()
            objc_setAssociatedObject(self, &AssociatedKey.branchDictionary, result, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return result
        }
    }


    fileprivate func appendBranchIfNeeded(_ branchIdentifier: Identifier, completion: ((RoutingResult) -> Void)) {
        var localViewControllers: [UIViewController] = viewControllers 

        if let index = branches[branchIdentifier.name] as? Int, index < localViewControllers.count {
            guard let result = localViewControllers[index] as? PlaceholderViewController else {
                completion(.failure(RoutingErrors.invalidRouteSegment(branchIdentifier, "TrunkRouteControllers must use PlaceholderViewController as direct children")))
                return
            }
            completion(.success(result))
        }

        let result = PlaceholderViewController()
        localViewControllers.append(result)
        viewControllers = localViewControllers
        branches[branchIdentifier.name] = localViewControllers.count - 1
        completion(.success(result))
    }

    public func configureBranch(_ branchIdentifier: Identifier, completion: ((RoutingResult) -> Void)) {
        return appendBranchIfNeeded(branchIdentifier, completion: completion)
    }

    public func selectBranch(_ branchIdentifier: Identifier, completion: ((RoutingResult) -> Void)) {
        appendBranchIfNeeded(branchIdentifier, completion: completion)
    }
    
}
