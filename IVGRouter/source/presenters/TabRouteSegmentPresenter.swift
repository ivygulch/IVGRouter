//
//  TabRouteSegmentPresenter.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public struct TabRouteSegmentPresenterOptions {
    public static let AppendOnlyKey = "appendOnly"
    public static let AppendOnlyDefault = false

    static func appendOnlyFromOptions(options: RouteSequenceOptions) -> Bool {
        return options[TabRouteSegmentPresenterOptions.AppendOnlyKey] as? Bool ?? TabRouteSegmentPresenterOptions.AppendOnlyDefault
    }
}


public class TabRouteSegmentPresenter : BaseRouteSegmentPresenter, VisualRouteSegmentPresenterType {

    public static let defaultPresenterIdentifier = Identifier(name: String(TabRouteSegmentPresenter))

    public func presentViewController(presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: (RoutingResult -> Void)) {
        guard verify(checkType(presentingViewController, type:UITabBarController.self, "presentingViewController"), completion: completion),
            let tabBarController = presentingViewController as? UITabBarController
            else {
                return
        }

        if TabRouteSegmentPresenterOptions.appendOnlyFromOptions(options) {
            tabBarController.appendViewControllerIfNeeded(presentedViewController)
        } else {
            tabBarController.selectViewControllerAppendingIfNeeded(presentedViewController)
        }

        completion(.Success(presentedViewController))
    }

}

extension UITabBarController {

    func selectViewControllerAppendingIfNeeded(viewController: UIViewController) {
        appendViewControllerIfNeeded(viewController)
        selectedViewController = viewController
    }

    func appendViewControllerIfNeeded(viewController: UIViewController) {
        let exists = viewControllers?.contains(viewController) ?? false
        if !exists {
            appendViewController(viewController)
        }
    }

    func appendViewController(viewController: UIViewController) {
        var useViewControllers = viewControllers ?? []
        useViewControllers.append(viewController)
        viewControllers = useViewControllers
    }
    
}
