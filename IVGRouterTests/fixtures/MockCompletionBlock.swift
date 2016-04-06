//
//  MockCompletionBlock.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/1/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

class MockCompletionBlock : TrackableTestClass {

    var completion: (Bool) -> Void {
        return {
            (finished:Bool) -> Void in
            self.track("completion", ["\(finished)"])
        }
    }

}