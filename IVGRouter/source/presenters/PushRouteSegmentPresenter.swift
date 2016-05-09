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
        let animated = PushRouteSegmentPresenterOptions.animatedFromOptions(options)
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
        let animated = PushRouteSegmentPresenterOptions.animatedFromOptions(options)
        print("DBG: about to present \(presentedViewController)")
        navigationController.pushViewController(presentedViewController, animated: animated, completion: {
            print("DBG: before completion, presented \(presentedViewController)")
            completion(true)
            print("DBG: after completion, presented \(presentedViewController)")
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
