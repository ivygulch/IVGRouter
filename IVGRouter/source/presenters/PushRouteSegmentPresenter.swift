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

    static func animatedFromOptions(_ options: RouteSequenceOptions) -> Bool {
        return options[PushRouteSegmentPresenterOptions.AnimatedKey] as? Bool ?? PushRouteSegmentPresenterOptions.AnimatedDefault
    }
}

public class PushRouteSegmentPresenter : BaseRouteSegmentPresenter, VisualRouteSegmentPresenterType, ReversibleRouteSegmentPresenterType {

    public static let defaultPresenterIdentifier = Identifier(name: String(describing: PushRouteSegmentPresenter.self))

    private func stackConfigurationError(_ stack:[UIViewController], additional:UIViewController? = nil) -> RoutingErrors? {
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

    private func setViewControllerAsRoot(_ presentedViewController : UIViewController, navigationController: UINavigationController, options: RouteSequenceOptions, completion: @escaping ((RoutingResult) -> Void)) {
        let stack = [presentedViewController]
        if let stackConfigurationError = stackConfigurationError(stack) {
            completion(.failure(stackConfigurationError))
            return
        }
        let animated = PushRouteSegmentPresenterOptions.animatedFromOptions(options)
        navigationController.setViewControllers(stack, animated: animated, completion: {
            completion(.success(presentedViewController))
        })
    }

    private func pushViewController(_ presentedViewController : UIViewController, navigationController: UINavigationController, options: RouteSequenceOptions, completion: @escaping ((RoutingResult) -> Void)) {
        if let stackConfigurationError = stackConfigurationError(navigationController.viewControllers, additional:presentedViewController) {
            completion(.failure(stackConfigurationError))
            return
        }
        let animated = PushRouteSegmentPresenterOptions.animatedFromOptions(options)
        navigationController.pushViewController(presentedViewController, animated: animated, completion: {
            completion(.success(presentedViewController))
        })
    }

    private func popViewController(_ navigationController: UINavigationController, completion: @escaping ((RoutingResult) -> Void)) {
        guard navigationController.viewControllers.count > 1 else {
            completion(.failure(RoutingErrors.couldNotReversePresentation(self.presenterIdentifier)))
            return
        }

        let animated = true
        navigationController.popViewControllerAnimated(animated, completion: {
            completion(.success(navigationController.topViewController!))
        })
    }

    public func presentViewController(_ presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: @escaping ((RoutingResult) -> Void)) {
        if let asNavigationController = presentingViewController as? UINavigationController {
            setViewControllerAsRoot(presentedViewController, navigationController: asNavigationController, options: options, completion: completion)
            return
        }

        if verify(checkNotNil(presentingViewController?.navigationController, "presentingViewController.navigationController"), completion: completion),
            let navigationController = presentingViewController?.navigationController {
            pushViewController(presentedViewController, navigationController: navigationController, options: options, completion: completion)
        }
    }

    // TODO: consider passing options here, would need to figure out what they were  
    public func reversePresentation(_ viewControllerToRemove : UIViewController, completion: @escaping ((RoutingResult) -> Void)) {
        if verify(checkNotNil(viewControllerToRemove.navigationController, "viewControllerToRemove.navigationController"), completion: completion) {
            let navigationController = viewControllerToRemove.navigationController!

            popViewController(navigationController, completion: completion)
        }
    }


}

extension UINavigationController {

    private func addCompletion(_ completion:@escaping ((Void) -> Void)) -> Bool {
        if let transitionCoordinator = transitionCoordinator {
            return transitionCoordinator.animate(alongsideTransition: nil,
                completion: {
                    _ in
                    completion()
                }
            )
        }
        return false
    }

    func popViewControllerAnimated(_ animated: Bool, completion:@escaping ((Void) -> Void)) {
        self.popViewController(animated: animated)
        if !addCompletion(completion) {
            completion()
        }
    }

    func pushViewController(_ viewController: UIViewController, animated: Bool, completion:@escaping ((Void) -> Void)) {
        self.pushViewController(viewController, animated: animated)
        if !addCompletion(completion) {
            completion()
        }
    }

    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool, completion:@escaping ((Void) -> Void)) {
        self.setViewControllers(viewControllers, animated: animated)
        if !addCompletion(completion) {
            completion()
        }
    }

}
