//
//  UserDefaultsServiceSpec.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/21/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Quick
import Nimble
import IVGAppContainer

class TestNSUserDefaults : NSUserDefaults {
    var synchronizeCallCount = 0

    override func synchronize() -> Bool {
        synchronizeCallCount += 1
        return super.synchronize()
    }
}

class UserDefaultsServiceSpec: QuickSpec {

    override func spec() {
        describe("UserDefaultsService") {
            var userDefaultsService: UserDefaultsService!
            var testNSUserDefaults: TestNSUserDefaults!

            beforeEach {
                let container = ApplicationContainer(window: TestWindow())
                testNSUserDefaults = TestNSUserDefaults()
                userDefaultsService = UserDefaultsService(container: container, userDefaults: testNSUserDefaults)
                container.addService(userDefaultsService, forProtocol: ServiceType.self)
            }

            describe("willResignActive") {
                it("should call synchronize") {
                    expect(testNSUserDefaults.synchronizeCallCount).to(equal(0))
                    userDefaultsService.willResignActive()
                    expect(testNSUserDefaults.synchronizeCallCount).to(equal(1))
                }
            }

            describe("setters") {
                it("setting string should return same value") {
                    let expectedValue = "test"
                    let key = "key"
                    userDefaultsService.setValue(expectedValue, forKey:key)
                    let actualValue = userDefaultsService.value(key, valueType: String.self)
                    expect(actualValue).to(equal(expectedValue))
                }

                it("setting int should return same value") {
                    let expectedValue = 123
                    let key = "key"
                    userDefaultsService.setValue(expectedValue, forKey:key)
                    let actualValue = userDefaultsService.value(key, valueType: Int.self)
                    expect(actualValue).to(equal(expectedValue))
                }

                it("setting float should return same value") {
                    let expectedValue = Float(123.456)
                    let key = "key"
                    userDefaultsService.setValue(expectedValue, forKey:key)
                    let actualValue = userDefaultsService.value(key, valueType: Float.self)
                    expect(actualValue).to(equal(expectedValue))
                }

                it("setting double should return same value") {
                    let expectedValue = Double(123.45678)
                    let key = "key"
                    userDefaultsService.setValue(expectedValue, forKey:key)
                    let actualValue = userDefaultsService.value(key, valueType: Double.self)
                    expect(actualValue).to(equal(expectedValue))
                }

                it("setting bool should return same value") {
                    let expectedValue = true
                    let key = "key"
                    userDefaultsService.setValue(expectedValue, forKey:key)
                    let actualValue = userDefaultsService.value(key, valueType: Bool.self)
                    expect(actualValue).to(equal(expectedValue))
                }

                it("setting url should return same value") {
                    let expectedValue = NSURL(string: "http://example.com")!
                    let key = "key"
                    userDefaultsService.setValue(expectedValue, forKey:key)
                    let actualValue = userDefaultsService.value(key, valueType: NSURL.self)
                    expect(actualValue).to(equal(expectedValue))
                }
            }

            describe("removing") {
                it("a value should mean it is gone") {
                    let key = "key"
                    userDefaultsService.setValue("test", forKey:key)
                    let valueBefore = userDefaultsService.value(key, valueType: String.self)
                    expect(valueBefore).toNot(beNil())
                    userDefaultsService.removeValueForKey(key)
                    let valueAfter = userDefaultsService.value(key, valueType: String.self)
                    expect(valueAfter).to(beNil())
                }
            }

        }
    }
}

