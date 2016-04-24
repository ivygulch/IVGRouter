//
//  MockBranchedRouteSegment.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class MockBranchedRouteSegment : TrackableTestClass, BranchedRouteSegmentType {

    init(segmentIdentifier: Identifier, presenterIdentifier: Identifier) {
        self.segmentIdentifier = segmentIdentifier
        self.presenterIdentifier = presenterIdentifier
        print("DBG: set")
    }

    let segmentIdentifier: Identifier
    let presenterIdentifier: Identifier

}
