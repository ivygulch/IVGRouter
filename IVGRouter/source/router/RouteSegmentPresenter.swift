//
//  RouteSegmentPresenter.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/4/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public protocol RouteSegmentPresenterType {
    var presenterIdentifier: Identifier { get }
    func presentViewController(presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: ((Bool) -> Void)) -> UIViewController?
}


