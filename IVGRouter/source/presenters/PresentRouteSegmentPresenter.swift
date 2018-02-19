//
//  PresentRouteSegmentPresenter.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 1/27/17.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public struct PresentRouteSegmentPresenterOptions {
    public static let modalPresentationStyleKey = "modalPresentationStyle"
}

open class PresentRouteSegmentPresenter: BaseRouteSegmentPresenter, VisualRouteSegmentPresenterType, ReversibleRouteSegmentPresenterType {

    public static let autoDismissPresenterIdentifier = Identifier(name: String(describing: PresentRouteSegmentPresenter.self) + ".autoDismiss")
    public static let fromRootPresenterIdentifier = Identifier(name: String(describing: PresentRouteSegmentPresenter.self) + ".fromRoot")
    public static let defaultPresenterIdentifier = Identifier(name: String(describing: PresentRouteSegmentPresenter.self))

    private var isAutoDismiss: Bool { return presenterIdentifier == PresentRouteSegmentPresenter.autoDismissPresenterIdentifier }
    private var isFromRoot: Bool { return presenterIdentifier == PresentRouteSegmentPresenter.fromRootPresenterIdentifier }

    open func present(viewController presentedViewController: UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: @escaping ((RoutingResult) -> Void)) {
        var usePresentingViewController = presentingViewController
        if isFromRoot {
            while usePresentingViewController?.parent != nil {
                usePresentingViewController = usePresentingViewController?.parent
            }
        }
        guard verify(checkNotNil(usePresentingViewController, "presentingViewController"), completion: completion),
            let parentViewController = usePresentingViewController else {
                return
        }

        var modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        if let value = options[PresentRouteSegmentPresenterOptions.modalPresentationStyleKey] as? Int,
            let style = UIModalPresentationStyle(rawValue: value) {
            modalPresentationStyle = style
        }
        presentedViewController.modalPresentationStyle = modalPresentationStyle
        parentViewController.present(presentedViewController, animated: true) {
            completion(.success(presentedViewController))
        }
    }

    open func reverse(viewController viewControllerToRemove: UIViewController, completion: @escaping  ((RoutingResult) -> Void)) {
        if isAutoDismiss {
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
