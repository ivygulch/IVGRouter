//
//  Router.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/22/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public typealias RouteSequence = [RouteSequenceItem]
public typealias RouteSequenceOptions = [String:Any]

public struct RouteSequenceItem {
    public let segmentIdentifier: Identifier
    public let options: RouteSequenceOptions

    public init(segmentIdentifier: Identifier, options: RouteSequenceOptions) {
        self.segmentIdentifier = segmentIdentifier
        self.options = options
    }
}

public func buildRouteSequence(source: [Any]) -> RouteSequence {
    var result:RouteSequence = []
    for item in source {
        if let routeSequenceItem = item as? RouteSequenceItem {
            result.append(routeSequenceItem)
        } else if let segmentIdentifier = item as? Identifier {
            result.append(RouteSequenceItem(segmentIdentifier: segmentIdentifier, options:[:]))
        } else if let name = item as? String {
            result.append(RouteSequenceItem(segmentIdentifier: Identifier(name: name), options:[:]))
        } else {
            print("Invalid sourceItem: \(item)")
        }
    }
    return result
}

public protocol RouterType {
    var window: UIWindow? { get }
    var routeSegments:[Identifier:RouteSegmentType] { get }
    var presenters:[Identifier:RouteSegmentPresenterType] { get }
    var viewControllers:[UIViewController] { get }
    func registerPresenter(presenter:RouteSegmentPresenterType)
    func registerRouteSegment(routeSegment:RouteSegmentType)
    func executeRoute(routeSequence:[Any]) -> Bool
    func appendRoute(routeSequence:[Any]) -> Bool
    func registerDefaultPresenters()

    var currentSequence:[Any] { get }
    func debug(msg: String)
}

public class Router : RouterType {

    public init(window: UIWindow?) {
        self.window = window
    }

    public func debug(msg: String) {
        print("Router(\(msg))")
        for index in 0..<currentActiveSegments.count {
            let activeSegment = currentActiveSegments[index]
            let segmentIdentifier = activeSegment.segmentIdentifier
            let vc = activeSegment.viewController
            var result = "[\(index)]"
            result += "=\(segmentIdentifier.name)"
            result += "," + String(vc.dynamicType)
            if let p = vc.parentViewController {
                result += ",p=" + String(p.dynamicType)
            }
            print(result)
        }
    }

    public private(set) var routeSegments:[Identifier:RouteSegmentType] = [:]
    public private(set) var presenters:[Identifier:RouteSegmentPresenterType] = [:]

    public let window: UIWindow?

    public var viewControllers:[UIViewController] {
        return currentActiveSegments.map { $0.viewController }
    }

    public func registerPresenter(presenter:RouteSegmentPresenterType) {
        presenters[presenter.presenterIdentifier] = presenter
    }

    public func registerRouteSegment(routeSegment:RouteSegmentType) {
        routeSegments[routeSegment.segmentIdentifier] = routeSegment
    }

    public func registerDefaultPresenters() {
        registerPresenter(RootRouteSegmentPresenter())
        registerPresenter(TabRouteSegmentPresenter())
        registerPresenter(PushRouteSegmentPresenter())
    }

    public var currentSequence:[Any] {
        return currentActiveSegments.map {
            activeSegment -> Identifier in
            return activeSegment.segmentIdentifier
        }
    }

    public func appendRoute(routeSequence:[Any]) -> Bool {
        guard let lastActiveSegment = currentActiveSegments.last else {
            // cannot append to empty current route sequence
            return false
        }
        let useRouteSequence = buildRouteSequence(routeSequence)
        var parent = lastActiveSegment.viewController
        for itemIndex in 0..<useRouteSequence.count {
            let routeSequenceItem = useRouteSequence[itemIndex]
            let segmentIdentifier = routeSequenceItem.segmentIdentifier
            guard let routeSegment = routeSegments[segmentIdentifier] else {
                print("No segment registered for: \(segmentIdentifier)")
                return false
            }

            var newChild: UIViewController?

            var completionSucessful = true
            if let presenter = presenters[routeSegment.presenterIdentifier],
                let viewController = routeSegment.viewController() {
                newChild = viewController
                presenter.presentViewController(viewController, from: parent, options: routeSequenceItem.options, window: window, completion: {
                    success in
                    completionSucessful = success
                })
            }
            guard let child = newChild else {
                print("Route segment did not load a viewController: \(segmentIdentifier)")
                return false
            }
            if !completionSucessful {
                print("Route segment completion block failed: \(segmentIdentifier)")
                return false
            }

            let newActiveSegment = ActiveSegment(segmentIdentifier:segmentIdentifier,viewController:child)
            debug("before normal=\(segmentIdentifier.name)")
            currentActiveSegments.append(newActiveSegment)
            debug("after normal=\(segmentIdentifier.name)")

            registeredViewControllers[child] = segmentIdentifier

            parent = child
        }
        return true
    }


