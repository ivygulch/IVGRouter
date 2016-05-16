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
    func presentViewController(presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: (RoutingResult -> Void))
}

public protocol ReversibleRouteSegmentPresenterType: RouteSegmentPresenterType {
    func reversePresentation(viewControllerToRemove : UIViewController, completion: (RoutingResult -> Void))
}

public protocol BranchRouteSegmentPresenterType: RouteSegmentPresenterType {
    func selectBranch(branchRouteSegmentIdentifier: Identifier, from trunkRouteController: TrunkRouteController, options: RouteSequenceOptions, completion: (RoutingResult -> Void))
}
