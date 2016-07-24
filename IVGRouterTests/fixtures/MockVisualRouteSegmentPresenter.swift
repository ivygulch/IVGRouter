//
//  MockVisualRouteSegmentPresenter.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/1/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class MockVisualRouteSegmentPresenter : TrackableTestClass, VisualRouteSegmentPresenterType, ReversibleRouteSegmentPresenterType {

    static let defaultPresenterIdentifier = Identifier(name: String(MockVisualRouteSegmentPresenter))

    init(presenterIdentifier: String, completionBlockArg: Bool) {
        self.presenterIdentifier = Identifier(name: presenterIdentifier)
        self.completionBlockArg = completionBlockArg
    }

    let presenterIdentifier: Identifier

    func presentViewController(presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: RoutingResult -> Void)  {
        let from = presentingViewController?.description ?? "nil"
        let windowID = window == nil ? "nil" : "\(unsafeAddressOf(window!))"
        track("presentViewController", [presentedViewController.description,from,windowID])
        if completionBlockArg {
            completion(.Success(presentedViewController))
        } else {
            completion(.Failure(RoutingErrors.CannotPresent(self.presenterIdentifier, "mock result is false")))
        }
    }

    func reversePresentation(viewControllerToRemove : UIViewController, completion: (RoutingResult -> Void)) {
        track("reversePresentation", [viewControllerToRemove.description])
        if completionBlockArg {
            completion(.Success(viewControllerToRemove))
        } else {
            completion(.Failure(RoutingErrors.CannotPresent(self.presenterIdentifier, "mock result is false")))
        }
    }

    private let completionBlockArg: Bool
}