    public func executeRoute(routeSequence:[Any]) -> Bool {
        var newActiveSegments:[ActiveSegment] = []
        var routeChanged = false
        defer {
            debug("before defer=\(currentActiveSegments.map { a -> String in a.segmentIdentifier.name })")
            currentActiveSegments = newActiveSegments
            debug("after defer=\(currentActiveSegments.map { a -> String in a.segmentIdentifier.name })")
        }
        let useRouteSequence = buildRouteSequence(routeSequence)
        var parent: UIViewController?
        for itemIndex in 0..<useRouteSequence.count {
            let routeSequenceItem = useRouteSequence[itemIndex]
            let segmentIdentifier = routeSequenceItem.segmentIdentifier
            guard let routeSegment = routeSegments[segmentIdentifier] else {
                print("No segment registered for: \(segmentIdentifier)")
                return false
            }
            let isLastSegment = (itemIndex == (routeSequence.count - 1))
            let currentActiveSegment:ActiveSegment? = (itemIndex < currentActiveSegments.count) ? currentActiveSegments[itemIndex] : nil
            var currentChild = currentActiveSegment?.viewController

            var needNewChild = false
            if currentChild == nil {
                needNewChild = true
            } else if let tabBarController = parent as? UITabBarController,
                sibling = selectSibingInTabBarController(tabBarController, forIdentifier: segmentIdentifier) {
                currentChild = sibling
                needNewChild = false
            } else {
                needNewChild = (segmentIdentifier != currentActiveSegment?.segmentIdentifier)
            }

            var child: UIViewController?
            if routeChanged || needNewChild {
                var completionSucessful = true
                if let presenter = presenters[routeSegment.presenterIdentifier],
                    let viewController = routeSegment.viewController() {
                    child = viewController
                    presenter.presentViewController(viewController, from: parent, options: routeSequenceItem.options, window: window, completion: {
                        success in
                        completionSucessful = success
                    })
                }
                if child == nil {
                    print("Route segment did not load a viewController: \(segmentIdentifier)")
                    return false
                }
                if !completionSucessful {
                    print("Route segment completion block failed: \(segmentIdentifier)")
                    return false
                }
            } else {
                child = currentChild
                // if we are still on the previous path, but on the last segment, check if we can simply pop back in the navigation stack
                if isLastSegment {
                    if let child = child, childNavigationController = child.navigationController {
                        childNavigationController.popToViewController(child, animated: true)
                    }
                }
            }

            if let child = child {
                newActiveSegments.append(ActiveSegment(segmentIdentifier:segmentIdentifier,viewController:child))
                registeredViewControllers[child] = segmentIdentifier
            }

            parent = child

        }
        return true
    }

    private func selectSibingInTabBarController(tabBarController:UITabBarController, forIdentifier segmentIdentifier:Identifier) -> UIViewController? {
        if let existingChildren = tabBarController.viewControllers {
            for index in 0..<existingChildren.count {
                let existingChild = existingChildren[index]
                if registeredViewControllers[existingChild] == segmentIdentifier {
                    tabBarController.selectedIndex = index
                    return existingChild
                }
            }
        }
        return nil
    }

    private var currentActiveSegments:[ActiveSegment] = []
    private var registeredViewControllers:[UIViewController:Identifier] = [:]

}

private struct ActiveSegment {
    let segmentIdentifier: Identifier
    let viewController: UIViewController
}
