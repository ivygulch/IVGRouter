//
//  RouterSpec.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/1/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class RouterSpec: QuickSpec {
    override func spec() {
        describe("Router") {
            self.initializationTests()
            self.presenterRegistrationTests()
            self.routeSegmentRegistrationTests()
            self.singleSegmentRouteExecutionTests()
            self.simpleMultipleSegmentRouteExecutionTests()
            self.popRouteTests()
            self.executeSubsetOfCurrentRouteTests()
            self.checkHistoryUsage()
        }
    }
}


// MARK: intialization tests
extension RouterSpec {

    func initializationTests() {

        context("when initialized") {

            it("should allow for a nil window") {
                let router = Router(window: nil, routerContext: RouterContext())
                expect(router.window).to(beNil())
            }

            it("should have an empty set of routeSegments") {
                let router = Router(window: nil, routerContext: RouterContext())
                expect(router.routerContext.routeSegments).to(beEmpty())
            }

            it("should have an empty set of presenters") {
                let router = Router(window: nil, routerContext: RouterContext(autoRegisterDefaultPresenters: false))
                expect(router.routerContext.presenters).to(beEmpty())
            }

            it("should have an empty set of viewControllers") {
                let router = Router(window: nil, routerContext: RouterContext())
                let viewControllers = router.viewControllers()
                expect(viewControllers).to(beEmpty())
            }

            it("should allow for a non-nil window") {
                let mockWindow = UIWindow()
                let router = Router(window: mockWindow, routerContext: RouterContext())
                expect(router.window).to(equal(mockWindow))
            }

        }

    }
}

// MARK: presenter registration tests
extension RouterSpec {

    func presenterRegistrationTests() {

        context("when registering default presenters") {

            var router: Router!

            beforeEach {
                router = Router(window: nil, routerContext: RouterContext(autoRegisterDefaultPresenters: true))
            }

            it("should include RootRouteSegmentPresenter") {
                expect(router.routerContext.presenters[Identifier(name: String(describing: RootRouteSegmentPresenter.self))]).toNot(beNil())
            }

            it("should include PushRouteSegmentPresenter") {
                expect(router.routerContext.presenters[Identifier(name: String(describing: PushRouteSegmentPresenter.self))]).toNot(beNil())
            }

        }
    }
}

// MARK: route segment registration tests
extension RouterSpec {

    func routeSegmentRegistrationTests() {

        context("when registering route segments") {

            var mockVisualRouteSegmentA: MockVisualRouteSegment!
            var mockVisualRouteSegmentB: MockVisualRouteSegment!
            var mockPresenterA: MockVisualRouteSegmentPresenter!
            var mockPresenterB: MockVisualRouteSegmentPresenter!
            var router: Router!

            beforeEach {
                mockPresenterA = MockVisualRouteSegmentPresenter(presenterIdentifier: "A", completionBlockArg: true)
                mockPresenterB = MockVisualRouteSegmentPresenter(presenterIdentifier: "B", completionBlockArg: true)
                mockVisualRouteSegmentA = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "A"), presenterIdentifier: mockPresenterA.presenterIdentifier, presentedViewController: MockViewController("A"))
                mockVisualRouteSegmentB = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "B"), presenterIdentifier: mockPresenterB.presenterIdentifier, presentedViewController: MockViewController("B"))
                router = Router(window: nil, routerContext: RouterContext())
            }

            it("should be able to register and recall single routes") {
                router.routerContext.register(routeSegment: mockVisualRouteSegmentA)
                let actualRouteSegmentA = router.routerContext.routeSegments[mockVisualRouteSegmentA.segmentIdentifier] as? MockVisualRouteSegment
                expect(actualRouteSegmentA).to(beIdenticalTo(mockVisualRouteSegmentA))
            }

            it("should be able to register and recall multiple routes") {
                router.routerContext.register(routeSegment: mockVisualRouteSegmentA)
                router.routerContext.register(routeSegment: mockVisualRouteSegmentB)
                let actualRouteSegmentA = router.routerContext.routeSegments[mockVisualRouteSegmentA.segmentIdentifier] as? MockVisualRouteSegment
                expect(actualRouteSegmentA).to(beIdenticalTo(mockVisualRouteSegmentA))
                let actualRouteSegmentB = router.routerContext.routeSegments[mockVisualRouteSegmentB.segmentIdentifier] as? MockVisualRouteSegment
                expect(actualRouteSegmentB).to(beIdenticalTo(mockVisualRouteSegmentB))
            }

            it("should be able to register and recall single presenter") {
                router.routerContext.register(routeSegmentPresenter: mockPresenterA)
                let actualPresenterA = router.routerContext.presenters[mockPresenterA.presenterIdentifier] as? MockVisualRouteSegmentPresenter
                expect(actualPresenterA).to(beIdenticalTo(mockPresenterA))
            }

            it("should be able to register and recall multiple presenters") {
                router.routerContext.register(routeSegmentPresenter: mockPresenterA)
                router.routerContext.register(routeSegmentPresenter: mockPresenterB)
                let actualPresenterA = router.routerContext.presenters[mockPresenterA.presenterIdentifier] as? MockVisualRouteSegmentPresenter
                expect(actualPresenterA).to(beIdenticalTo(mockPresenterA))
                let actualPresenterB = router.routerContext.presenters[mockPresenterB.presenterIdentifier] as? MockVisualRouteSegmentPresenter
                expect(actualPresenterB).to(beIdenticalTo(mockPresenterB))
            }
        }

    }
}

