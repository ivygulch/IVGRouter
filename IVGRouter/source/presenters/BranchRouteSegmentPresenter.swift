//
//  BranchRouteSegmentPresenter.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public struct BranchRouteSegmentPresenterOptions {
    public static let AppendOnlyKey = "appendOnly"
    public static let AppendOnlyDefault = false

    static func appendOnlyFromOptions(_ options: RouteSequenceOptions) -> Bool {
        return options[BranchRouteSegmentPresenterOptions.AppendOnlyKey] as? Bool ?? BranchRouteSegmentPresenterOptions.AppendOnlyDefault
    }
}

public class BranchRouteSegmentPresenter : BaseRouteSegmentPresenter, BranchRouteSegmentPresenterType {

    public static let defaultPresenterIdentifier = Identifier(name: String(describing: BranchRouteSegmentPresenter.self))

    public func selectBranch(_ branchRouteSegmentIdentifier: Identifier, from trunkRouteController: TrunkRouteController, options: RouteSequenceOptions, completion: @escaping ((RoutingResult) -> Void)) {
        if BranchRouteSegmentPresenterOptions.appendOnlyFromOptions(options) {
            trunkRouteController.configureBranch(branchRouteSegmentIdentifier, completion: completion)
        } else {
            trunkRouteController.selectBranch(branchRouteSegmentIdentifier, completion: completion)
        }
    }

}
