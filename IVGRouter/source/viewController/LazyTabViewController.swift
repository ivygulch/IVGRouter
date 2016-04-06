//
//  LazyTabViewController.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/29/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

class LazyTabViewController : UIViewController {

    var loadSegment:((Void) -> (UIViewController?))?

    init(title:String?, image:UIImage?, loadSegment:(Void) -> (UIViewController?)) {
        self.loadSegment = loadSegment
        super.init(nibName: nil, bundle: nil)

        tabBarItem.title = title
        tabBarItem.image = image
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let loadSegment = loadSegment, childViewController = loadSegment() {
            addChildViewController(childViewController)
            childViewController.view.frame =
                view.bounds
            view.addSubview(childViewController.view)
            childViewController.didMoveToParentViewController(self)
        }
    }

    lazy var childViewController: UIViewController? = {
        return self.childViewControllers.first
    }()

}