// MARK: single segment route execution tests
extension RouterSpec {

    func singleSegmentRouteExecutionTests() {

        context("when executing single segment route") {

            let identifierNoViewController = Identifier(name: "NoViewController")
            let identifierCompletionFails = Identifier(name: "CompletionFails")
            let identifierValid = Identifier(name: "Valid")
            let mockViewControllerA = MockViewController("A")
            let mockViewControllerB = MockViewController("B")
            var mockPresenterCompletionSucceeds: MockVisualRouteSegmentPresenter!
            var mockPresenterCompletionFails: MockVisualRouteSegmentPresenter!
            var mockVisualRouteSegmentValid: MockVisualRouteSegment!
            var mockVisualRouteSegmentNoViewController: MockVisualRouteSegment!
            var mockVisualRouteSegmentCompletionFails: MockVisualRouteSegment!
            var router: Router!

            beforeEach {
                mockPresenterCompletionSucceeds = MockVisualRouteSegmentPresenter(presenterIdentifier: "Success", completionBlockArg: true)
                mockPresenterCompletionFails = MockVisualRouteSegmentPresenter(presenterIdentifier: "Failure", completionBlockArg: false)
                mockVisualRouteSegmentValid = MockVisualRouteSegment(segmentIdentifier: identifierValid, presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: mockViewControllerA)
                mockVisualRouteSegmentNoViewController = MockVisualRouteSegment(segmentIdentifier: identifierNoViewController, presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: nil)
                mockVisualRouteSegmentCompletionFails = MockVisualRouteSegment(segmentIdentifier: identifierCompletionFails, presenterIdentifier: mockPresenterCompletionFails.presenterIdentifier, presentedViewController: mockViewControllerB)
                router = Router(window: nil, routerContext: RouterContext())
                router.routerContext.register(routeSegmentPresenter: mockPresenterCompletionSucceeds)
                router.routerContext.register(routeSegmentPresenter: mockPresenterCompletionFails)
                router.routerContext.register(routeSegment: mockVisualRouteSegmentNoViewController)
                router.routerContext.register(routeSegment: mockVisualRouteSegmentCompletionFails)
                router.routerContext.register(routeSegment: mockVisualRouteSegmentValid)
                router.routerContext.register(routeSegment: mockVisualRouteSegmentNoViewController)
                router.routerContext.register(routeSegment: mockVisualRouteSegmentCompletionFails)
            }

            context("with segment that produces a view controller and completion block arg is true") {

                it("should succeed") {
                    let routeSequence: [Any] = [mockVisualRouteSegmentValid.segmentIdentifier]
                    let expectation = self.expectation(description: "executeRoute completion callback")
                    router.execute(route: routeSequence) {
                        routingResult in
                        switch routingResult {
                        case .success(let finalViewController): 
                            expect(finalViewController).to(equal(mockViewControllerA))
                        case .failure(let error): 
                            fail("Did not expect error: \(error)")
                        }
                        expectation.fulfill()
                    }
                    self.waitForExpectations(timeout: 5, handler: nil)
                }

            }

            context("with segment that does not produce a view controller") {

                it("should fail") {
                    let routeSequence: [Any] = [mockVisualRouteSegmentNoViewController.segmentIdentifier]
                    let expectation = self.expectation(description: "executeRoute completion callback")
                    router.execute(route: routeSequence) {
                        routingResult in
                        switch routingResult {
                        case .success(let finalViewController): 
                            fail("Did not expect success: \(finalViewController)")
                        case .failure(let error): 
                            expect(error as? RoutingErrors).toNot(beNil())
                            if let error = error as? RoutingErrors {
                                switch error {
                                case .noViewControllerProduced(let identifier): 
                                    expect(identifier).to(equal(identifierNoViewController))
                                default: 
                                    fail("Did not expect: \(error)")
                                }
                            }
                        }
                        expectation.fulfill()
                    }
                    self.waitForExpectations(timeout: 5, handler: nil)
                }

            }

            context("with segment completion block that returns false") {

                it("should fail") {
                    let routeSequence: [Any] = [mockVisualRouteSegmentCompletionFails.segmentIdentifier]
                    let expectation = self.expectation(description: "executeRoute completion callback")
                    router.execute(route: routeSequence) {
                        routingResult in
                        switch routingResult {
                        case .success(let finalViewController): 
                            fail("Did not expect success: \(finalViewController)")
                        case .failure(let error): 
                            expect(error as? RoutingErrors).toNot(beNil())
                            if let error = error as? RoutingErrors {
                                switch error {
                                case .cannotPresent(let identifier, _): 
                                    expect(identifier).to(equal(mockPresenterCompletionFails.presenterIdentifier))
                                default: 
                                    fail("Did not expect: \(error)")
                                }
                            }
                        }
                        expectation.fulfill()
                    }
                    self.waitForExpectations(timeout: 5, handler: nil)
                }

            }
        }

    }
}

