//
//  ApplicationContainerTypeSpec.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/19/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation
import Quick
import Nimble
import IVGAppContainer

protocol TestServiceTypeA : ServiceType {}
protocol TestServiceTypeB : ServiceType {}
protocol TestServiceTypeC : ServiceType {}
protocol TestServiceTypeD : ServiceType {}
protocol TestServiceTypeE : ServiceType {}
protocol TestServiceTypeF : ServiceType {}
protocol TestServiceTypeG : ServiceType {}
protocol TestServiceTypeH : ServiceType {}
protocol TestServiceTypeI : ServiceType {}
protocol TestServiceTypeJ : ServiceType {}

class ApplicationContainerTypeSpec: QuickSpec {

    override func spec() {
        describe("ApplicationContainerType dependency injection") {
            var applicationContainer:ApplicationContainerType!
            var resource:BaseTestResource!
            var service:BaseTestService!
            var coordinator:BaseTestCoordinator!

            beforeEach {
                applicationContainer = ApplicationContainer(window: TestWindow())
                service = BaseTestService(container: applicationContainer)!
                coordinator = BaseTestCoordinator(container: applicationContainer)!
                resource = BaseTestResource(container: applicationContainer)!
            }

            describe("resource") {
                it("should work") {
                    expect(applicationContainer.resourceCount).to(equal(0))
                    applicationContainer.addResource(resource, forProtocol: ResourceType.self)
                    expect(applicationContainer.resourceCount).to(equal(1))
                    if let checkResource = applicationContainer.resource(ResourceType.self) as? BaseTestResource {
                        expect(checkResource === resource).to(beTrue())
                    }
                }
            }

            describe("service") {
                it("should work") {
                    expect(applicationContainer.serviceCount).to(equal(0))
                    applicationContainer.addService(service, forProtocol: ServiceType.self)
                    expect(applicationContainer.serviceCount).to(equal(1))
                    if let checkService = applicationContainer.service(ServiceType.self) as? BaseTestService {
                        expect(checkService === service).to(beTrue())
                    }
                }
            }

            describe("coordinator") {
                it("should work") {
                    expect(applicationContainer.coordinatorCount).to(equal(0))
                    applicationContainer.addCoordinator(coordinator, forProtocol: CoordinatorType.self)
                    expect(applicationContainer.coordinatorCount).to(equal(1))
                    if let checkCoordinator = applicationContainer.coordinator(CoordinatorType.self) as? BaseTestCoordinator {
                        expect(checkCoordinator === coordinator).to(beTrue())
                    }
                }
            }
        }

        describe("ApplicationContainerType lifecycle event") {
            var applicationContainer:ApplicationContainerType!
            var services:[BaseTestService]!

            beforeEach {
                applicationContainer = ApplicationContainer(window: TestWindow())
                services = []
                for _ in 0..<10 {
                    services.append(BaseTestService(container: applicationContainer)!)
                }
                applicationContainer.addService(services[0], forProtocol:TestServiceTypeA.self)
                applicationContainer.addService(services[1], forProtocol:TestServiceTypeB.self)
                applicationContainer.addService(services[2], forProtocol:TestServiceTypeC.self)
                applicationContainer.addService(services[3], forProtocol:TestServiceTypeD.self)
                applicationContainer.addService(services[4], forProtocol:TestServiceTypeE.self)
                applicationContainer.addService(services[5], forProtocol:TestServiceTypeF.self)
                applicationContainer.addService(services[6], forProtocol:TestServiceTypeG.self)
                applicationContainer.addService(services[7], forProtocol:TestServiceTypeH.self)
                applicationContainer.addService(services[8], forProtocol:TestServiceTypeI.self)
                applicationContainer.addService(services[9], forProtocol:TestServiceTypeJ.self)
            }

            describe("willFinishLaunching") {
                it("should call service.willFinishLaunching once for each service in order") {
                    let result = applicationContainer.willFinishLaunching()
                    expect(result).to(beTrue())
                    var previousTimestamp:NSDate?
                    for service in services {
                        expect(service.trackerKeys).to(equal(["willFinishLaunching()"]))
                        expect(service.trackerCount).to(equal(1))
                        let timestamp = service.tracker["willFinishLaunching()"]!.first!
                        if let previousTimestamp = previousTimestamp {
                            expect(timestamp.timeIntervalSinceReferenceDate).to(beGreaterThan(previousTimestamp.timeIntervalSinceReferenceDate))
                        }
                        previousTimestamp = timestamp
                    }
                }
            }

            describe("didFinishLaunching") {
                it("should call service.didFinishLaunching once for each service in order") {
                    let result = applicationContainer.didFinishLaunching()
                    expect(result).to(beTrue())
                    var previousTimestamp:NSDate?
                    for service in services {
                        expect(service.trackerKeys).to(equal(["didFinishLaunching()"]))
                        expect(service.trackerCount).to(equal(1))
                        let timestamp = service.tracker["didFinishLaunching()"]!.first!
                        if let previousTimestamp = previousTimestamp {
                            expect(timestamp.timeIntervalSinceReferenceDate).to(beGreaterThan(previousTimestamp.timeIntervalSinceReferenceDate))
                        }
                        previousTimestamp = timestamp
                    }
                }
            }

            describe("didBecomeActive") {
                it("should call service.didBecomeActive once for each service in order") {
                    applicationContainer.didBecomeActive()
                    var previousTimestamp:NSDate?
                    for service in services {
                        expect(service.trackerKeys).to(equal(["didBecomeActive()"]))
                        expect(service.trackerCount).to(equal(1))
                        let timestamp = service.tracker["didBecomeActive()"]!.first!
                        if let previousTimestamp = previousTimestamp {
                            expect(timestamp.timeIntervalSinceReferenceDate).to(beGreaterThan(previousTimestamp.timeIntervalSinceReferenceDate))
                        }
                        previousTimestamp = timestamp
                    }
                }
            }

            describe("willResignActive") {
                it("should call service.willResignActive once for each service in order") {
                    applicationContainer.willResignActive()
                    var previousTimestamp:NSDate?
                    for service in services {
                        expect(service.trackerKeys).to(equal(["willResignActive()"]))
                        expect(service.trackerCount).to(equal(1))
                        let timestamp = service.tracker["willResignActive()"]!.first!
                        if let previousTimestamp = previousTimestamp {
                            expect(timestamp.timeIntervalSinceReferenceDate).to(beGreaterThan(previousTimestamp.timeIntervalSinceReferenceDate))
                        }
                        previousTimestamp = timestamp
                    }
                }
            }

            describe("willTerminate") {
                it("should call service.willTerminate once for each service in order") {
                    applicationContainer.willTerminate()
                    var previousTimestamp:NSDate?
                    for service in services {
                        expect(service.trackerKeys).to(equal(["willTerminate()"]))
                        expect(service.trackerCount).to(equal(1))
                        let timestamp = service.tracker["willTerminate()"]!.first!
                        if let previousTimestamp = previousTimestamp {
                            expect(timestamp.timeIntervalSinceReferenceDate).to(beGreaterThan(previousTimestamp.timeIntervalSinceReferenceDate))
                        }
                        previousTimestamp = timestamp
                    }
                }
            }

            describe("didEnterBackground") {
                it("should call service.didEnterBackground once for each service in order") {
                    applicationContainer.didEnterBackground()
                    var previousTimestamp:NSDate?
                    for service in services {
                        expect(service.trackerKeys).to(equal(["didEnterBackground()"]))
                        expect(service.trackerCount).to(equal(1))
                        let timestamp = service.tracker["didEnterBackground()"]!.first!
                        if let previousTimestamp = previousTimestamp {
                            expect(timestamp.timeIntervalSinceReferenceDate).to(beGreaterThan(previousTimestamp.timeIntervalSinceReferenceDate))
                        }
                        previousTimestamp = timestamp
                    }
                }
            }

            describe("willEnterForeground") {
                it("should call service.willEnterForeground once for each service in order") {
                    applicationContainer.willEnterForeground()
                    var previousTimestamp:NSDate?
                    for service in services {
                        expect(service.trackerKeys).to(equal(["willEnterForeground()"]))
                        expect(service.trackerCount).to(equal(1))
                        let timestamp = service.tracker["willEnterForeground()"]!.first!
                        if let previousTimestamp = previousTimestamp {
                            expect(timestamp.timeIntervalSinceReferenceDate).to(beGreaterThan(previousTimestamp.timeIntervalSinceReferenceDate))
                        }
                        previousTimestamp = timestamp
                    }
                }
            }
        }

        describe("ApplicationContainerType lifecycle event special cases") {

            describe("willFinishLaunching") {
                it("should call service.willFinishLaunching until one service in the list fails") {
                    let applicationContainer = ApplicationContainer(window: TestWindow())
                    let serviceA = BaseTestService(container: applicationContainer)!
                    let serviceB = BaseTestService(container: applicationContainer, willFinishLaunchingValue: false, didFinishLaunchingValue: true)
                    let serviceC = BaseTestService(container: applicationContainer)!
                    applicationContainer.addService(serviceA, forProtocol:TestServiceTypeA.self)
                    applicationContainer.addService(serviceB, forProtocol:TestServiceTypeB.self)
                    applicationContainer.addService(serviceC, forProtocol:TestServiceTypeC.self)

                    let result = applicationContainer.willFinishLaunching()
                    expect(result).to(beFalse())
                    expect(serviceA.trackerKeys).to(equal(["willFinishLaunching()"]))
                    expect(serviceA.trackerCount).to(equal(1))
                    expect(serviceB.trackerKeys).to(equal(["willFinishLaunching()"]))
                    expect(serviceB.trackerCount).to(equal(1))
                    expect(serviceC.trackerCount).to(equal(0))
                }
            }
        }

        describe("ApplicationContainerType lifecycle event special cases") {

            describe("didFinishLaunching") {
                it("should call service.didFinishLaunching until one service in the list fails") {
                    let applicationContainer = ApplicationContainer(window: TestWindow())
                    let serviceA = BaseTestService(container: applicationContainer)!
                    let serviceB = BaseTestService(container: applicationContainer, willFinishLaunchingValue: true, didFinishLaunchingValue: false)
                    let serviceC = BaseTestService(container: applicationContainer)!
                    applicationContainer.addService(serviceA, forProtocol:TestServiceTypeA.self)
                    applicationContainer.addService(serviceB, forProtocol:TestServiceTypeB.self)
                    applicationContainer.addService(serviceC, forProtocol:TestServiceTypeC.self)

                    let result = applicationContainer.didFinishLaunching()
                    expect(result).to(beFalse())
                    expect(serviceA.trackerKeys).to(equal(["didFinishLaunching()"]))
                    expect(serviceA.trackerCount).to(equal(1))
                    expect(serviceB.trackerKeys).to(equal(["didFinishLaunching()"]))
                    expect(serviceB.trackerCount).to(equal(1))
                    expect(serviceC.trackerCount).to(equal(0))
                }
            }
        }

        describe("ApplicationContainerType") {

            var applicationContainer:ApplicationContainerType!
            var service:BaseTestService!

            beforeEach {
                applicationContainer = ApplicationContainer(window: TestWindow())
                service = BaseTestService(container: applicationContainer)!
            }

            describe("after calling") {
                it("willFinishLaunching, should call service.willFinishLaunching when added") {
                    expect(service.trackerCount).to(equal(0))
                    applicationContainer.willFinishLaunching()
                    applicationContainer.addService(service, forProtocol:TestServiceTypeA.self)

                    expect(service.trackerKeys).to(equal(["willFinishLaunching()"]))
                    expect(service.trackerCount).to(equal(1))
                }

                it("didFinishLaunching, should call service.willFinishLaunching/didFinishLaunching when added") {
                    expect(service.trackerCount).to(equal(0))
                    applicationContainer.didFinishLaunching()
                    applicationContainer.addService(service, forProtocol:TestServiceTypeA.self)

                    expect(service.trackerKeys).to(equal(["willFinishLaunching()","didFinishLaunching()"]))
                    expect(service.trackerCount).to(equal(2))
                }

                it("didFinishLaunching, should call service.willFinishLaunching/didFinishLaunching/didBecomeActive when added") {
                    expect(service.trackerCount).to(equal(0))
                    applicationContainer.didBecomeActive()
                    applicationContainer.addService(service, forProtocol:TestServiceTypeA.self)

                    expect(service.trackerKeys).to(equal(["willFinishLaunching()","didFinishLaunching()","didBecomeActive()"]))
                    expect(service.trackerCount).to(equal(3))
                }

                it("didEnterBackground, should call service.willFinishLaunching/didFinishLaunching/didEnterBackground when added") {
                    expect(service.trackerCount).to(equal(0))
                    applicationContainer.didEnterBackground()
                    applicationContainer.addService(service, forProtocol:TestServiceTypeA.self)

                    expect(service.trackerKeys).to(equal(["willFinishLaunching()","didFinishLaunching()","didEnterBackground()"]))
                    expect(service.trackerCount).to(equal(3))
                }
            }

        }

    }
}
