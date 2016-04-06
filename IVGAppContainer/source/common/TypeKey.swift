//
//  TypeKey.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/19/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public struct TypeKey: Hashable {
    public init<T>(_ keyType: T) {
        self.keyName = "\(keyType.self)"
    }

    public var hashValue: Int {
        return keyName.hashValue
    }

    private var keyName: String
}

public func ==(lhs: TypeKey, rhs: TypeKey) -> Bool {
    return lhs.keyName == rhs.keyName
}
