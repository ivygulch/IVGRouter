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

    static func animatedFromOptions(options: RouteSequenceOptions) -> Bool {
        return options[PushRouteSegmentPresenterOptions.AnimatedKey] as? Bool ?? PushRouteSegmentPresenterOptions.AnimatedDefault
    }
}

public class PushRouteSegmentPresenter : BaseRouteSegmentPresenter, VisualRouteSegmentPresenterType {

    public static let defaultPresenterIdentifier = Identifier(name: String(PushRouteSegmentPresenter))

    private func stackConfigurationError(stack:[UIViewController], additional:UIViewController? = nil) -> RoutingErrors? {
        var existingSet = Set<UIViewController>()
        for viewController in stack {
            if existingSet.contains(viewController) {
                return RoutingErrors.InvalidConfiguration("View controllers may only appear once in view controller stack: \(viewController)")
            }
            existingSet.insert(viewController)
        }
        if let additional = additional {
            if existingSet.contains(additional) {
                return RoutingErrors.InvalidConfiguration("View controllers may only appear once in view controller stack: \(additional)")
            }
        }
        return nil
    }

    private func setViewControllerAsRoot(presentedViewController : UIViewController, navigationController: UINavigationController, options: RouteSequenceOptions, completion: (RoutingResult -> Void)) {
        let stack = [presentedViewController]
        if let stackConfigurationError = stackConfigurationError(stack) {
            completion(.Failure(stackConfigurationError))
            return
        }
        let animated = PushRouteSegmentPresenterOptions.animatedFromOptions(options)
        navigationController.setViewControllers(stack, animated: animated, completion: {
            completion(.Success(presentedViewController))
        })
    }

    private func pushViewController(presentedViewController : UIViewController, navigationController: UINavigationController, options: RouteSequenceOptions, completion: (RoutingResult -> Void)) {
        if let stackConfigurationError = stackConfigurationError(navigationController.viewControllers, additional:presentedViewController) {
            completion(.Failure(stackConfigurationError))
            return
        }
        let animated = PushRouteSegmentPresenterOptions.animatedFromOptions(options)
        navigationController.pushViewController(presentedViewController, animated: animated, completion: {
            completion(.Success(presentedViewController))
        })
    }

    public func presentViewController(presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: (RoutingResult -> Void)) {
        if let asNavigationController = presentingViewController as? UINavigationController {
            setViewControllerAsRoot(presentedViewController, navigationController: asNavigationController, options: options, completion: completion)
            return
        }

        if verify(checkNotNil(presentingViewController?.navigationController, "presentingViewController.navigationController"), completion: completion),
            let navigationController = presentingViewController?.navigationController {
            pushViewController(presentedViewController, navigationController: navigationController, options: options, completion: completion)
        }
    }
    
}

extension UINavigationController {

    private func addCompletion(completion:(Void -> Void)) -> Bool {
        if let transitionCoordinator = transitionCoordinator() {
            return transitionCoordinator.animateAlongsideTransition(nil,
                completion: {
                    _ in
                    completion()
                }
            )
        }
        return false
    }

    func popViewControllerAnimated(animated: Bool, completion:(Void -> Void)) {
        self.popViewControllerAnimated(animated)
        if !addCompletion(completion) {
            completion()
        }
    }

    func pushViewController(viewController: UIViewController, animated: Bool, completion:(Void -> Void)) {
        self.pushViewController(viewController, animated: animated)
        if !addCompletion(completion) {
            completion()
        }
    }

    func setViewControllers(viewControllers: [UIViewController], animated: Bool, completion:(Void -> Void)) {
        self.setViewControllers(viewControllers, animated: animated)
        if !addCompletion(completion) {
            completion()
        }
    }

}
