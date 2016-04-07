//
//  Coordinator.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/19/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation
import IVGRouter

public protocol CoordinatorType {

    init(container: ApplicationContainerType)

    func registerRouteSegments(router: RouterType)
}