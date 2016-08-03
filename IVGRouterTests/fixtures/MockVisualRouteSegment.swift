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
        self.name = segmentIdentifier.name
        self.presentedViewController = presentedViewController
    }

    let segmentIdentifier: Identifier
    let presenterIdentifier: Identifier
    let name: String
    let presentedViewController: UIViewController?

    func viewController() -> UIViewController? {
        return presentedViewController
    }
}
