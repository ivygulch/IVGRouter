//
//  TrackableTestClass.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/19/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

protocol TrackableTestClassType {
    var trackerLog:[(String,NSDate)] { get }
    var tracker:[String:[NSDate]] { get }
    var trackerKeys:Set<String> { get }
    var trackerCount:Int { get }

    func track(key:String)
}

protocol TrackableTestClassProxy : TrackableTestClassType {
    var trackableTestClass: TrackableTestClass { get }
}

extension TrackableTestClassProxy {
    var trackerLog:[(String,NSDate)] {
        return trackableTestClass.trackerLog
    }
    var tracker:[String:[NSDate]] {
        return trackableTestClass.tracker
    }
    var trackerKeys:Set<String> {
        return trackableTestClass.trackerKeys
    }
    var trackerCount:Int {
        return trackableTestClass.trackerCount
    }

    func track(key:String) {
        trackableTestClass.track(key)
    }
}

class TrackableTestClass : TrackableTestClassType {
    var trackerLog:[(String,NSDate)] = []
    var tracker:[String:[NSDate]] = [:]
    var trackerKeys:Set<String> {
        return Set(tracker.keys)
    }
    var trackerCount:Int {
        return tracker.values.reduce(0,combine:{$0 + $1.count})
    }

    func track(key:String) {
        let timestamp = NSDate()

        var timestamps:[NSDate] = tracker[key] ?? []
        timestamps.append(timestamp)
        tracker[key] = timestamps
        trackerLog.append((key,timestamp))
    }
    
}

