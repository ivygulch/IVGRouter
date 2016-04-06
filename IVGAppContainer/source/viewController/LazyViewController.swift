//
//  LazyViewController.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/29/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public class LazyViewController : UIViewController {

    public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, loadSegment:(Void) -> (UIViewController?)) {
        self.loadSegment = loadSegment
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        if let loadSegment = loadSegment, childViewController = loadSegment() {
            addChildViewController(childViewController)
            childViewController.view.frame =
                view.bounds
            view.addSubview(childViewController.view)
            childViewController.didMoveToParentViewController(self)
        }
    }

    public lazy var childViewController: UIViewController? = {
        return self.childViewControllers.first
    }()

    private var loadSegment:((Void) -> (UIViewController?))?

}
