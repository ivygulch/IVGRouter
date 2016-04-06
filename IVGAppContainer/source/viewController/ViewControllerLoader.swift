//
//  ViewControllerLoader.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/29/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

protocol ViewControllerLoaderType {
    func viewControllerForStoryboardName<T: UIViewController>(name: String, viewControllerType: T.Type) -> T?
    func viewControllerForStoryboardName<T: UIViewController>(name: String, viewControllerType: T.Type, viewControllerID: String?) -> T?
}

class ViewControllerLoader : ViewControllerLoaderType{

    func viewControllerForStoryboardName<T: UIViewController>(name: String, viewControllerType: T.Type) -> T? {
        return self.viewControllerForStoryboardName(name, viewControllerType: viewControllerType, viewControllerID: nil)
    }

    func viewControllerForStoryboardName<T: UIViewController>(name: String, viewControllerType: T.Type, viewControllerID: String?) -> T? {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let useViewControllerID = viewControllerID ?? String(viewControllerType)
        return storyboard.instantiateViewControllerWithIdentifier(useViewControllerID) as? T
    }
    
}
