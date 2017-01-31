//
//  RootRouteSegmentPresenterSpec.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class RootRouteSegmentPresenterSpec: QuickSpec {

    override func spec() {

        let mockViewControllerA = MockViewController("A")
        let mockViewControllerB = MockViewController("B")
        var mockWindow: MockWindow!
        var mockCompletionBlock: MockCompletionBlock!

        beforeEach {
            mockWindow = MockWindow()
            mockCompletionBlock = MockCompletionBlock()
        }

        describe("class definition") {

            it("should have default identifier") {
                expect(RootRouteSegmentPresenter.defaultPresenterIdentifier).to(equal(Identifier(name: String(describing: RootRouteSegmentPresenter.self))))
            }

        }

        describe("presentViewController") {

            it("should fail when window is nil") {
                let presenter = RootRouteSegmentPresenter()
                presenter.present(viewController: mockViewControllerB, from: nil, options: [: ], window: nil, completion: mockCompletionBlock.completion)
                expect(mockCompletionBlock.trackerKeyValuesDifferences(["completion": [["false","nil"]]])).to(beEmpty())
            }

            it("should fail when presentingViewController is not nil") {
                let presenter = RootRouteSegmentPresenter()
                presenter.present(viewController: mockViewControllerB, from: mockViewControllerA, options: [: ], window: mockWindow, completion: mockCompletionBlock.completion)
                expect(mockCompletionBlock.trackerKeyValuesDifferences(["completion": [["false","nil"]]])).to(beEmpty())
                expect(mockWindow.trackerKeyValues).to(beEmpty())
            }

            it("should pass when window is not nil") {
                let presenter = RootRouteSegmentPresenter()
                presenter.present(viewController: mockViewControllerB, from: nil, options: [: ], window: mockWindow, completion: mockCompletionBlock.completion)
                expect(mockCompletionBlock.trackerKeyValuesDifferences(["completion": [["true",String(describing: mockViewControllerB)]]])).to(beEmpty())
                expect(mockWindow.trackerKeyValuesDifferences(["makeKeyAndVisible": [[]],"setRootViewController": [[mockViewControllerB.description]]])).to(beEmpty())
            }

        }
        
    }
    
}
