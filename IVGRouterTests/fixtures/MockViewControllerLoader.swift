//
//  MockViewControllerLoader.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/1/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

class MockViewControllerLoader : TrackableTestClass {

    init(viewController: UIViewController?) {
        self.viewController = viewController
    }

    func load() -> (() -> UIViewController?) {
        return {
            () -> UIViewController? in
            let name = self.viewController?.description ?? "nil"
            self.track("load",[name])
            return self.viewController
        }
    }

    fileprivate let viewController: UIViewController?
}
