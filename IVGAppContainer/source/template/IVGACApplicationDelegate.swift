//
//  IVGACApplicationDelegate.swift
//  IVGAppContainer
//
//  Base implementation of UIApplicationDelegate to ensure it implements the full ApplicationContainerType pattern
//
//  Created by Douglas Sjoquist on 3/20/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public class IVGACApplicationDelegate<T: ApplicationContainerType> : UIResponder, UIApplicationDelegate {

    // MARK: - methods to override

    /// override for testing or if a subclass is desired
    public lazy var container: T = self.createApplicationContainer(self.window)

    public func createApplicationContainer(window: UIWindow?) -> T {
        return T(window: window)
    }

    public func configureApplicationContainer(container: T) {
        fatalError("You must override this method to configure the application container")
    }

    // MARK: - standard UIApplicationDelegate methods

    public func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)

        configureApplicationContainer(container)
        container.executeDefaultRouteSequence()
        
        return container.willFinishLaunching()
    }
    
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let result = container.didFinishLaunching() ?? false
        if result {
            window?.makeKeyAndVisible()
        }
        return result
    }
    
    public func applicationDidBecomeActive(application: UIApplication) {
        container.didBecomeActive()
    }

    public func applicationWillResignActive(application: UIApplication) {
        container.willResignActive()
    }

    public func applicationWillTerminate(application: UIApplication) {
        container.willTerminate()
    }

    public func applicationDidEnterBackground(application: UIApplication) {
        container.didEnterBackground()
    }

    public func applicationWillEnterForeground(application: UIApplication) {
        container.willEnterForeground()
    }

    // MARK: - private variables

    public var window: UIWindow?
}
