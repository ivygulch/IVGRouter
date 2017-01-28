//
//  RouteSequenceItemSpec.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 5/15/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class RouteSequenceItemSpec: QuickSpec {

    func differenceFromExpectedOptions(_ expectedOptions: RouteSequenceOptions, actualOptions: RouteSequenceOptions?) -> [String] {
        var result: [String] = []
        for (key,expectedValue) in expectedOptions {
            if let actualValue = actualOptions?[key] {
                if actualValue !== expectedValue {
                    result.append("Expected option: \(key):\(expectedValue), got \(key):\(actualValue)")
                }
            } else {
                result.append("Expected option: \(key):\(expectedValue)")
            }
        }

        if let actualOptions = actualOptions {
            for (key,actualValue) in actualOptions {
                let expectedValue = expectedOptions[key]
                if expectedValue == nil {
                    result.append("Did not expected option: \(key):\(actualValue)")
                }
            }
        }

        return result
    }

    override func spec() {

        describe("RouteSequenceItemSpec") {

            context("when initializing directly") {

                it("should retain values") {
                    let testIdentifier = Identifier(name: "test")
                    let testOptions: RouteSequenceOptions = ["a":1 as AnyObject, "b":true as AnyObject, "c":"value" as AnyObject]
                    let item = RouteSequenceItem(segmentIdentifier: testIdentifier, options: testOptions)
                    expect(item.segmentIdentifier).to(equal(testIdentifier))
                    expect(String(describing: item.options)).to(equal(String(describing: testOptions)))
                }
            }

            context("when transforming Identifier") {

                it("should produce valid item") {
                    let testIdentifier = Identifier(name: "test")
                    let item = RouteSequenceItem.transform(testIdentifier)
                    expect(item).toNot(beNil())
                    if let item = item {
                        expect(item.segmentIdentifier).to(equal(testIdentifier))
                        expect(item.options).to(beEmpty())
                    }
                }
            }

            context("when transforming Identifier and options") {

                it("should produce valid item") {
                    let testIdentifier = Identifier(name: "test")
                    let testOptions: RouteSequenceOptions = ["a":1 as AnyObject, "b":true as AnyObject, "c":"value" as AnyObject]
                    let item = RouteSequenceItem.transform((testIdentifier,testOptions))
                    expect(item).toNot(beNil())
                    if let item = item {
                        expect(item.segmentIdentifier).to(equal(testIdentifier))
                        expect(String(describing: item.options)).to(equal(String(describing: testOptions)))
                    }
                }
            }

            context("when transforming String and options") {

                it("should produce valid item") {
                    let testValue = "test"
                    let testOptions: RouteSequenceOptions = ["a":1 as AnyObject, "b":true as AnyObject, "c":"value" as AnyObject]
                    let item = RouteSequenceItem.transform((testValue,testOptions))
                    expect(item).toNot(beNil())
                    if let item = item {
                        expect(item.segmentIdentifier).to(equal(Identifier(name: testValue)))
                        expect(String(describing: item.options)).to(equal(String(describing: testOptions)))
                    }
                }
            }

            context("when transforming simple string") {

                it("should produce valid item") {
                    let testValue = "test"
                    let item = RouteSequenceItem.transform(testValue)
                    expect(item).toNot(beNil())
                    if let item = item {
                        expect(item.segmentIdentifier).to(equal(Identifier(name: testValue)))
                        expect(item.options).to(beEmpty())
                    }
                }
            }

            context("when transforming string with embedded options") {

                it("should produce valid item") {
                    let testName = "test"
                    let testValue = "\(testName);a=1;b=2;c"
                    let expectedOptions: RouteSequenceOptions = ["a":"1" as AnyObject,"b":"2" as AnyObject,"c":"" as AnyObject]
                    let item = RouteSequenceItem.transform(testValue)
                    expect(item).toNot(beNil())
                    if let item = item {
                        expect(item.segmentIdentifier).to(equal(Identifier(name: testName)))
                        expect(String(describing: item.options)).to(equal(String(describing: expectedOptions)))
                    }
                }
            }

            context("when transforming other value") {

                it("should not produce valid item") {
                    let testValue = 123
                    let item = RouteSequenceItem.transform(testValue)
                    expect(item).to(beNil())
                }
            }
            
        }
        
    }
    
}
