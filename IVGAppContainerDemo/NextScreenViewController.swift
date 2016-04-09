//
//  NextScreenViewController.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/21/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

class NextScreenViewController : UIViewController {

    var returnAction:(Void -> Void)?
    var wrapAction:(Void -> Void)?

    @IBAction func wrapAction(button: UIButton) {
        print("wrapAction")
        wrapAction?()
    }

    @IBAction func returnAction(button: UIButton) {
        print("returnAction")
        returnAction?()
    }

}