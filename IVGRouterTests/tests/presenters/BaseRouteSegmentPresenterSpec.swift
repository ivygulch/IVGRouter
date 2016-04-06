//
//  BaseRouteSegmentPresenterSpec.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
@testable import IVGRouter

// need a class that implements RouteSegmentPresenterType to make it testable
public class TestBaseRouteSegmentPresenter : BaseRouteSegmentPresenter, RouteSegmentPresenterType {
    public static let defaultPresenterIdentifier = Identifier(name: String(TestBaseRouteSegmentPresenter))

    public func presentViewController(presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: ((Bool) -> Void)) -> UIViewController? {
        return nil
    }
}

class BaseRouteSegmentPresenterSpec: QuickSpec {

    override func spec() {

        describe("presentIdentifier") {

            it("should get a default value") {
                let presenter = TestBaseRouteSegmentPresenter()
                let defaultIdentifier = Identifier(name: String(presenter.dynamicType))
                expect(presenter.presenterIdentifier).to(equal(defaultIdentifier))
            }

            it("should allow a custom identifier") {
                let customIdentifier = Identifier(name: "Custom")
                let presenter = TestBaseRouteSegmentPresenter(presenterIdentifier: customIdentifier)
                expect(presenter.presenterIdentifier).to(equal(customIdentifier))
            }

        }

        describe("conditions") {

            var presenter: TestBaseRouteSegmentPresenter!

            beforeEach {
                presenter = TestBaseRouteSegmentPresenter()
            }

            describe("when item is nil") {

                it("checkNil should not return an error message") {
                    expect(presenter.checkNil(nil, "source")).to(beNil())
                }

                it("checkNotNil should return an error message") {
                    expect(presenter.checkNotNil(nil, "source")).toNot(beNil())
                }

                it("checkType should return an error message") {
                    expect(presenter.checkType(nil, type:Any.self, "source")).toNot(beNil())
                }

            }

            describe("when item is not nil") {

                it("checkNil should return an error message") {
                    expect(presenter.checkNil("test", "source")).toNot(beNil())
                }

                it("checkNotNil should not return an error message") {
                    expect(presenter.checkNotNil("test", "source")).to(beNil())
                }

                it("checkType should not return an error message") {
                    expect(presenter.checkType("test", type:Any.self, "source")).to(beNil())
                }

            }
            
            describe("when item is wrong class") {

                it("checkType should return an error message") {
                    expect(presenter.checkType("test", type:Int.self, "source")).toNot(beNil())
                }

            }

            describe("when condition fails") {

                var mockCompletionBlock: MockCompletionBlock!

                beforeEach {
                    mockCompletionBlock = MockCompletionBlock()
                }

                describe("calling verify with nil error message") {

                    var verifyResult:Bool!

                    beforeEach {
                        verifyResult = presenter.verify(nil, completion:mockCompletionBlock.completion)
                    }

                    it("should return true") {
                        expect(verifyResult).to(beTrue())
                    }

                    it("should not call completion block") {
                        expect(mockCompletionBlock.trackerKeyValues).to(beEmpty())
                    }
                }

                describe("calling verify with non-nil error message") {

                    var verifyResult:Bool!

                    beforeEach {
                        verifyResult = presenter.verify("test", completion:mockCompletionBlock.completion)
                    }

                    it("should return false") {
                        expect(verifyResult).to(beFalse())
                    }

                    it("should call completion block") {
                        expect(mockCompletionBlock.trackerKeyValues).to(equal(["completion":[["false"]]]))
                    }
                }
            }
            
        }
        
    }
    
}