// MARK: simple, multiple segment route execution tests
extension RouterSpec {

    func simpleMultipleSegmentRouteExecutionTests() {

        context("when executing simple, multiple segment route") {

            let identifierInvalid = Identifier(name: "Invalid")
            let mockViewControllerA = MockViewController("A")
            let mockViewControllerB = MockViewController("B")
            let mockViewControllerC = MockViewController("C")
            var mockPresenterCompletionSucceeds: MockVisualRouteSegmentPresenter!
            var mockPresenterCompletionFails: MockVisualRouteSegmentPresenter!
            var mockVisualRouteSegmentA: MockVisualRouteSegment!
            var mockVisualRouteSegmentB: MockVisualRouteSegment!
            var mockVisualRouteSegmentC: MockVisualRouteSegment!
            var mockVisualRouteSegmentInvalid: MockVisualRouteSegment!
            var router: Router!
            var validSequence: [Any]!
            var invalidSequence: [Any]!

            beforeEach {
                mockPresenterCompletionSucceeds = MockVisualRouteSegmentPresenter(presenterIdentifier: "Success", completionBlockArg: true)
                mockPresenterCompletionFails = MockVisualRouteSegmentPresenter(presenterIdentifier: "Failure", completionBlockArg: false)
                mockVisualRouteSegmentA = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "A"), presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: mockViewControllerA)
                mockVisualRouteSegmentB = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "B"), presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: mockViewControllerB)
                mockVisualRouteSegmentC = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "C"), presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: mockViewControllerC)
                mockVisualRouteSegmentInvalid = MockVisualRouteSegment(segmentIdentifier: identifierInvalid, presenterIdentifier: mockPresenterCompletionFails.presenterIdentifier, presentedViewController: nil)
                router = Router(window: nil, routerContext: RouterContext())
                router.routerContext.register(routeSegmentPresenter: mockPresenterCompletionSucceeds)
                router.routerContext.register(routeSegmentPresenter: mockPresenterCompletionFails)
                router.routerContext.register(routeSegment: mockVisualRouteSegmentA)
                router.routerContext.register(routeSegment: mockVisualRouteSegmentB)
                router.routerContext.register(routeSegment: mockVisualRouteSegmentC)
                validSequence = [mockVisualRouteSegmentA.segmentIdentifier,mockVisualRouteSegmentB.segmentIdentifier,mockVisualRouteSegmentC.segmentIdentifier]
                invalidSequence = [mockVisualRouteSegmentA.segmentIdentifier,mockVisualRouteSegmentInvalid.segmentIdentifier,mockVisualRouteSegmentC.segmentIdentifier]
            }

            context("with a valid sequence") {

                it("should succeed") {
                    let expectation = self.expectation(description: "executeRoute completion callback")
                    router.execute(route: validSequence) {
                        routingResult in
                        switch routingResult {
                        case .success(let finalViewController): 
                            expect(finalViewController).to(equal(mockViewControllerC))
                        case .failure(let error): 
                            fail("Did not expect error: \(error)")
                        }
                        expectation.fulfill()
                    }
                    self.waitForExpectations(timeout: 5, handler: nil)
                }

                it("should produce full sequence") {
                    let expectation = self.expectation(description: "executeRoute completion callback")
                    router.execute(route: validSequence) { _ in
                        expectation.fulfill()
                    }
                    self.waitForExpectations(timeout: 5, handler: nil)
                    let viewControllers = router.viewControllers()
                    expect(viewControllers).to(equal([mockViewControllerA,mockViewControllerB,mockViewControllerC]))
                }

            }

            context("with an invalid sequence") {

                it("should fail") {
                    let expectation = self.expectation(description: "executeRoute completion callback")
                    router.execute(route: invalidSequence) {
                        routingResult in
                        switch routingResult {
                        case .success(let finalViewController): 
                            fail("Did not expect success: \(finalViewController)")
                        case .failure(let error): 
                            expect(error as? RoutingErrors).toNot(beNil())
                            if let error = error as? RoutingErrors {
                                switch error {
                                case .segmentNotRegistered(let identifier): 
                                    expect(identifier).to(equal(identifierInvalid))
                                default: 
                                    fail("Did not expect: \(error)")
                                }
                            }
                        }
                        expectation.fulfill()
                    }
                    self.waitForExpectations(timeout: 5, handler: nil)
                }

                it("should produce partial sequence") {
                    let expectation = self.expectation(description: "executeRoute completion callback")
                    router.execute(route: invalidSequence) { _ in
                        expectation.fulfill()
                    }
                    self.waitForExpectations(timeout: 5, handler: nil)
                    let viewControllers = router.viewControllers()
                    expect(viewControllers).to(equal([mockViewControllerA]))
                }

            }

        }

    }

}

