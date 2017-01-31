//
//  SetRouteSegmentPresenter.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

open class SetRouteSegmentPresenter : BaseRouteSegmentPresenter, VisualRouteSegmentPresenterType {

    open static let defaultPresenterIdentifier = Identifier(name: String(describing: SetRouteSegmentPresenter.self))

    open func present(viewController presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: @escaping ((RoutingResult) -> Void)) {
        guard verify(checkNotNil(presentingViewController, "presentingViewController"), completion: completion),
            let parentViewController = presentingViewController else {
            return
        }

        if let placeholderViewController = parentViewController as? PlaceholderViewController {
            placeholderViewController.childViewController = presentedViewController
            completion(.success(presentedViewController))
        } else if presentedViewController == parentViewController.childViewControllers.first {
            completion(.success(presentedViewController))
        } else {
            let childViewControllers = parentViewController.childViewControllers
            for childViewController in childViewControllers {
                childViewController.willMove(toParentViewController: nil)
                childViewController.view.removeFromSuperview()
                childViewController.removeFromParentViewController()
            }

            if let navigationController = parentViewController as? UINavigationController {
                navigationController.viewControllers = [presentedViewController]
            } else {
                presentedViewController.view.frame = parentViewController.view.bounds
                presentedViewController.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
                parentViewController.addChildViewController(presentedViewController)
                parentViewController.view.addSubview(presentedViewController.view)
                presentedViewController.didMove(toParentViewController: parentViewController)
            }
            completion(.success(presentedViewController))
        }

    }
}
