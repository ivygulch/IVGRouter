//
//  RootRouteSegmentPresenter.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

open class RootRouteSegmentPresenter : BaseRouteSegmentPresenter, VisualRouteSegmentPresenterType {

    open static let defaultPresenterIdentifier = Identifier(name: String(describing: RootRouteSegmentPresenter.self))

    open func presentViewController(_ presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: @escaping ((RoutingResult) -> Void)) {
        guard verify(checkNotNil(window, "Router.window"), completion: completion),
            let window = window else {
            return
        }
        guard verify(checkNil(presentingViewController, "presentingViewController"), completion: completion) else {
            return
        }
        window.rootViewController = presentedViewController
        window.makeKeyAndVisible()
        completion(.success(presentedViewController))
    }
    
}
