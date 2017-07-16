//
//  PresentRouteSegmentPresenter.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 1/27/17.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

open class PresentRouteSegmentPresenter : BaseRouteSegmentPresenter, VisualRouteSegmentPresenterType, ReversibleRouteSegmentPresenterType {

    public static let autoDismissPresenterIdentifier = Identifier(name: String(describing: PresentRouteSegmentPresenter.self) + ".autoDismiss")
    public static let defaultPresenterIdentifier = Identifier(name: String(describing: PresentRouteSegmentPresenter.self))

    private var autoDismiss: Bool { return presenterIdentifier == PresentRouteSegmentPresenter.autoDismissPresenterIdentifier }

    open func present(viewController presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: @escaping ((RoutingResult) -> Void)) {
        guard verify(checkNotNil(presentingViewController, "presentingViewController"), completion: completion),
            let parentViewController = presentingViewController else {
                return
        }

        parentViewController.present(presentedViewController, animated: true) {
            completion(.success(presentedViewController))
        }
    }

    open func reverse(viewController viewControllerToRemove : UIViewController, completion: @escaping  ((RoutingResult) -> Void)) {
        if autoDismiss {
             // nothing to do here, the caller promises to handle it (probably via an AlertViewController)
            completion(.success(viewControllerToRemove))
            return
        }
        guard let presentingViewController = viewControllerToRemove.presentingViewController else {
            completion(.failure(RoutingErrors.couldNotReversePresentation(self.presenterIdentifier)))
            return
        }

        presentingViewController.dismiss(animated: true) {
            completion(.success(viewControllerToRemove))
        }
    }

}
