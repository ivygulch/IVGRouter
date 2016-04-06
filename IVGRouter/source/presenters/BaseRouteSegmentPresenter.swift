//
//  BaseRouteSegmentPresenter.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public class BaseRouteSegmentPresenter {

    public convenience init() {
        self.init(presenterIdentifier: Identifier(name: String(self.dynamicType)))
    }
    
    public init(presenterIdentifier: Identifier) {
        self.presenterIdentifier = presenterIdentifier
    }
    
    public let presenterIdentifier: Identifier

    func checkNil(item : Any?, _ source: String) -> String? {
        if item == nil {
            return nil
        }
        return "\(source) must be nil"
    }

    func checkNotNil(item : Any?, _ source: String) -> String? {
        if item != nil {
            return nil
        }
        return "\(source) must not be nil"
    }

    func checkType<T>(item : Any?, type: T.Type, _ source: String) -> String? {
        if let _ = item as? T {
            return nil
        }
        let foundDescription = (item == nil) ? "nil" : String(item!)
        return "\(source) must be of type \(type) but found \(foundDescription)"
    }

    func verify(verificationMessage: String?, completion: ((Bool) -> Void)) -> Bool {
        if let verificationMessage = verificationMessage {
            print("\(String(self)) cannot present view controller: \(verificationMessage)")
            completion(false)
            return false
        }
        return true
    }
}
