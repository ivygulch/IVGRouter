//
//  MockWindow.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

class MockWindow: UIWindow, TrackableTestClassProxy {

    let trackableTestClass = TrackableTestClass()

    override var rootViewController: UIViewController? {
        didSet {
            let value = rootViewController == nil ? "nil" : "\(rootViewController!)"
            track("setRootViewController", [value])
        }
    }

    override func makeKeyAndVisible() {
        track("makeKeyAndVisible", [])
    }

}
