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

class MockVisualRouteSegmentPresenter: TrackableTestClass, VisualRouteSegmentPresenterType, ReversibleRouteSegmentPresenterType {

    static let defaultPresenterIdentifier = Identifier(name: String(describing: MockVisualRouteSegmentPresenter.self))

    init(presenterIdentifier: String, completionBlockArg: Bool) {
        self.presenterIdentifier = Identifier(name: presenterIdentifier)
        self.completionBlockArg = completionBlockArg
    }

    let presenterIdentifier: Identifier

    func present(viewController presentedViewController: UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: @escaping (RoutingResult) -> Void)  {
        let from = presentingViewController?.description ?? "nil"
        let windowID = window == nil ? "nil": "\(Unmanaged.passUnretained(window!).toOpaque())"
        track("presentViewController", [presentedViewController.description,from,windowID])
        if completionBlockArg {
            completion(.success(presentedViewController))
        } else {
            completion(.failure(RoutingErrors.cannotPresent(self.presenterIdentifier, "mock result is false")))
        }
    }

    func reverse(viewController viewControllerToRemove: UIViewController, completion: @escaping ((RoutingResult) -> Void)) {
        track("reversePresentation", [viewControllerToRemove.description])
        if completionBlockArg {
            completion(.success(viewControllerToRemove))
        } else {
            completion(.failure(RoutingErrors.cannotPresent(self.presenterIdentifier, "mock result is false")))
        }
    }

    fileprivate let completionBlockArg: Bool
}
