//
//  MockTrunkRouteSegment.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class MockTrunkRouteSegment : MockVisualRouteSegment, TrunkRouteSegmentType {

    let trunkRouteController: TrunkRouteController
    var branches:[BranchRouteSegmentType] = []

    init(segmentIdentifier: Identifier, presenterIdentifier: Identifier, trunkRouteController: TrunkRouteController, presentedViewController: UIViewController?) {
        self.trunkRouteController = trunkRouteController
        super.init(segmentIdentifier: segmentIdentifier, presenterIdentifier: presenterIdentifier, presentedViewController: presentedViewController)
    }

    func branchForIdentifier(segmentIdentifier: Identifier) -> BranchRouteSegmentType? {
        for branch in branches {
            if branch.segmentIdentifier == segmentIdentifier {
                return branch
            }
        }
        return nil
    }

    func addBranch(branchRouteSegment: BranchRouteSegmentType) {
        branches.append(branchRouteSegment)
    }

}
