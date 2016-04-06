//
//  PushRouteSegmentPresenter.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public class PushRouteSegmentPresenter : BaseRouteSegmentPresenter, RouteSegmentPresenterType {

    public func presentViewController(presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: ((Bool) -> Void)) -> UIViewController?{
        guard verify(checkType(presentingViewController, type:UINavigationController.self, "presentingViewController"), completion: completion),
            let navigationController = presentingViewController as? UINavigationController
            else {
                return nil
        }

        navigationController.pushViewController(presentedViewController, animated: true)
        completion(true)
        return presentedViewController
    }

}
