//
//  BranchRouteSegmentPresenterSpec.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter


class BranchRouteSegmentPresenterSpec: QuickSpec {

//    override func spec() {
//
//        let mockViewControllerA = MockViewController("A")
//        let mockViewControllerB = MockViewController("B")
//        var mockCompletionBlock: MockCompletionBlock!
//
//        beforeEach {
//            mockCompletionBlock = MockCompletionBlock()
//        }
//
//        describe("class definition") {
//
//            it("should have default identifier") {
//                expect(BranchRouteSegmentPresenter.defaultPresenterIdentifier).to(equal(Identifier(name: String(BranchRouteSegmentPresenter))))
//            }
//
//        }
//
//        describe("presentViewController") {
//
//            it("should fail when presentingViewController is nil") {
//                let presenter = BranchRouteSegmentPresenter()
//                presenter.selectBranch(<#T##branchRouteSegmentIdentifier: Identifier##Identifier#>, from: <#T##TrunkRouteController#>, options: <#T##RouteSequenceOptions#>, completion: <#T##(RoutingResult -> Void)##(RoutingResult -> Void)##RoutingResult -> Void#>)
//                presenter.selectBranch(mockBranchRouteSegmentIdentifier, from: mockTabBarController, options: [: ], completion: mockCompletionBlock.completion)
//                expect(mockCompletionBlock.trackerKeyValues).to(equal(["completion": [["false","nil"]]]))
//            }
//
//            it("should fail when presentingViewController is not a UITabBarController") {
//                let presenter = BranchRouteSegmentPresenter()
//                presenter.present(viewController: mockViewControllerB, from: mockViewControllerA, options: [: ], window: nil, completion: mockCompletionBlock.completion)
//                expect(mockCompletionBlock.trackerKeyValues).to(equal(["completion": [["false","nil"]]]))
//            }
//
//            it("should succeed when presentingViewController is a UITabBarController") {
//                let presenter = BranchRouteSegmentPresenter()
//                presenter.present(viewController: mockViewControllerB, from: UITabBarController(), options: [: ], window: nil, completion: mockCompletionBlock.completion)
//                expect(mockCompletionBlock.trackerKeyValues).to(equal(["completion": [["true", String(mockViewControllerB)]]]))
//            }
//
//        }
//
//        describe("adding multiple tabs") {
//
//            it("should leave last tab added as selected one by default") {
//                let presenter = BranchRouteSegmentPresenter()
//                let tabBarController = UITabBarController()
//                presenter.present(viewController: mockViewControllerA, from: tabBarController, options: [: ], window: nil, completion: mockCompletionBlock.completion)
//                expect(tabBarController.selectedViewController).to(equal(mockViewControllerA))
//                presenter.present(viewController: mockViewControllerB, from: tabBarController, options: [: ], window: nil, completion: mockCompletionBlock.completion)
//                expect(tabBarController.selectedViewController).to(equal(mockViewControllerB))
//            }
//
//            it("should not select a tab when appendOnly option is false") {
//                let presenter = BranchRouteSegmentPresenter()
//                let tabBarController = UITabBarController()
//
//                let options: RouteSequenceOptions = [BranchRouteSegmentPresenterOptions.AppendOnlyKey: true]
//
//                expect(tabBarController.selectedViewController).to(beNil())
//
//                presenter.present(viewController: mockViewControllerA, from: tabBarController, options: options, window: nil, completion: mockCompletionBlock.completion)
//                // the first tab added will automatically become the selected one, regardless of the options
//                expect(tabBarController.selectedViewController).to(equal(mockViewControllerA))
//
//                presenter.present(viewController: mockViewControllerB, from: tabBarController, options: options, window: nil, completion: mockCompletionBlock.completion)
//                expect(tabBarController.selectedViewController).to(equal(mockViewControllerA))
//            }
//
//        }
//
//    }
    
}
