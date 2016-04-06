//
//  PushRouteSegmentPresenter.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public struct PushRouteSegmentPresenterOptions {
    public static let PushAnimatedKey = "animated"
    public static let PushAnimatedDefault = true
}

public class PushRouteSegmentPresenter : BaseRouteSegmentPresenter, RouteSegmentPresenterType {

    private func stackIsValid(stack:[UIViewController], additional:UIViewController? = nil) -> Bool {
        var existingSet = Set<UIViewController>()
        for viewController in stack {
            if existingSet.contains(viewController) {
                print("View controllers may only appear once in view controller stack: \(viewController)")
                return false
            }
            existingSet.insert(viewController)
        }
        if let additional = additional {
            if existingSet.contains(additional) {
                print("View controllers may only appear once in view controller stack: \(additional)")
                return false
            }
        }
        return true
    }

    private func setViewControllerAsRoot(presentedViewController : UIViewController, navigationController: UINavigationController, options: RouteSequenceOptions, completion: ((Bool) -> Void)) -> UIViewController? {
        let stack = [presentedViewController]
        guard stackIsValid(stack) else {
            completion(false)
            return nil
        }
        let animated = options[PushRouteSegmentPresenterOptions.PushAnimatedKey] as? Bool ?? PushRouteSegmentPresenterOptions.PushAnimatedDefault
        navigationController.setViewControllers(stack, animated: animated, completion: {
            completion(true)
        })
        return presentedViewController
    }

    private func pushViewController(presentedViewController : UIViewController, navigationController: UINavigationController, options: RouteSequenceOptions, completion: ((Bool) -> Void)) -> UIViewController? {
        guard stackIsValid(navigationController.viewControllers, additional:presentedViewController) else {
            completion(false)
            return nil
        }
        let animated = options[PushRouteSegmentPresenterOptions.PushAnimatedKey] as? Bool ?? PushRouteSegmentPresenterOptions.PushAnimatedDefault
        navigationController.pushViewController(presentedViewController, animated: animated, completion: {
            completion(true)
        })
        return presentedViewController
    }

    public func presentViewController(presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: ((Bool) -> Void)) -> UIViewController?{
        if let asNavigationController = presentingViewController as? UINavigationController {
            return setViewControllerAsRoot(presentedViewController, navigationController: asNavigationController, options: options, completion: completion)
        }

        if verify(checkNotNil(presentingViewController?.navigationController, "presentingViewController.navigationController"), completion: completion),
            let navigationController = presentingViewController?.navigationController {
            return pushViewController(presentedViewController, navigationController: navigationController, options: options, completion: completion)
        }

        return nil
    }
    
}

extension UINavigationController {

    func popViewControllerAnimated(animated: Bool, completion:(Void -> Void)) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popViewControllerAnimated(animated)
        CATransaction.commit()
    }

    func pushViewController(viewController: UIViewController, animated: Bool, completion:(Void -> Void)) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }

    func setViewControllers(viewControllers: [UIViewController], animated: Bool, completion:(Void -> Void)) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.setViewControllers(viewControllers, animated: animated)
        CATransaction.commit()
    }

}
