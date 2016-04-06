//
//  RootRouteSegmentPresenter.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public class RootRouteSegmentPresenter : BaseRouteSegmentPresenter, RouteSegmentPresenterType {

    public func presentViewController(presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: ((Bool) -> Void)) -> UIViewController? {
        guard verify(checkNotNil(window, "Router.window"), completion: completion),
            let window = window else {
            return nil
        }
        guard verify(checkNil(presentingViewController, "presentingViewController"), completion: completion) else {
            return nil
        }
        window.rootViewController = presentedViewController
        window.makeKeyAndVisible()
        completion(true)
        return presentedViewController
    }
    
}
