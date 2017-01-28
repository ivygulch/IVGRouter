//
//  BaseRouteSegmentPresenter.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/6/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

// Note, this class deliberately does NOT implement RouteSegmentPresenterType
open class BaseRouteSegmentPresenter {

    public init() {
        guard let subtype = self as? RouteSegmentPresenterType else {
            fatalError("\(self) should implement RouteSegmentPresenterType")
        }
        self.presenterIdentifier = type(of: subtype).defaultPresenterIdentifier
    }
    
    public init(presenterIdentifier: Identifier) {
        self.presenterIdentifier = presenterIdentifier
    }

    // need this form & initialization to match the RouteSegmentPresenterType requirement
    open fileprivate(set) var presenterIdentifier = Identifier(name: "")

    open func checkNil(_ item : Any?, _ source: String) -> String? {
        if item == nil {
            return nil
        }
        return "\(source) must be nil"
    }

    open func checkNotNil(_ item : Any?, _ source: String) -> String? {
        if item != nil {
            return nil
        }
        return "\(source) must not be nil"
    }

    open func checkType<T>(_ item : Any?, type: T.Type, _ source: String) -> String? {
        if let _ = item as? T {
            return nil
        }
        let foundDescription = (item == nil) ? "nil" : String(describing: item!)
        return "\(source) must be of type \(type) but found \(foundDescription)"
    }

    open func verify(_ verificationMessage: String?, completion: ((RoutingResult) -> Void)) -> Bool {
        if let verificationMessage = verificationMessage {
            completion(.failure(RoutingErrors.cannotPresent(self.presenterIdentifier, verificationMessage)))
            return false
        }
        return true
    }
}
