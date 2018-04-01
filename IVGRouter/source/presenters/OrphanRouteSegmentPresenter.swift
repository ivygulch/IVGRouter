//
//  OrphanRouteSegmentPresenter.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/2/18.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

open class OrphanRouteSegmentPresenter: BaseRouteSegmentPresenter, VisualRouteSegmentPresenterType {

    open static let defaultPresenterIdentifier = Identifier(name: String(describing: OrphanRouteSegmentPresenter.self))

    open func present(viewController presentedViewController: UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: @escaping ((RoutingResult) -> Void)) {
        guard verify(checkNil(presentingViewController, "presentingViewController"), completion: completion) else {
            return
        }
        completion(.success(presentedViewController))
    }
    
}
