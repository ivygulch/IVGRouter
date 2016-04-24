//
//  MockViewControllerLoader.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/1/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

class MockViewControllerLoader : TrackableTestClass {

    init(viewController: UIViewController?) {
        self.viewController = viewController
    }

    func load() -> ((Void) -> UIViewController?) {
        return {
            (Void) -> UIViewController? in
            let name = self.viewController?.description ?? "nil"
            self.track("load",[name])
            return self.viewController
        }
    }

    private let viewController: UIViewController?
}