//
//  AppDelegate.swift
//  IVGRouterDemo
//
//  Created by Douglas Sjoquist on 4/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var demoRouteCoordinator: DemoRouteCoordinator?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)

        demoRouteCoordinator = DemoRouteCoordinator(window: window)
        demoRouteCoordinator?.executeDefaultRouteSequence()

        return true
    }

}

