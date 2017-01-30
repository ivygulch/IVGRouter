//
//  ViewController.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 3/21/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

class TabBarController : UITabBarController {

    let name: String
    var backAction: Action? {
        didSet {
            if let _ = backAction {
                let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.doBackAction))
                navigationItem.leftBarButtonItem = backButton
            } else {
                navigationItem.leftBarButtonItem = nil
            }
        }
    }
    var rightAction: Action? {
        didSet {
            if let _ = rightAction {
                let rightButton = UIBarButtonItem(title: "Right", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.doRightAction))
                navigationItem.rightBarButtonItem = rightButton
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        }
    }

    init(name: String) {
        self.name = name
        super.init(nibName: nil, bundle: nil)
    }

    override var description: String {
        return "tbc(\(name)), selected=\(selectedIndex)"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("coder not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.lightGray
        navigationItem.title = name

        navigationItem.hidesBackButton = true
    }

    func doBackAction() {
        if let backAction = backAction {
            let backTitle = navigationItem.leftBarButtonItem?.title
            print("\(name).back(\(backTitle))")
            backAction()
        }
    }

    func doRightAction() {
        if let rightAction = rightAction {
            let rightTitle = navigationItem.rightBarButtonItem?.title
            print("\(name).right(\(rightTitle))")
            rightAction()
        }
    }

}
