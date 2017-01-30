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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        demoRouteCoordinator = DemoRouteCoordinator(window: window)
        demoRouteCoordinator?.startupAction()

        return true
    }

}

