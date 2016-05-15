//
//  MockBranchRouteSegmentPresenter.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class MockBranchRouteSegmentPresenter : TrackableTestClass, BranchRouteSegmentPresenterType {

    static let defaultPresenterIdentifier = Identifier(name: String(MockBranchRouteSegmentPresenter))

    init(presenterIdentifier: String, completionBlockArg: Bool) {
        self.presenterIdentifier = Identifier(name: presenterIdentifier)
        self.completionBlockArg = completionBlockArg
    }

    let presenterIdentifier: Identifier

    func selectBranch(branchRouteSegment : BranchRouteSegmentType, from trunkRouteController: TrunkRouteController, options: RouteSequenceOptions, completion: (RoutingResult -> Void)) {
        let from = (trunkRouteController as? CustomStringConvertible)?.description ?? "trunkRouteController"
        track("selectBranchViewController", [branchRouteSegment.segmentIdentifier.name,from])
        let result = trunkRouteController.selectBranch(branchRouteSegment.segmentIdentifier)
        if completionBlockArg {
            completion(.Success(result!))
        } else {
            completion(.Failure(RoutingErrors.CannotPresent(self.presenterIdentifier, "mock result is false")))
        }
    }

    private let completionBlockArg: Bool
}
