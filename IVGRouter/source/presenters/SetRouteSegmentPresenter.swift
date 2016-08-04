//
//  SetRouteSegmentPresenter.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public class SetRouteSegmentPresenter : BaseRouteSegmentPresenter, VisualRouteSegmentPresenterType {

    public static let defaultPresenterIdentifier = Identifier(name: String(SetRouteSegmentPresenter))

    public func presentViewController(presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: (RoutingResult -> Void)) {
        guard verify(checkNotNil(presentingViewController, "presentingViewController"), completion: completion),
            let parentViewController = presentingViewController else {
            return
        }

        if let placeholderViewController = parentViewController as? PlaceholderViewController {
            placeholderViewController.childViewController = presentedViewController
            completion(.Success(presentedViewController))
        } else if presentedViewController == parentViewController.childViewControllers.first {
            completion(.Success(presentedViewController))
        } else {
            let childViewControllers = parentViewController.childViewControllers
            for childViewController in childViewControllers {
                childViewController.willMoveToParentViewController(nil)
                childViewController.view.removeFromSuperview()
                childViewController.removeFromParentViewController()
            }

            if let navigationController = parentViewController as? UINavigationController {
                navigationController.viewControllers = [presentedViewController]
            } else {
                presentedViewController.view.frame = parentViewController.view.bounds
                presentedViewController.view.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
                parentViewController.addChildViewController(presentedViewController)
                parentViewController.view.addSubview(presentedViewController.view)
                presentedViewController.didMoveToParentViewController(parentViewController)
            }
            completion(.Success(presentedViewController))
        }

    }
}
