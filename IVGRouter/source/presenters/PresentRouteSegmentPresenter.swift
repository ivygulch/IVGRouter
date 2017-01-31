//
//  PresentRouteSegmentPresenter.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 1/27/17.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

open class PresentRouteSegmentPresenter : BaseRouteSegmentPresenter, VisualRouteSegmentPresenterType {

    open static let defaultPresenterIdentifier = Identifier(name: String(describing: PresentRouteSegmentPresenter.self))

    open func present(viewController presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: @escaping ((RoutingResult) -> Void)) {
        guard verify(checkNotNil(presentingViewController, "presentingViewController"), completion: completion),
            let parentViewController = presentingViewController else {
                return
        }

        parentViewController.present(presentedViewController, animated: true) {
            completion(.success(presentedViewController))
        }
    }
}
