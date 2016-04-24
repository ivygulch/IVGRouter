//
//  BaseRouteSegmentPresenter.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

// Note, this class deliberately does NOT implement RouteSegmentPresenterType
public class BaseRouteSegmentPresenter {

    public init() {
        guard let subtype = self as? RouteSegmentPresenterType else {
            fatalError("\(self) should implement RouteSegmentPresenterType")
        }
        self.presenterIdentifier = subtype.dynamicType.defaultPresenterIdentifier
    }
    
    public init(presenterIdentifier: Identifier) {
        self.presenterIdentifier = presenterIdentifier
    }

    // need this form & initialization to match the RouteSegmentPresenterType requirement
    public private(set) var presenterIdentifier = Identifier(name: "")

    public func checkNil(item : Any?, _ source: String) -> String? {
        if item == nil {
            return nil
        }
        return "\(source) must be nil"
    }

    public func checkNotNil(item : Any?, _ source: String) -> String? {
        if item != nil {
            return nil
        }
        return "\(source) must not be nil"
    }

    public func checkType<T>(item : Any?, type: T.Type, _ source: String) -> String? {
        if let _ = item as? T {
            return nil
        }
        let foundDescription = (item == nil) ? "nil" : String(item!)
        return "\(source) must be of type \(type) but found \(foundDescription)"
    }

    public func verify(verificationMessage: String?, completion: ((Bool) -> Void)) -> Bool {
        if let verificationMessage = verificationMessage {
            print("\(String(self)) cannot present view controller: \(verificationMessage)")
            completion(false)
            return false
        }
        return true
    }
}