// MARK: simple popRoute tests
extension RouterSpec {

    func popRouteTests() {

        context("when executing a sequence") {

            let mockViewControllerA = MockViewController("A")
            let mockViewControllerB = MockViewController("B")
            let mockViewControllerC = MockViewController("C")
            var mockPresenterCompletionSucceeds: MockVisualRouteSegmentPresenter!
            var mockVisualRouteSegmentA: MockVisualRouteSegment!
            var mockVisualRouteSegmentB: MockVisualRouteSegment!
            var mockVisualRouteSegmentC: MockVisualRouteSegment!
            var router: Router!
            var initialSequence: [Any]!

            beforeEach {
                mockPresenterCompletionSucceeds = MockVisualRouteSegmentPresenter(presenterIdentifier: "Success", completionBlockArg: true)
                mockVisualRouteSegmentA = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "A"), presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: mockViewControllerA)
                mockVisualRouteSegmentB = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "B"), presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: mockViewControllerB)
                mockVisualRouteSegmentC = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "C"), presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: mockViewControllerC)
                router = Router(window: nil, routerContext: RouterContext())
                router.routerContext.register(routeSegmentPresenter: mockPresenterCompletionSucceeds)
                router.routerContext.register(routeSegment: mockVisualRouteSegmentA)
                router.routerContext.register(routeSegment: mockVisualRouteSegmentB)
                router.routerContext.register(routeSegment: mockVisualRouteSegmentC)
                initialSequence = [mockVisualRouteSegmentA.segmentIdentifier,mockVisualRouteSegmentB.segmentIdentifier,mockVisualRouteSegmentC.segmentIdentifier]

                let expectation = self.expectation(description: "executeRoute baseRoute")
                router.execute(route: initialSequence) {
                    routingResult in
                    switch routingResult {
                    case .success(let finalViewController): 
                        expect(finalViewController).to(equal(mockViewControllerC))
                    case .failure(let error): 
                        fail("Did not expect error: \(error)")
                    }
                    expectation.fulfill()
                }
