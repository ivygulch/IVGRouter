//
//  Router.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 3/22/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public protocol RouterContextType {
    var routeSegments: [Identifier: RouteSegmentType] { get }
    var presenters: [Identifier: RouteSegmentPresenterType] { get }

    func register(routeSegmentPresenter: RouteSegmentPresenterType)
    func register(routeSegment: RouteSegmentType)
}

open class RouterContext: RouterContextType {

    public init(autoRegisterDefaultPresenters: Bool = true) {
        if autoRegisterDefaultPresenters {
            registerDefaultPresenters()
        }
    }

    public fileprivate(set) var routeSegments: [Identifier: RouteSegmentType] = [: ]
    public fileprivate(set) var presenters: [Identifier: RouteSegmentPresenterType] = [: ]

    public func register(routeSegmentPresenter: RouteSegmentPresenterType) {
        presenters[routeSegmentPresenter.presenterIdentifier] = routeSegmentPresenter
    }

    public func register(routeSegment: RouteSegmentType) {
        routeSegments[routeSegment.segmentIdentifier] = routeSegment
    }

    public func registerDefaultPresenters() {
        register(routeSegmentPresenter: RootRouteSegmentPresenter())
        register(routeSegmentPresenter: PushRouteSegmentPresenter())
        register(routeSegmentPresenter: PresentRouteSegmentPresenter())
        register(routeSegmentPresenter: PresentRouteSegmentPresenter(presenterIdentifier: PresentRouteSegmentPresenter.autoDismissPresenterIdentifier)) // auto-dismiss version for use by AlertControllers
        register(routeSegmentPresenter: PresentRouteSegmentPresenter(presenterIdentifier: PresentRouteSegmentPresenter.fromRootPresenterIdentifier)) // fromRoot version for use by modal VCs
        register(routeSegmentPresenter: SetRouteSegmentPresenter())
        register(routeSegmentPresenter: OrphanRouteSegmentPresenter())
        register(routeSegmentPresenter: WrappingRouteSegmentPresenter(wrappingRouteSegmentAnimator: SlidingWrappingRouteSegmentAnimator()))
    }

}

