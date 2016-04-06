//
//  RootRouteSegmentPresenter.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public class RootRouteSegmentPresenter : RouteSegmentPresenterType {

    public convenience init() {
        self.init(presenterIdentifier: Identifier(name: String(self.dynamicType)))
    }
    
    public init(presenterIdentifier: Identifier) {
        self.presenterIdentifier = presenterIdentifier
    }
    
    public let presenterIdentifier: Identifier

    public func presentViewController(presentedViewController : UIViewController, from presentingViewController: UIViewController?, withWindow window: UIWindow?, completion: ((Bool) -> Void)) {
        guard let window = window else {
            print("Cannot present Root: Router.window is nil")
            completion(false)
            return
        }
        if let _ = presentingViewController {
            print("Cannot present Root: presentingViewController is not nil")
            completion(false)
            return
        }
        window.rootViewController = presentedViewController
        window.makeKeyAndVisible()
        completion(true)
    }
    
}
