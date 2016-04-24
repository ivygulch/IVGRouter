//
//  MockBranchingRouteSegment.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class MockBranchingRouteSegment : MockVisualRouteSegment, BranchingRouteSegmentType {

    var branches:[BranchedRouteSegmentType] = []

    func addBranch(branchedRouteSegment: BranchedRouteSegmentType) {
        branches.append(branchedRouteSegment)
    }

}
