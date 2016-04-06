//
//  UserDefaultsService.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/21/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public protocol UserDefaultsServiceType: ServiceType {
    func value<T>(key: String, valueType:T.Type) -> T?
    func setValue<T>(value: T, forKey key: String)
    func removeValueForKey(key: String)
}

public class UserDefaultsService: UserDefaultsServiceType {

    public required init?(container: ApplicationContainerType) {
        self.container = container
        self.userDefaults = NSUserDefaults.standardUserDefaults()
    }

    public init(container: ApplicationContainerType, userDefaults: NSUserDefaults) {
        self.container = container
        self.userDefaults = userDefaults
    }

    public func value<T>(key: String, valueType:T.Type) -> T? {
        if T.self == String.self {
            return userDefaults.stringForKey(key) as! T?
        } else if T.self == Int.self {
            return userDefaults.integerForKey(key) as? T
        } else if T.self == Float.self {
            return userDefaults.floatForKey(key) as? T
        } else if T.self == Double.self {
            return userDefaults.doubleForKey(key) as? T
        } else if T.self == Bool.self {
            return userDefaults.boolForKey(key) as? T
        } else if T.self == NSURL.self {
            return userDefaults.URLForKey(key) as? T
        }

        return nil
    }

    public func setValue<T>(value: T, forKey key: String) {
        if let value = value as? String {
            userDefaults.setObject(value, forKey: key)
        } else if let value = value as? Int {
            userDefaults.setInteger(value, forKey: key)
        } else if let value = value as? Float {
            userDefaults.setFloat(value, forKey: key)
        } else if let value = value as? Double {
            userDefaults.setDouble(value, forKey: key)
        } else if let value = value as? Bool {
            userDefaults.setBool(value, forKey: key)
        } else if let value = value as? NSURL {
            userDefaults.setURL(value, forKey: key)
        }
    }

    public func removeValueForKey(key: String) {
        userDefaults.removeObjectForKey(key)
    }

    public func willResignActive() {
        userDefaults.synchronize()
    }

    // MARK: private variables

    private let container: ApplicationContainerType
    private let userDefaults: NSUserDefaults
}