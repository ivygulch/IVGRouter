//
//  PlaceholderViewController.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

open class PlaceholderViewController: UIViewController {

    public init(childViewController: UIViewController? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.childViewController = childViewController
    }

    public init(lazyLoader: @escaping ((Void) -> UIViewController)) {
        self.lazyLoader = lazyLoader
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open var childViewController: UIViewController? {
        get {
            return self.childViewControllers.first
        }
        set {
            if newValue == self.childViewControllers.first {
                return // nothing to do
            }
            for viewController in self.childViewControllers {
                viewController.willMove(toParentViewController: nil)
                viewController.view.removeFromSuperview()
                viewController.removeFromParentViewController()
            }
            if let newValue = newValue {
                addChildViewController(newValue)
                newValue.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
                newValue.view.frame = self.view.bounds
                self.view.addSubview(newValue.view)
                newValue.didMove(toParentViewController: self)
            }
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        if let lazyLoader = lazyLoader {
            childViewController = lazyLoader()
        }
    }


    override open var tabBarItem: UITabBarItem! {
        get {
            return childViewController?.tabBarItem ?? super.tabBarItem
        }
        set {
            if let childViewController = childViewController {
                childViewController.tabBarItem = newValue
            } else {
                super.tabBarItem = newValue
            }
        }
    }

    override open var navigationItem: UINavigationItem {
        get {
            return childViewController?.navigationItem ?? super.navigationItem
        }
    }

    fileprivate var lazyLoader: ((Void) -> UIViewController)?
    
}
