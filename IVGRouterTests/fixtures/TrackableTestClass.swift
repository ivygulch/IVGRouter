//
//  TrackableTestClass.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 3/19/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation
//import IVGFoundation

struct TrackerLogEntry {
    let key: String
    let values: [String]
    let timestamp: Date
}

struct TrackerSummaryEntry {
    let values: [String]
    let timestamp: Date
}


protocol TrackableTestClassType {
    var trackerLog: [TrackerLogEntry] { get }
    var trackerSummary: [String: [TrackerSummaryEntry]] { get }
    var trackerKeys: Set<String> { get }
    var trackerKeyValues: [String: [[String]]] { get }
    var trackerKeyCounts: [String: Int] { get }
    var trackerCount: Int { get }

    func track(_ key: String)
    func track<T>(_ key: String, andReturn: T) -> T
    func track(_ key: String, _ values: [String])
    func track<T>(_ key: String, _ values: [String], andReturn: T) -> T
    func reset()

    func trackerKeyValuesDifferences(_ key: String, _ values: [[String]]) -> [String]
    func trackerKeyValuesDifferences(_ values: [String: [[String]]]) -> [String]
}

protocol TrackableTestClassProxy : TrackableTestClassType {
    var trackableTestClass: TrackableTestClass { get }
}

extension TrackableTestClassProxy {
    var trackerLog: [TrackerLogEntry] {
        return trackableTestClass.trackerLog
    }
    var trackerSummary: [String: [TrackerSummaryEntry]] {
        return trackableTestClass.trackerSummary
    }
    var trackerKeys: Set<String> {
        return trackableTestClass.trackerKeys
    }
    var trackerKeyValues: [String: [[String]]] {
        return trackableTestClass.trackerKeyValues
    }
    var trackerKeyCounts: [String: Int] {
        return trackableTestClass.trackerKeyCounts
    }
    var trackerCount: Int {
        return trackableTestClass.trackerCount
    }

    func track(_ key: String) {
        trackableTestClass.track(key)
    }

    func track<T>(_ key: String, andReturn: T) -> T {
        return trackableTestClass.track(key, andReturn: andReturn)
    }

    func track(_ key: String, _ values: [String]) {
        trackableTestClass.track(key, values)
    }
    
    func track<T>(_ key: String, _ values: [String], andReturn: T) -> T {
        return trackableTestClass.track(key, values, andReturn: andReturn)
    }
    
    func reset() {
        trackableTestClass.reset()
    }

    func trackerKeyValuesDifferences(_ key: String, _ values: [[String]]) -> [String] {
        return trackableTestClass.trackerKeyValuesDifferences(key, values)
    }

    func trackerKeyValuesDifferences(_ values: [String: [[String]]]) -> [String] {
        return trackableTestClass.trackerKeyValuesDifferences(values)
    }
}

class TrackableTestClass : TrackableTestClassType {
    var trackerLog: [TrackerLogEntry] = []
    var trackerSummary: [String: [TrackerSummaryEntry]] = [: ]
    var trackerKeys: Set<String> {
        return Set(trackerSummary.keys)
    }
    var trackerKeyValues: [String: [[String]]] {
        var result: [String: [[String]]] = [: ]
        for (key,entries) in trackerSummary {
            var values: [[String]] = result[key] ?? []
            let entryValues = entries.map { $0.values }
            values += entryValues
            result[key] = values
        }
        return result
    }
    var trackerKeyCounts: [String: Int] {
        var result: [String: Int] = [: ]
        for (key,entries) in trackerSummary {
            let keyCount = result[key] ?? 0
            result[key] = keyCount + entries.count
        }
        return result
    }
    var trackerCount: Int {
        return trackerSummary.values.reduce(0,{$0 + $1.count})
    }

    func track(_ key: String) {
        track(key, [])
    }

    func track<T>(_ key: String, andReturn: T) -> T {
        track(key)
        return andReturn
    }

    func track(_ key: String, _ values: [String]) {
        let timestamp = Date()//Clock.sharedClock.currentDate
        let trackerLogEntry = TrackerLogEntry(key: key, values: values, timestamp: timestamp)
        let trackerSummaryEntry = TrackerSummaryEntry(values: values, timestamp: timestamp)

        var entries: [TrackerSummaryEntry] = trackerSummary[key] ?? []
        entries.append(trackerSummaryEntry)
        trackerSummary[key] = entries
        trackerLog.append(trackerLogEntry)
    }

    func track<T>(_ key: String, _ values: [String], andReturn: T) -> T {
        track(key, values)
        return andReturn
    }

    func reset() {
        trackerLog = []
        trackerSummary = [: ]
    }

    func trackerKeyValuesDifferences(_ key: String, _ values: [[String]]) -> [String] {
        return []
    }

    func trackerKeyValuesDifferences(_ values: [String: [[String]]]) -> [String] {
        return []
    }
}

