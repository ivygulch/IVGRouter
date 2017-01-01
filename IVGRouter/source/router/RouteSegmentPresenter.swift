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
    func presentViewController(_ presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion:@escaping ((RoutingResult) -> Void))
}

public protocol ReversibleRouteSegmentPresenterType: RouteSegmentPresenterType {
    func reversePresentation(_ viewControllerToRemove : UIViewController, completion:@escaping  ((RoutingResult) -> Void))
}

public protocol BranchRouteSegmentPresenterType: RouteSegmentPresenterType {
    func selectBranch(_ branchRouteSegmentIdentifier: Identifier, from trunkRouteController: TrunkRouteController, options: RouteSequenceOptions, completion:@escaping  ((RoutingResult) -> Void))
}
