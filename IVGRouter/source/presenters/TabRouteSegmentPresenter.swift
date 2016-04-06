//
//  TabRouteSegmentPresenter.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public class TabRouteSegmentPresenter : BaseRouteSegmentPresenter, RouteSegmentPresenterType {

    public func presentViewController(presentedViewController : UIViewController, from presentingViewController: UIViewController?, withWindow window: UIWindow?, completion: ((Bool) -> Void)) -> UIViewController?{
        guard verify(checkType(presentingViewController, type:UITabBarController.self, "presentingViewController"), completion: completion),
            let tabBarController = presentingViewController as? UITabBarController
            else {
                return nil
        }

        tabBarController.selectViewControllerAppendingIfNeeded(presentedViewController)
        completion(true)
        return presentedViewController
    }

}

extension UITabBarController {

    func selectViewControllerAppendingIfNeeded(viewController: UIViewController) {
        if let exists = viewControllers?.contains(viewController) where !exists {
            appendViewController(viewController)
        }
        selectedViewController = viewController
    }

    func appendViewController(viewController: UIViewController) {
        var useViewControllers = viewControllers ?? []
        useViewControllers.append(viewController)
        viewControllers = useViewControllers
    }

}

