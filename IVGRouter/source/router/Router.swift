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
    let segmentIdentifer: Identifier
    let options: RouteSequenceOptions
}

public func buildRouteSequence(source: [Any]) -> RouteSequence {
    var result:RouteSequence = []
    for item in source {
        if let routeSequenceItem = item as? RouteSequenceItem {
            result.append(routeSequenceItem)
        } else if let segmentIdentifer = item as? Identifier {
            result.append(RouteSequenceItem(segmentIdentifer: segmentIdentifer, options:[:]))
        } else if let name = item as? String {
            result.append(RouteSequenceItem(segmentIdentifer: Identifier(name: name), options:[:]))
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
    func registerRouteSegment(routeSegment:RouteSegmentType)
    func executeRoute(routeSequence:[Any]) -> Bool
    func registerDefaultPresenters()
}

public class Router : RouterType {

    public init(window: UIWindow?) {
        self.window = window
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

    public func executeRoute(routeSequence:[Any]) -> Bool {
        var newActiveSegments:[ActiveSegment] = []
        var routeChanged = false
        defer {
            currentActiveSegments = newActiveSegments
        }
        let useRouteSequence = buildRouteSequence(routeSequence)
        var parent: UIViewController?
        for itemIndex in 0..<useRouteSequence.count {
            let routeSequenceItem = useRouteSequence[itemIndex]
            let segmentIdentifier = routeSequenceItem.segmentIdentifer
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
