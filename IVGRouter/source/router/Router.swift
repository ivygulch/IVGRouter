//
//  Router.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 3/22/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public typealias RouteSequenceOptions = [String:Any]

public struct RouteSequence {
    public var items: [RouteSequenceItem] = []

    public init(source: [Any] = []) {
        source.forEach { self.addItem($0) }
    }

    public mutating func addItem(item: Any) {
        if let routeSequenceItem = item as? RouteSequenceItem {
            items.append(routeSequenceItem)
        } else if let segmentIdentifier = item as? Identifier {
            items.append(RouteSequenceItem(segmentIdentifier: segmentIdentifier, options:[:]))
        } else if let name = item as? String {
            items.append(RouteSequenceItem(segmentIdentifier: Identifier(name: name), options:[:]))
        } else {
            print("Invalid sourceItem: \(item)")
        }
    }

}

public struct RouteSequenceItem {
    public let segmentIdentifier: Identifier
    public let options: RouteSequenceOptions

    public init(segmentIdentifier: Identifier, options: RouteSequenceOptions) {
        self.segmentIdentifier = segmentIdentifier
        self.options = options
    }
}

public protocol RouterType {
    var window: UIWindow? { get }
    var routeSegments: [Identifier: RouteSegmentType] { get }
    var presenters: [Identifier: RouteSegmentPresenterType] { get }
    var viewControllers: [UIViewController] { get }
    func registerPresenter(presenter: RouteSegmentPresenterType)
    func registerRouteSegment(routeSegment: RouteSegmentType)
    func appendRouteOnMain(source: [Any])
    func executeRouteOnMain(source: [Any])
    func appendRoute(source: [Any]) -> Bool
    func executeRoute(source: [Any]) -> Bool
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
            if let p = vc?.parentViewController {
                result += ",p=" + String(p.dynamicType)
            }
            print(result)
        }
    }

    public private(set) var routeSegments:[Identifier:RouteSegmentType] = [:]
    public private(set) var presenters:[Identifier:RouteSegmentPresenterType] = [:]

    public let window: UIWindow?

    public var viewControllers:[UIViewController] {
        return currentActiveSegments.flatMap { $0.viewController }
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
        registerPresenter(WrappingRouteSegmentPresenter(wrappingRouteSegmentAnimator: SlidingWrappingRouteSegmentAnimator()))
    }

    public var currentSequence:[Any] {
        return currentActiveSegments.map {
            activeSegment -> Identifier in
            return activeSegment.segmentIdentifier
        }
    }

    public func appendRouteOnMain(source: [Any]) {
        dispatch_async(dispatch_get_main_queue()) {
            self.appendRoute(source)
        }
    }

    public func executeRouteOnMain(source: [Any]) {
        dispatch_async(dispatch_get_main_queue()) {
            self.executeRoute(source)
        }
    }

    public func appendRoute(source: [Any]) -> Bool {
        return self.executeRouteSequence(source, append: true)
    }

    public func executeRoute(source: [Any]) -> Bool {
        return self.executeRouteSequence(source, append: false)
    }

    private func executeRouteSequence(source: [Any], append: Bool) -> Bool {
        var newActiveSegments:[ActiveSegment] = []
        var routeChanged = false
        defer {
            currentActiveSegments = newActiveSegments
        }
        let useRouteSequence = RouteSequence(source: source)
        var parent: UIViewController?

        if append {
            newActiveSegments.appendContentsOf(currentActiveSegments)
            parent = currentActiveSegments.last?.viewController
        }

        for itemIndex in 0..<useRouteSequence.items.count {
            let routeSequenceItem = useRouteSequence.items[itemIndex]
            let segmentIdentifier = routeSequenceItem.segmentIdentifier
            guard let routeSegment = routeSegments[segmentIdentifier] else {
                print("No segment registered for: \(segmentIdentifier)")
                return false
            }

            let isLastSegment = (itemIndex == (routeSegments.count - 1))
            let parentActiveSegment = currentActiveSegments[safe: itemIndex-1]
            let currentActiveSegment = currentActiveSegments[safe: itemIndex]
            let nextActiveSegment = currentActiveSegments[safe: itemIndex+1]
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
                if let presenter = presenters[routeSegment.presenterIdentifier] {
                    if let visualPresenter = presenter as? VisualRouteSegmentPresenterType,
                        let visualRouteSegment = routeSegment as? VisualRouteSegmentType {
                        if let viewController = visualRouteSegment.viewController() {
                            child = viewController
                            visualPresenter.presentViewController(viewController, from: parent, options: routeSequenceItem.options, window: window, completion: {
                                success in
                                completionSucessful = success
                            })
                        }
                    } else {
                        print("WARNING: Need to handle non-visual presenters & segments: \(presenter)")
                        return false
                    }
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
                    if var lastChild = child, let lastChildNavigationController = lastChild.navigationController {
                        let lastChildParent = lastChild.parentViewController!

                        // TODO: this is all a kluge to trigger the menuPresenter to properly remove things
                        var stillNeedToPop = true
                        if lastChildNavigationController != lastChildParent {
                            let nextRouteSegment = routeSegments[nextActiveSegment!.segmentIdentifier]!
                            if let presenter = presenters[nextRouteSegment.presenterIdentifier] {
                                stillNeedToPop = false
                                if let visualPresenter = presenter as? VisualRouteSegmentPresenterType {
                                    lastChild = visualPresenter.presentViewController(lastChildParent, from: lastChildParent, options: [:], window: nil, completion: {
                                        _ in
                                    })!
                                    child = lastChild
                                } else {
                                    print("WARNING: Need to handle non-visual presenters")
                                    return false
                                }
                            }
                        }
                        if stillNeedToPop {
                            lastChildNavigationController.popToViewController(lastChild, animated: true)
                        }
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

private extension CollectionType {
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

private struct ActiveSegment {
    let segmentIdentifier: Identifier

    let viewController: UIViewController?
}
