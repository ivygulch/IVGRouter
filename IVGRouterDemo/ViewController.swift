//
//  ViewController.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 3/21/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

typealias Action = (Void -> Void)

class ViewController : UIViewController {

    let name: String
    var actions: [UIButton: Action] = [:]
    var backAction: Action? {
        didSet {
            if let _ = backAction {
                let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.doBackAction))
                navigationItem.leftBarButtonItem = backButton
            } else {
                navigationItem.leftBarButtonItem = nil
            }
        }
    }
    var currentItemTop: CGFloat = 80.0
    let itemSize = CGSizeMake(200.0,30.0)

    init(name: String) {
        self.name = name
        super.init(nibName: nil, bundle: nil)
    }

    override var description: String {
        return "vc(\(name))"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("coder not supported")
    }

    func centeredRect(top: CGFloat, _ size: CGSize) -> CGRect {
        let midX = CGRectGetMidX(self.view.bounds)
        return CGRectMake(midX-size.width/2,top,size.width,size.height)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.lightGrayColor()
        navigationItem.title = name

        navigationItem.hidesBackButton = true

        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.text = name
        titleLabel.font = UIFont.boldSystemFontOfSize(18)
        titleLabel.textAlignment = .Center
        addItem(titleLabel)
    }

    func addItem(item: UIView) {
        loadViewIfNeeded()
        item.frame = centeredRect(currentItemTop,itemSize)
        view.addSubview(item)
        currentItemTop += itemSize.height + 8
    }

    func addAction(title: String, action: (Void -> Void)) {
        let button = UIButton(type: .System)
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.addTarget(self, action: #selector(ViewController.doAction(_:)), forControlEvents: .TouchUpInside)
        actions[button] = action
        addItem(button)
    }

    func doBackAction() {
        if let backAction = backAction {
            let backTitle = navigationItem.leftBarButtonItem?.title
            print("\(name).back(\(backTitle))")
            backAction()
        }
    }

    func doAction(button: UIButton) {
        if let action = actions[button] {
            let title = button.titleForState(.Normal) ?? "?"
            print("\(name).\(title)")
            action()
        }
    }

}