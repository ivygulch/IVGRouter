//
//  RootRouteSegmentPresenter.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public class RootRouteSegmentPresenter : BaseRouteSegmentPresenter, VisualRouteSegmentPresenterType {

    public static let defaultPresenterIdentifier = Identifier(name: String(RootRouteSegmentPresenter))

    public func presentViewController(presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: ((Bool, UIViewController?) -> Void)) {
        guard verify(checkNotNil(window, "Router.window"), completion: completion),
            let window = window else {
            return
        }
        guard verify(checkNil(presentingViewController, "presentingViewController"), completion: completion) else {
            return
        }
        window.rootViewController = presentedViewController
        window.makeKeyAndVisible()
        completion(true, presentedViewController)
    }
    
}
