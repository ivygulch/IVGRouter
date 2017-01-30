//
//  ActingPresentingViewControllerDelegate.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 7/22/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public protocol ActingPresentingViewControllerDelegate {
    var actingPresentingController: UIViewController { get }
}

extension UIViewController {

    var actingPresentingController: UIViewController {
        if let actingPresentingViewControllerDelegate = self as? ActingPresentingViewControllerDelegate {
            return actingPresentingViewControllerDelegate.actingPresentingController
        }
        return self
    }

}
