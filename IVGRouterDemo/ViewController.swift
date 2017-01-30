//
//  ViewController.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 3/21/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

typealias Action = ((Void) -> Void)

class ViewController : UIViewController {

    let name: String
    var actions: [UIButton: Action] = [: ]
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
    var didAppearAction: Action?

    var currentItemTop: CGFloat = 80.0
    let itemSize = CGSize(width: 200.0,height: 30.0)

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

    func centeredRect(_ top: CGFloat, _ size: CGSize) -> CGRect {
        let midX = self.view.bounds.midX
        return CGRect(x: midX-size.width/2,y: top,width: size.width,height: size.height)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.lightGray
        navigationItem.title = name

        navigationItem.hidesBackButton = true

        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.black
        titleLabel.text = name
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        addItem(titleLabel)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        didAppearAction?()
    }

    func addItem(_ item: UIView) {
        loadViewIfNeeded()
        item.frame = centeredRect(currentItemTop,itemSize)
        view.addSubview(item)
        currentItemTop += itemSize.height + 8
    }

    func addAction(_ title: String, titleColor: UIColor = UIColor.white, action: @escaping ((Void) -> Void)) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: UIControlState())
        button.setTitleColor(titleColor, for: UIControlState())
        button.addTarget(self, action: #selector(ViewController.doAction(_: )), for: .touchUpInside)
        actions[button] = action
        addItem(button)
        return button
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

    func doAction(_ button: UIButton) {
        if let action = actions[button] {
            let title = button.title(for: UIControlState()) ?? "?"
            print("\(name).\(title)")
            action()
        }
    }

}
