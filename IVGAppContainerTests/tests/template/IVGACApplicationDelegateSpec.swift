//
//  IVGACApplicationDelegateSpec.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/20/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Quick
import Nimble
import IVGRouter
// need @testable since we are using a package init method
@testable import IVGAppContainer

class TestIVGACApplicationDelegate : IVGACApplicationDelegate<ApplicationContainer> {
    let testContainer: ApplicationContainer
    init(testContainer: ApplicationContainer) {
        self.testContainer = testContainer
    }

    override func createApplicationContainer(window: UIWindow?) -> ApplicationContainer {
        return testContainer
    }

    override func configureApplicationContainer(container: ApplicationContainer) {
    }
}

class TestAppCoordinator : TrackableTestClass, CoordinatorType {
    required init(container: ApplicationContainerType) {
    }

    func registerRouteSegments(router: RouterType) {

    }

}

class TestWindow: UIWindow {
    var rootViewControllerSetterCount = 0
    var makeKeyAndVisibleCallCount = 0

    override var rootViewController:UIViewController? {
        didSet {
            rootViewControllerSetterCount += 1
        }
    }

    override func makeKeyAndVisible() {
        makeKeyAndVisibleCallCount += 1
    }
}

class IVGACApplicationDelegateSpec: QuickSpec {

    var mockApplication:UIApplication = unsafeBitCast(0, UIApplication.self)

    override func spec() {
        describe("IVGACApplicationDelegate dependency injection") {
            var appDelegate: TestIVGACApplicationDelegate!
            var testService: BaseTestService!
            var testContainer: ApplicationContainer!

            beforeEach {
                testContainer = ApplicationContainer(window: TestWindow())
                testService = BaseTestService(container: testContainer)!
                testContainer.addService(testService, forProtocol: ServiceType.self)
                appDelegate = TestIVGACApplicationDelegate(testContainer:testContainer)
            }

            describe("should call once for each service in order:") {
                it("service.willFinishLaunching") {
                    let result = appDelegate.application(self.mockApplication, willFinishLaunchingWithOptions:nil)
                    expect(result).to(beTrue())
                    expect(testService.trackerKeys).to(equal(["willFinishLaunching()"]))
                    expect(testService.trackerCount).to(equal(1))
                }

                it("service.didFinishLaunching") {
                    appDelegate.container = testContainer
                    let result = appDelegate.application(self.mockApplication, didFinishLaunchingWithOptions:nil)
                    expect(result).to(beTrue())
                    expect(testService.trackerKeys).to(equal(["didFinishLaunching()"]))
                    expect(testService.trackerCount).to(equal(1))
                }

                it("service.didBecomeActive") {
                    appDelegate.applicationDidBecomeActive(self.mockApplication)
                    expect(testService.trackerKeys).to(equal(["didBecomeActive()"]))
                    expect(testService.trackerCount).to(equal(1))
                }

                it("service.willResignActive") {
                    appDelegate.applicationWillResignActive(self.mockApplication)
                    expect(testService.trackerKeys).to(equal(["willResignActive()"]))
                    expect(testService.trackerCount).to(equal(1))
                }

                it("service.willTerminate") {
                    appDelegate.applicationWillTerminate(self.mockApplication)
                    expect(testService.trackerKeys).to(equal(["willTerminate()"]))
                    expect(testService.trackerCount).to(equal(1))
                }

                it("service.didEnterBackground") {
                    appDelegate.applicationDidEnterBackground(self.mockApplication)
                    expect(testService.trackerKeys).to(equal(["didEnterBackground()"]))
                    expect(testService.trackerCount).to(equal(1))
                }

                it("service.willEnterForeground") {
                    appDelegate.applicationWillEnterForeground(self.mockApplication)
                    expect(testService.trackerKeys).to(equal(["willEnterForeground()"]))
                    expect(testService.trackerCount).to(equal(1))
                }
            }
        }

        describe("IVGACApplicationDelegate launching with registered CoordinatorType") {
            var appDelegate: TestIVGACApplicationDelegate!
            var testAppCoordinator: TestAppCoordinator!
            var testWindow: TestWindow!

            beforeEach {
                testWindow = TestWindow()
                let container = ApplicationContainer(window: testWindow)
                testAppCoordinator = TestAppCoordinator(container: container)
                container.addCoordinator(testAppCoordinator, forProtocol: CoordinatorType.self)
                appDelegate = TestIVGACApplicationDelegate(testContainer:container)
            }

            it("should call makeKeyAndVisible") {
                appDelegate.window = testWindow
                appDelegate.application(self.mockApplication, didFinishLaunchingWithOptions:nil)
                expect(testWindow.makeKeyAndVisibleCallCount).to(equal(1))
           }

        }
    }
}