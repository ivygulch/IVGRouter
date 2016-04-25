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

    func branchForIdentifier(segmentIdentifier: Identifier) -> BranchedRouteSegmentType? {
        for branch in branches {
            if branch.segmentIdentifier == segmentIdentifier {
                return branch
            }
        }
        return nil
    }

    func addBranch(branchedRouteSegment: BranchedRouteSegmentType) {
        branches.append(branchedRouteSegment)
    }

}
