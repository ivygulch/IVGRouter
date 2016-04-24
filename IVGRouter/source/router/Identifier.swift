//
//  Identifier.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/22/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public func ==(lhs: Identifier, rhs: Identifier) -> Bool {
    return lhs.name == rhs.name
}

public struct Identifier: Hashable {

    public init(name: String) {
        self.name = name
    }
    
    let name: String
    public var hashValue: Int { return name.hashValue }
}
