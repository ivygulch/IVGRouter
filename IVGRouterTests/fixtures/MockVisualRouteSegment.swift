//
//  MockVisualRouteSegment.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/1/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class MockVisualRouteSegment : TrackableTestClass, VisualRouteSegmentType {

    init(segmentIdentifier: Identifier, presenterIdentifier: Identifier, presentedViewController: UIViewController?) {
        self.segmentIdentifier = segmentIdentifier
        self.presenterIdentifier = presenterIdentifier
        self.title = segmentIdentifier.name
        self.presentedViewController = presentedViewController
    }

    let segmentIdentifier: Identifier
    let presenterIdentifier: Identifier
    let title: String
    let shouldBeRecorded = true
    let presentedViewController: UIViewController?

    func viewController() -> UIViewController? {
        return presentedViewController
    }

    func set(data: RouteSegmentDataType?, on presented: UIViewController, from presenting: UIViewController?) {
    }
}
