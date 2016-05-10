//
//  TrackableTestClass.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 3/19/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

struct TrackerLogEntry {
    let key: String
    let values: [String]
    let timestamp: NSDate
}

struct TrackerSummaryEntry {
    let values: [String]
    let timestamp: NSDate
}

protocol TrackableTestClassType {
    var trackerLog:[TrackerLogEntry] { get }
    var trackerSummary:[String:[TrackerSummaryEntry]] { get }
    var trackerKeys:Set<String> { get }
    var trackerKeyValues:[String:[[String]]] { get }
    var trackerKeyCounts:[String:Int] { get }
    var trackerCount:Int { get }

    func track(key:String)
    func track(key:String, _ values:[String])
    func reset()
}

protocol TrackableTestClassProxy : TrackableTestClassType {
    var trackableTestClass: TrackableTestClass { get }
}

extension TrackableTestClassProxy {
    var trackerLog:[TrackerLogEntry] {
        return trackableTestClass.trackerLog
    }
    var trackerSummary:[String:[TrackerSummaryEntry]] {
        return trackableTestClass.trackerSummary
    }
    var trackerKeys:Set<String> {
        return trackableTestClass.trackerKeys
    }
    var trackerKeyValues:[String:[[String]]] {
        return trackableTestClass.trackerKeyValues
    }
    var trackerKeyCounts:[String:Int] {
        return trackableTestClass.trackerKeyCounts
    }
    var trackerCount:Int {
        return trackableTestClass.trackerCount
    }

    func track(key:String) {
        trackableTestClass.track(key)
    }

    func track(key:String, _ values:[String]) {
        trackableTestClass.track(key, values)
    }

    func reset() {
        trackableTestClass.reset()
    }
}

class TrackableTestClass : TrackableTestClassType {
    var trackerLog:[TrackerLogEntry] = []
    var trackerSummary:[String:[TrackerSummaryEntry]] = [:]
    var trackerKeys:Set<String> {
        return Set(trackerSummary.keys)
    }
    var trackerKeyValues:[String:[[String]]] {
        var result:[String:[[String]]] = [:]
        for (key,entries) in trackerSummary {
            var values:[[String]] = result[key] ?? []
            let entryValues = entries.map { $0.values }
            values += entryValues
            result[key] = values
        }
        return result
    }
    var trackerKeyCounts:[String:Int] {
        var result:[String:Int] = [:]
        for (key,entries) in trackerSummary {
            let keyCount = result[key] ?? 0
            result[key] = keyCount + entries.count
        }
        return result
    }
    var trackerCount:Int {
        return trackerSummary.values.reduce(0,combine:{$0 + $1.count})
    }

    func track(key:String) {
        track(key, [])
    }

    func track(key:String, _ values:[String]) {
        let timestamp = NSDate()
        let trackerLogEntry = TrackerLogEntry(key: key, values: values, timestamp: timestamp)
        let trackerSummaryEntry = TrackerSummaryEntry(values: values, timestamp: timestamp)

        var entries:[TrackerSummaryEntry] = trackerSummary[key] ?? []
        entries.append(trackerSummaryEntry)
        trackerSummary[key] = entries
        trackerLog.append(trackerLogEntry)
    }

    func reset() {
        trackerLog = []
        trackerSummary = [:]
    }
}

