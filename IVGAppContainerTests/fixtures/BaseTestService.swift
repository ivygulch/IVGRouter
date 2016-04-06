//
//  BaseTestService.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/19/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation
import IVGAppContainer

class BaseTestService : TrackableTestClass, ServiceType {

    var willFinishLaunchingValue = true
    var didFinishLaunchingValue = true

    required init?(container: ApplicationContainerType) {
    }

    convenience init(container: ApplicationContainerType, willFinishLaunchingValue:Bool, didFinishLaunchingValue:Bool) {
        self.init(container:container)!
        self.willFinishLaunchingValue = willFinishLaunchingValue
        self.didFinishLaunchingValue = didFinishLaunchingValue
    }

    func willFinishLaunching() -> Bool {
        track(#function)
        return willFinishLaunchingValue
    }

    func didFinishLaunching() -> Bool {
        track(#function)
        return didFinishLaunchingValue
    }

    func didBecomeActive() {
        track(#function)
    }

    func willResignActive() {
        track(#function)
    }

    func willTerminate() {
        track(#function)
    }

    func didEnterBackground() {
        track(#function)
    }

    func willEnterForeground() {
        track(#function)
    }

}

