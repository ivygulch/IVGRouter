//
//  Router.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/22/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
/*
public struct ActiveSegment {
    let segmentIdentifier: Identifier
    let viewController: UIViewController
}

public protocol RouterType {
    func registerRouteSegment(routeSegment:RouteSegment)
    func executeRoute(Identifiers:[Identifier]) -> Bool
}

public class Router : RouterType {

    var currentActiveSegments:[ActiveSegment] = []

    public init(window: UIWindow?) {
        self.window = window
    }

    public func registerRouteSegment(routeSegment:RouteSegment) {
        routeSegments[routeSegment.segmentIdentifier] = routeSegment
    }

    func switchTabsIfNeededInParent(parent:UIViewController?, forSegmentIdentifier segmentIdentifier:Identifier) -> UIViewController? {
        if let parentRootViewController = parent as? UITabBarController,
            let existingChildren = parentRootViewController.viewControllers {
            for index in 0..<existingChildren.count {
                let existingChild = parentRootViewController.viewControllers![index]
                if registeredViewControllers[existingChild] == segmentIdentifier {
                    parentRootViewController.selectedIndex = index
                    return existingChild
                }
            }
        }
        return nil
    }

    public func executeRoute(Identifiers:[Identifier]) -> Bool {
        var newActiveSegments:[ActiveSegment] = []
        var routeChanged = false
        defer {
            currentActiveSegments = newActiveSegments
        }
        var parent: UIViewController?
        for segmentIndex in 0..<Identifiers.count {
            let Identifier = Identifiers[segmentIndex]
            guard let routeSegment = routeSegments[Identifier] else {
                print("No segment registered for : \(Identifier)")
                return false
            }
            let isLastSegment = (segmentIndex == (Identifiers.count - 1))
            let currentActiveSegment:ActiveSegment? = (segmentIndex < currentActiveSegments.count) ? currentActiveSegments[segmentIndex] : nil
            var currentChild = currentActiveSegment?.viewController

            var needNewChild = false
            if currentChild == nil {
                needNewChild = true
            } else if let childSwitchedTo = switchTabsIfNeededInParent(parent, forSegmentIdentifier: Identifier) {
                currentChild = childSwitchedTo
                needNewChild = false
            } else {
                needNewChild = (Identifier != currentActiveSegment?.segmentIdentifier)
            }

            var child: UIViewController!
            if routeChanged || needNewChild {
                let loadViewController = routeSegment.loadViewController()
                guard let controller = loadViewController() else {
                    print("Segment could not load a view controller: \(routeSegment)")
                    return false
                }
                guard let presentedChild = presentChild(controller, fromParent:parent, presentationType:routeSegment.presentationType) else {
                    return false
                }
                child = presentedChild
                print("DBG: segment[\(segmentIndex)]=\(Identifier), new child=\(child)")
                routeChanged = true
            } else {
                child = currentChild!
                if isLastSegment && (child.navigationController != nil) {
                    child.navigationController?.popToViewController(child, animated: true)
                }
                print("DBG: segment[\(segmentIndex)]=\(Identifier), existing child=\(child)")
            }

            newActiveSegments.append(ActiveSegment(segmentIdentifier:Identifier,viewController:child))
            registeredViewControllers[child] = Identifier

            parent = child

        }
        print("DBG: new route=\(newActiveSegments.map { $0.segmentIdentifier })")
        return true
    }

    func unwrapViewController(viewController: UIViewController?) -> UIViewController? {
        if let lazyTabViewController = viewController as? LazyTabViewController,
            let childViewController = lazyTabViewController.childViewController {
            return childViewController
        }
        return viewController
    }

    func presentChild(child:UIViewController, fromParent parent:UIViewController?, presentationType:RouterPresentationType) -> UIViewController? {

    }

    func presentChild_orig(child:UIViewController, fromParent parent:UIViewController?, presentationType:RouterPresentationType) -> UIViewController? {
        var result:UIViewController? = child
        let unwrappedParent = unwrapViewController(parent)
        switch presentationType {
        case .Root:
            guard let window = window else {
                print("Cannot present Root: Router.window is nil")
                return nil
            }
            window.rootViewController = child
            window.makeKeyAndVisible()
        case .Tab:
            guard let tabBarController = unwrappedParent as? UITabBarController else {
                print("Cannot present Tab: parent must be UITabBarController")
                return nil
            }

            result = {
                (Void) -> UIViewController in
                return isLazy
                    ? LazyTabViewController(title: child.tabBarItem.title, image: child.tabBarItem.image) { return child }
                    : child
            }()
            if let tabIndex = tabIndex {
                tabBarController.setViewController(child, atIndex:tabIndex)
            } else {
                tabBarController.appendViewController(child)
            }
        case .PopStack:
            guard let navigationController = unwrappedParent as? UINavigationController else {
                print("Cannot present PopStack: parent must be UINavigationController")
                return nil
            }

            navigationController.setViewControllers([child], animated: true)
        case .Push:
            let navigationController: UINavigationController?
            if let controller = unwrappedParent as? UINavigationController {
                navigationController = controller
            } else if let controller = unwrappedParent, let controllerNavigationController = controller.navigationController {
                navigationController = controllerNavigationController
            } else {
                print("Cannot present Push: parent must be UINavigationController or be part of a navigation stack")
                return nil
            }
            navigationController?.pushViewController(child, animated: true)
        }
        return result
    }

    let window: UIWindow?
    private var routeSegments:[Identifier:RouteSegment] = [:]
    private var registeredViewControllers:[UIViewController:Identifier] = [:]
    private var routeSegmentPresenters:[RouterPresentationType: RouteSegmentPresenter]
}

private extension UITabBarController {
    func appendViewController(viewController: UIViewController) {
        var useViewControllers = viewControllers ?? []
        useViewControllers.append(viewController)
        viewControllers = useViewControllers
    }

    func setViewController(viewController: UIViewController, atIndex index: Int) {
        while index < viewControllers?.count {
            appendViewController(UIViewController())
        }
        if index == viewControllers?.count {
            appendViewController(viewController)
        } else {
            viewControllers?[index] = viewController
        }
    }
}
*/