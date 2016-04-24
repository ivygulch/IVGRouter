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
    func presentViewController(presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: ((Bool) -> Void)) -> UIViewController?
}

public protocol BranchingRouteSegmentPresenterType: VisualRouteSegmentPresenterType {
}

public protocol BranchedRouteSegmentPresenterType: RouteSegmentPresenterType {
}