//                print("DBG: initialSequence=\(initialSequence)")
                self.waitForExpectations(timeout: 5, handler: nil)
            }

            context("then calling popRoute once") {

                it("should move back to previous segment") {
                    let expectation = self.expectation(description: "executeRoute completion callback")
                    router.pop() {
                        routingResult in
                        switch routingResult {
                        case .success(let finalViewController): 
                            expect(finalViewController).to(equal(mockViewControllerB))
                        case .failure(let error): 
                            fail("Did not expect error: \(error)")
                        }
                        expectation.fulfill()
                    }
                    self.waitForExpectations(timeout: 5, handler: nil)
                }

            }

            context("then calling popRoute twice") {

                it("should move back to first segment") {
                    let expectation = self.expectation(description: "second popRoute completion")
                    router.pop() { _ in

                        router.pop() {
                            routingResult in
                            switch routingResult {
                            case .success(let finalViewController): 
                                expect(finalViewController).to(equal(mockViewControllerA))
                            case .failure(let error): 
                                fail("Did not expect error: \(error)")
                            }
                            expectation.fulfill()
                        }

                    }
                    self.waitForExpectations(timeout: 5, handler: nil)
                }

            }

        }

    }

}

// MARK: execute subset of current route
extension RouterSpec {

    func executeSubsetOfCurrentRouteTests() {

        context("when executing a sequence") {

            let mockViewControllerA = MockViewController("A")
            let mockViewControllerB = MockViewController("B")
            let mockViewControllerC = MockViewController("C")
            let mockViewControllerD = MockViewController("D")
            let mockViewControllerE = MockViewController("E")
            var mockPresenterCompletionSucceeds: MockVisualRouteSegmentPresenter!
            var mockVisualRouteSegmentA: MockVisualRouteSegment!
            var mockVisualRouteSegmentB: MockVisualRouteSegment!
            var mockVisualRouteSegmentC: MockVisualRouteSegment!
            var mockVisualRouteSegmentD: MockVisualRouteSegment!
            var mockVisualRouteSegmentE: MockVisualRouteSegment!
            var router: Router!
            var initialSequence: [Any]!

            beforeEach {
                mockPresenterCompletionSucceeds = MockVisualRouteSegmentPresenter(presenterIdentifier: "Success", completionBlockArg: true)
                mockVisualRouteSegmentA = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "A"), presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: mockViewControllerA)
                mockVisualRouteSegmentB = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "B"), presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: mockViewControllerB)
                mockVisualRouteSegmentC = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "C"), presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: mockViewControllerC)
                mockVisualRouteSegmentD = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "D"), presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: mockViewControllerD)
                mockVisualRouteSegmentE = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "E"), presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: mockViewControllerE)
                router = Router(window: nil, routerContext: RouterContext())
                router.routerContext.register(routeSegmentPresenter: mockPresenterCompletionSucceeds)
                router.routerContext.register(routeSegment: mockVisualRouteSegmentA)
                router.routerContext.register(routeSegment: mockVisualRouteSegmentB)
                router.routerContext.register(routeSegment: mockVisualRouteSegmentC)
                router.routerContext.register(routeSegment: mockVisualRouteSegmentD)
                router.routerContext.register(routeSegment: mockVisualRouteSegmentE)
                initialSequence = [mockVisualRouteSegmentA.segmentIdentifier,mockVisualRouteSegmentB.segmentIdentifier,mockVisualRouteSegmentC.segmentIdentifier,mockVisualRouteSegmentD.segmentIdentifier]

                let expectation = self.expectation(description: "executeRoute baseRoute")
                router.execute(route: initialSequence) {
                    routingResult in
                    switch routingResult {
                    case .success(let finalViewController): 
                        let presentedVCNames = mockPresenterCompletionSucceeds.trackerLog.map { $0.values[0] }
                        let actualVCNames = initialSequence.map { ($0 as! Identifier).name }
                        expect(presentedVCNames).to(equal(actualVCNames))
                        expect(finalViewController).to(equal(mockViewControllerD))
                    case .failure(let error): 
                        fail("Did not expect error: \(error)")
                    }
                    expectation.fulfill()
                }
                self.waitForExpectations(timeout: 5, handler: nil)
            }

            context("then executing subset of route with one less segment") {

                it("should effectively pop to previous segment") {
                    let subSequence = Array(initialSequence.prefix(initialSequence.count-1))
                    let expectation = self.expectation(description: "executeRoute completion callback")
                    router.execute(route: subSequence) {
                        routingResult in
                        switch routingResult {
                        case .success(let finalViewController): 
                            // executing a subsequence should not present any new VCs
                            let presentedVCNames = mockPresenterCompletionSucceeds.trackerLog.map { $0.values[0] }
                            let actualVCNames = initialSequence.map { ($0 as! Identifier).name }
                            expect(presentedVCNames).to(equal(actualVCNames))
                            expect(finalViewController).to(equal(mockViewControllerC))
                        case .failure(let error): 
                            fail("Did not expect error: \(error)")
                        }
                        expectation.fulfill()
                    }
                    self.waitForExpectations(timeout: 5, handler: nil)

                    let viewControllers = router.viewControllers()
                    expect(viewControllers).to(equal([mockViewControllerA,mockViewControllerB,mockViewControllerC]))
                }

            }

            context("then executing subset of route with two less segments") {

                it("should effectively pop twice to earlier segment") {
                    let subSequence = Array(initialSequence.prefix(initialSequence.count-2))
                    let expectation = self.expectation(description: "executeRoute completion callback")
                    router.execute(route: subSequence) {
                        routingResult in
                        switch routingResult {
                        case .success(let finalViewController): 
                            // executing a subsequence should not re-present any initial VCs
                            let presentedVCNames = mockPresenterCompletionSucceeds.trackerLog.map { $0.values[0] }
                            let actualVCNames = initialSequence.map { ($0 as! Identifier).name }
                            expect(presentedVCNames).to(equal(actualVCNames))
                            expect(finalViewController).to(equal(mockViewControllerB))
                        case .failure(let error): 
                            fail("Did not expect error: \(error)")
                        }
                        expectation.fulfill()
                    }
                    self.waitForExpectations(timeout: 5, handler: nil)

                    let viewControllers = router.viewControllers()
                    expect(viewControllers).to(equal([mockViewControllerA,mockViewControllerB]))
                }

            }

            context("then executing new sequence that partially matches") {

                it("should effectively pop some segments before moving to new one") {
                    var subSequence = Array(initialSequence.prefix(initialSequence.count-2))
                    subSequence.append(mockVisualRouteSegmentE.segmentIdentifier)
                    let expectation = self.expectation(description: "executeRoute completion callback")
                    router.execute(route: subSequence) {
                        routingResult in
                        switch routingResult {
                        case .success(let finalViewController): 
                            // executing new sequence should not re-present any initial VCs, just the new one
                            let presentedVCNames = mockPresenterCompletionSucceeds.trackerLog.map { $0.values[0] }
                            var actualVCNames = initialSequence.map { ($0 as! Identifier).name }
                            actualVCNames.append(mockVisualRouteSegmentE.segmentIdentifier.name)
                            expect(presentedVCNames).to(equal(actualVCNames))
                            expect(finalViewController).to(equal(mockViewControllerE))
                        case .failure(let error): 
                            fail("Did not expect error: \(error)")
                        }
                        expectation.fulfill()
                    }
                    self.waitForExpectations(timeout: 5, handler: nil)

                    let viewControllers = router.viewControllers()
                    expect(viewControllers).to(equal([mockViewControllerA,mockViewControllerB,mockViewControllerE]))
                }

            }

        }

    }

}

