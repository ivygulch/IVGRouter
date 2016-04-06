//
//  IdentifierSpec.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/1/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class IdentifierSpec: QuickSpec {

    override func spec() {

        describe("checking equality") {
            let segmentIdentifierA1 = Identifier(name:"a")
            let segmentIdentifierA2 = Identifier(name:"a")
            let segmentIdentifierB = Identifier(name:"b")

            it("of same object should be true") {
                expect(segmentIdentifierA1).to(equal(segmentIdentifierA1))
            }

            it("of different objects with same name should be true") {
                expect(segmentIdentifierA1).to(equal(segmentIdentifierA2))
            }

            it("of different objects with different name should be false") {
                expect(segmentIdentifierA1).toNot(equal(segmentIdentifierB))
            }
        }

    }
}