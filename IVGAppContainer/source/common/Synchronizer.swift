//
//  Synchronizer.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/20/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public class Synchronizer {
    private let queue:dispatch_queue_t

    public init() {
        let uuid = NSUUID().UUIDString
        self.queue = dispatch_queue_create("Sync.\(uuid)",nil)
    }

    public init(queueName:String) {
        self.queue = dispatch_queue_create(queueName,nil)
    }

    public init(queue:dispatch_queue_t) {
        self.queue = queue
    }

    public func execute(closure:()->Void) {
        dispatch_sync(queue, {
            closure()
        })
    }

    public func valueOf<T>(closure:()->T) -> T {
        var result:T!
        dispatch_sync(queue, {
            result = closure()
        })
        return result
    }

}