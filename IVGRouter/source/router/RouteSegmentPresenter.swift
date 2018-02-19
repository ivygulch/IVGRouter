//
//  RouteSegmentPresenter.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/4/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public protocol RouteSegmentPresenterType {
    static var defaultPresenterIdentifier: Identifier { get }
    var presenterIdentifier: Identifier { get }
}

public protocol VisualRouteSegmentPresenterType: RouteSegmentPresenterType {
    func present(viewController presentedViewController: UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: @escaping ((RoutingResult) -> Void))
}

public protocol ReversibleRouteSegmentPresenterType: RouteSegmentPresenterType {
    func reverse(viewController viewControllerToRemove: UIViewController, completion: @escaping  ((RoutingResult) -> Void))
}

public protocol BranchRouteSegmentPresenterType: RouteSegmentPresenterType {
    func select(branchRouteSegmentIdentifier: Identifier, from trunkRouteController: TrunkRouteController, options: RouteSequenceOptions, completion: @escaping  ((RoutingResult) -> Void))
}
