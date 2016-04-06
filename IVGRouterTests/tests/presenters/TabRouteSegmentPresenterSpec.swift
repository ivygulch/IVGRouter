//
//  TabRouteSegmentPresenterSpec.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class TabRouteSegmentPresenterSpec: QuickSpec {

    override func spec() {

        let mockViewControllerA = MockViewController("A")
        let mockViewControllerB = MockViewController("B")
        var mockCompletionBlock: MockCompletionBlock!

        beforeEach {
            mockCompletionBlock = MockCompletionBlock()
        }

        describe("class definition") {

            it("should have default identifier") {
                expect(TabRouteSegmentPresenter.defaultPresenterIdentifier).to(equal(Identifier(name: String(TabRouteSegmentPresenter))))
            }

        }

        describe("presentViewController") {

            it("should fail when presentingViewController is nil") {
                let presenter = TabRouteSegmentPresenter()
                let result = presenter.presentViewController(mockViewControllerB, from: nil, options:[:], window: nil, completion: mockCompletionBlock.completion)
                expect(result).to(beNil())
                expect(mockCompletionBlock.trackerKeyValues).to(equal(["completion":[["false"]]]))
            }

            it("should fail when presentingViewController is not a UITabBarController") {
                let presenter = TabRouteSegmentPresenter()
                let result = presenter.presentViewController(mockViewControllerB, from: mockViewControllerA, options:[:], window: nil, completion: mockCompletionBlock.completion)
                expect(result).to(beNil())
                expect(mockCompletionBlock.trackerKeyValues).to(equal(["completion":[["false"]]]))
            }

            it("should succeed when presentingViewController is a UITabBarController") {
                let presenter = TabRouteSegmentPresenter()
                let result = presenter.presentViewController(mockViewControllerB, from: UITabBarController(), options:[:], window: nil, completion: mockCompletionBlock.completion)
                expect(result).to(equal(mockViewControllerB))
                expect(mockCompletionBlock.trackerKeyValues).to(equal(["completion":[["true"]]]))
            }

        }

        describe("adding multiple tabs") {

            it("should leave last tab added as selected one by default") {
                let presenter = TabRouteSegmentPresenter()
                let tabBarController = UITabBarController()
                presenter.presentViewController(mockViewControllerA, from: tabBarController, options:[:], window: nil, completion: mockCompletionBlock.completion)
                expect(tabBarController.selectedViewController).to(equal(mockViewControllerA))
                presenter.presentViewController(mockViewControllerB, from: tabBarController, options:[:], window: nil, completion: mockCompletionBlock.completion)
                expect(tabBarController.selectedViewController).to(equal(mockViewControllerB))
            }

            it("should not select a tab when appendOnly option is false") {
                let presenter = TabRouteSegmentPresenter()
                let tabBarController = UITabBarController()

                let options:RouteSequenceOptions = [TabRouteSegmentPresenterOptions.AppendOnlyKey:true]

                expect(tabBarController.selectedViewController).to(beNil())

                presenter.presentViewController(mockViewControllerA, from: tabBarController, options:options, window: nil, completion: mockCompletionBlock.completion)
                // the first tab added will automatically become the selected one, regardless of the options
                expect(tabBarController.selectedViewController).to(equal(mockViewControllerA))

                presenter.presentViewController(mockViewControllerB, from: tabBarController, options:options, window: nil, completion: mockCompletionBlock.completion)
                expect(tabBarController.selectedViewController).to(equal(mockViewControllerA))
            }

        }
        
    }
    
}