//
//  PresentRouteSegmentPresenter.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 1/27/17.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public class PresentRouteSegmentPresenter : BaseRouteSegmentPresenter, VisualRouteSegmentPresenterType {

    public static let defaultPresenterIdentifier = Identifier(name: String(describing: PresentRouteSegmentPresenter.self))

    public func presentViewController(_ presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: @escaping ((RoutingResult) -> Void)) {
        guard verify(checkNotNil(presentingViewController, "presentingViewController"), completion: completion),
            let parentViewController = presentingViewController else {
                return
        }

        parentViewController.present(presentedViewController, animated: true) {
            completion(.success(presentedViewController))
        }
    }
}