// MARK: manage history

extension RouterSpec {

    func checkHistoryUsage() {

        let mockViewControllerA = MockViewController("A")
        let mockViewControllerB = MockViewController("B")
        let mockViewControllerC = MockViewController("C")
        let mockViewControllerD = MockViewController("D")
        var mockPresenterCompletionSucceeds: MockVisualRouteSegmentPresenter!
        var mockVisualRouteSegmentRoot: MockVisualRouteSegment!
        var mockVisualRouteSegmentA: MockVisualRouteSegment!
        var mockVisualRouteSegmentB: MockVisualRouteSegment!
        var mockVisualRouteSegmentC: MockVisualRouteSegment!
        var mockVisualRouteSegmentD: MockVisualRouteSegment!
        var router: Router!

        beforeEach {
            mockPresenterCompletionSucceeds = MockVisualRouteSegmentPresenter(presenterIdentifier: "Success", completionBlockArg: true)
            mockVisualRouteSegmentRoot = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "A"), presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: UINavigationController())
            mockVisualRouteSegmentA = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "A"), presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: mockViewControllerA)
            mockVisualRouteSegmentB = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "B"), presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: mockViewControllerB)
            mockVisualRouteSegmentC = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "C"), presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: mockViewControllerC)
            mockVisualRouteSegmentD = MockVisualRouteSegment(segmentIdentifier: Identifier(name: "D"), presenterIdentifier: mockPresenterCompletionSucceeds.presenterIdentifier, presentedViewController: mockViewControllerD)
            router = Router(window: nil, routerContext: RouterContext())
            router.routerContext.register(routeSegmentPresenter: mockPresenterCompletionSucceeds)
            router.routerContext.register(routeSegment: mockVisualRouteSegmentRoot)
            router.routerContext.register(routeSegment: mockVisualRouteSegmentA)
            router.routerContext.register(routeSegment: mockVisualRouteSegmentB)
            router.routerContext.register(routeSegment: mockVisualRouteSegmentC)
            router.routerContext.register(routeSegment: mockVisualRouteSegmentD)
        }

        context("when executing a single sequence") {

            beforeEach {
                router.execute(route: [mockVisualRouteSegmentRoot.segmentIdentifier, mockVisualRouteSegmentA.segmentIdentifier]) { _ in }
            }

            it("should not have previous in history") {
                expect(router.previousRouteHistoryItem()).to(beNil())
            }

            it("should not move back") {
                let expectation = self.expectation(description: "goBack completion callback")
                router.goBack() {
                    routingResult in
                    switch routingResult {
                    case .success: 
                        fail("Did not expect success: \(routingResult)")
                    case .failure(let error): 
                        expect(error as? RoutingErrors).toNot(beNil())
                        if let error = error as? RoutingErrors {
                            switch error {
                            case .noHistory: 
                            break // yup
                            default: 
                                fail("Did not expect: \(error)")
                            }
                        }
                    }
                    expectation.fulfill()
                }
                self.waitForExpectations(timeout: 5, handler: nil)
            }

        }

        context("when executing two sequences") {

            beforeEach {
                router.execute(route: [mockVisualRouteSegmentRoot.segmentIdentifier, mockVisualRouteSegmentA.segmentIdentifier]) { _ in }
                router.execute(route: [mockVisualRouteSegmentRoot.segmentIdentifier, mockVisualRouteSegmentB.segmentIdentifier]) { _ in }
            }

            it("should have previous in history") {
                expect(router.previousRouteHistoryItem()).toNot(beNil())
            }

            it("should move back") {
                let expectation = self.expectation(description: "goBack completion callback")
                router.goBack() {
                    routingResult in
                    switch routingResult {
                    case .success(let viewController): 
                        expect(viewController).to(equal(mockViewControllerA))
                    case .failure(let error): 
                        fail("Did not expect failure: \(error)")
                    }
                    expectation.fulfill()
                }
                self.waitForExpectations(timeout: 5, handler: nil)
            }

        }
        
        context("when executing four sequences forward then one back") {
            
            beforeEach {
                router.execute(route: [mockVisualRouteSegmentRoot.segmentIdentifier, mockVisualRouteSegmentA.segmentIdentifier]) { _ in }
                router.execute(route: [mockVisualRouteSegmentRoot.segmentIdentifier, mockVisualRouteSegmentB.segmentIdentifier]) { _ in }
                router.execute(route: [mockVisualRouteSegmentRoot.segmentIdentifier, mockVisualRouteSegmentC.segmentIdentifier]) { _ in }
                router.execute(route: [mockVisualRouteSegmentRoot.segmentIdentifier, mockVisualRouteSegmentD.segmentIdentifier]) { _ in }
                router.goBack() { _ in }
            }
            
            it("should have previous in history") {
                expect(router.previousRouteHistoryItem()).toNot(beNil())
            }
            
            it("should move back") {
                let expectation = self.expectation(description: "goBack completion callback")
                router.goBack() {
                    routingResult in
                    switch routingResult {
                    case .success(let viewController): 
                        expect(viewController).to(equal(mockViewControllerB))
                    case .failure(let error): 
                        fail("Did not expect failure: \(error)")
                    }
                    expectation.fulfill()
                }
                self.waitForExpectations(timeout: 5, handler: nil)
            }
          
        }

    }
    
}
