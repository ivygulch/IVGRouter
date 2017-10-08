//
//  PushRouteSegmentPresenter.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public struct PushRouteSegmentPresenterOptions {
    public static let AnimatedKey = "animated"
    public static let AnimatedDefault = true

    static func animated(fromOptions options: RouteSequenceOptions) -> Bool {
        return options[PushRouteSegmentPresenterOptions.AnimatedKey] as? Bool ?? PushRouteSegmentPresenterOptions.AnimatedDefault
    }
}

open class PushRouteSegmentPresenter : BaseRouteSegmentPresenter, VisualRouteSegmentPresenterType, ReversibleRouteSegmentPresenterType {

    open static let defaultPresenterIdentifier = Identifier(name: String(describing: PushRouteSegmentPresenter.self))

    fileprivate func configurationError(withStack stack: [UIViewController], additional: UIViewController? = nil) -> RoutingErrors? {
        var existingSet = Set<UIViewController>()
        for viewController in stack {
            if existingSet.contains(viewController) {
                return RoutingErrors.invalidConfiguration("View controllers may only appear once in view controller stack: \(viewController)")
            }
            existingSet.insert(viewController)
        }
        if let additional = additional {
            if existingSet.contains(additional) {
                return RoutingErrors.invalidConfiguration("View controllers may only appear once in view controller stack: \(additional)")
            }
        }
        return nil
    }

    fileprivate func setRoot(toViewController presentedViewController : UIViewController, navigationController: UINavigationController, options: RouteSequenceOptions, completion: @escaping ((RoutingResult) -> Void)) {
        let stack = [presentedViewController]
        if let stackConfigurationError = configurationError(withStack: stack) {
            completion(.failure(stackConfigurationError))
            return
        }
        let animated = PushRouteSegmentPresenterOptions.animated(fromOptions: options)
        navigationController.set(viewControllers: stack, animated: animated, completion: {
            completion(.success(presentedViewController))
        })
    }

    fileprivate func push(viewController presentedViewController : UIViewController, navigationController: UINavigationController, options: RouteSequenceOptions, completion: @escaping ((RoutingResult) -> Void)) {
        if let stackConfigurationError = configurationError(withStack: navigationController.viewControllers, additional: presentedViewController) {
            completion(.failure(stackConfigurationError))
            return
        }
        let animated = PushRouteSegmentPresenterOptions.animated(fromOptions: options)
        navigationController.push(viewController: presentedViewController, animated: animated, completion: {
            completion(.success(presentedViewController))
        })
    }

    fileprivate func pop(navigationController: UINavigationController, completion: @escaping ((RoutingResult) -> Void)) {
        guard navigationController.viewControllers.count > 1 else {
            completion(.failure(RoutingErrors.couldNotReversePresentation(self.presenterIdentifier)))
            return
        }

        let animated = true
        navigationController.pop(animated: animated, completion: {
            completion(.success(navigationController.topViewController!))
        })
    }

    open func present(viewController presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: @escaping ((RoutingResult) -> Void)) {
        if let asNavigationController = presentingViewController as? UINavigationController {
            setRoot(toViewController: presentedViewController, navigationController: asNavigationController, options: options, completion: completion)
            return
        }

        if verify(checkNotNil(presentingViewController?.navigationController, "presentingViewController.navigationController"), completion: completion),
            let navigationController = presentingViewController?.navigationController {
            push(viewController: presentedViewController, navigationController: navigationController, options: options, completion: completion)
        }
    }

    // TODO: consider passing options here, would need to figure out what they were  
    open func reverse(viewController viewControllerToRemove : UIViewController, completion: @escaping ((RoutingResult) -> Void)) {
        if verify(checkNotNil(viewControllerToRemove.navigationController, "viewControllerToRemove.navigationController"), completion: completion) {
            let navigationController = viewControllerToRemove.navigationController!

            pop(navigationController: navigationController, completion: completion)
        }
    }


}

extension UINavigationController {

    fileprivate func add(completion: @escaping (() -> Void)) -> Bool {
        if let transitionCoordinator = transitionCoordinator {
            return transitionCoordinator.animate(alongsideTransition: nil,
                completion: { _ in
                    completion()
                }
            )
        }
        return false
    }

    func pop(animated: Bool, completion: @escaping (() -> Void)) {
        self.popViewController(animated: animated)
        if !add(completion: completion) {
            completion()
        }
    }

    func push(viewController: UIViewController, animated: Bool, completion: @escaping (() -> Void)) {
        self.pushViewController(viewController, animated: animated)
        if !add(completion: completion) {
            completion()
        }
    }

    func set(viewControllers: [UIViewController], animated: Bool, completion: @escaping (() -> Void)) {
        self.setViewControllers(viewControllers, animated: animated)
        if !add(completion: completion) {
            completion()
        }
    }

}
