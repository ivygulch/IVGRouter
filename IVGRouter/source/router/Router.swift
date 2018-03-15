//
//  Router.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 3/22/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public enum RoutingErrors: Error {
    case invalidRouteSequence
    case noHistory
    case segmentNotRegistered(Identifier)
    case presenterNotRegistered(Identifier)
    case sequenceEndedWithoutViewController
    case invalidRouteSegment(Identifier, String)
    case noViewControllerProduced(Identifier)
    case invalidConfiguration(String)
    case couldNotReversePresentation(Identifier)
    case cannotPresent(Identifier,String)
}

public enum RoutingResult {
    case success(UIViewController)
    case failure(Error)
}

public protocol RouteHistoryPreviousButtonProvider {
    var previousHistoryItemButton: UIButton? { get }
    func configurePreviousHistoryItem(forButton button: UIButton, routeHistoryItemTitle: String?) -> (() -> Void)?
}

public typealias RouterProvider = ((String,UIWindow?) -> RouterType)

public protocol RouterType {
    var window: UIWindow? { get }
    var routerContext: RouterContextType { get }
    var historySize: Int { get }

    func append(route source: [Any], completion: @escaping ((RoutingResult) -> Void))
    func execute(route source: [Any], completion: @escaping ((RoutingResult) -> Void))
    func pop(completion: @escaping ((RoutingResult) -> Void))

    func clearHistory()
    func previousRouteHistoryItem() -> RouteHistoryItemType?
    func goBack(completion: @escaping ((RoutingResult) -> Void))

    func viewControllers() -> [UIViewController]
}

public struct RouterConstants {
    public static let defaultTitle = "Previous Page"
    public static let defaultHistorySize: Int = 20
}

open class Router: RouterType {

    public init(window: UIWindow?, routerContext: RouterContextType, historySize: Int = RouterConstants.defaultHistorySize) {
        self.window = window
        self.routerContext = routerContext
        self.historySize = historySize
    }

    public func debugString(_ msg: String) -> String {
        var lines: [String] = []
        lines.append("Router(\(msg)).count=\(lastRecordedSegments.count)")
        for index in 0..<lastRecordedSegments.count {
            let recordedSegment = lastRecordedSegments[index]
            let segmentIdentifier = recordedSegment.segmentIdentifier
            let vc = recordedSegment.viewController
            var result = "[\(index)]"
            result += "=\(segmentIdentifier.name)"
            result += "," + String(describing: vc)
            if let p = vc?.parent {
                result += ",p=" + String(describing: p)
            }
            lines.append(result)
            if let children = vc?.childViewControllers, children.count > 1 {
                for childIndex in 0..<children.count {
                    let child = children[childIndex]
                    lines.append("   child\(childIndex)=\(String(describing: child))")
                }
            }
        }

        return lines.joined(separator: "\n")
    }

    public func debug(_ msg: String) {
        print("\(debugString(msg))")
    }

    public let window: UIWindow?
    public let routerContext: RouterContextType
    public let historySize: Int

    public func viewControllers() -> [UIViewController] {
        return lastRecordedSegments.flatMap { $0.viewController }
    }

    // MARK: public routing methods

    public func append(route source: [Any], completion: @escaping ((RoutingResult) -> Void)) {
        let wrappedCompletion: ((RoutingResult) -> Void) = { [weak self] routingResult in
            if case .success(let viewController) = routingResult {
                _ = self?.recordHistory(title: viewController.title)
                self?.configureHistoryButtons(presented: viewController)
            }
            completion(routingResult)
        }
        execute(routeSequence: source, append: true, completion: wrappedCompletion)
    }

    public func pop(completion: @escaping ((RoutingResult) -> Void)) {
        let wrappedCompletion: ((RoutingResult) -> Void) = { [weak self] routingResult in
            if case .success(let viewController) = routingResult {
                _ = self?.recordHistory(title: viewController.title)
                self?.configureHistoryButtons(presented: viewController)
            }
            completion(routingResult)
        }

        popInternal(completion: wrappedCompletion)
    }

    public func clearHistory() {
        historyForIdentifiers = nil
    }

    public func previousRouteHistoryItem() -> RouteHistoryItemType? {
        return historyForIdentifiers?.previousRouteHistoryItem
    }

    public func goBack(completion: @escaping ((RoutingResult) -> Void)) {
        let history = historyForIdentifier()
        guard let previousRouteHistoryItem = history.previousRouteHistoryItem else {
            completion(.failure(RoutingErrors.noHistory))
            return
        }

        let wrappedCompletion: ((RoutingResult) -> Void) = {
            routingResult in
            if case .success = routingResult {
                history.moveBackward()
            }
            completion(routingResult)
        }
        execute(routeSequence: previousRouteHistoryItem.routeSequence, append: false, completion: wrappedCompletion)
    }

    public func execute(route source: [Any], completion: @escaping ((RoutingResult) -> Void)) {
        let wrappedCompletion: ((RoutingResult) -> Void) = { [weak self] routingResult in
            if case .success(let viewController) = routingResult {
                _ = self?.recordHistory(title: viewController.title)
                self?.configureHistoryButtons(presented: viewController)
            }
            completion(routingResult)
        }
        execute(routeSequence: source, append: false, completion: wrappedCompletion)
    }

    // MARK: UIButton configuration

    fileprivate var previousButtonCompletions: [UIButton: (() -> Void)] = [: ]

    @objc fileprivate func previousButtonAction(_ button: UIButton) {
        let buttonCompletion = previousButtonCompletions[button]
        goBack() { _ in
            buttonCompletion?()
        }
    }

    fileprivate func configure(previousButton button: UIButton, tapCompletion: (() -> Void)?) {
        let selector = #selector(Router.previousButtonAction(_: ))
        if previousRouteHistoryItem() != nil {
            button.isHidden = false
            previousButtonCompletions[button] = tapCompletion
            button.addTarget(self, action: selector, for: .touchUpInside)
        } else {
            button.isHidden = true
            previousButtonCompletions[button] = nil
            button.removeTarget(self, action: selector, for: .touchUpInside)
            button.setTitle(nil, for: .normal)
        }
    }

    fileprivate func configureHistoryButtons(presented: Any) {
        if let previousButtonProvider = presented as? RouteHistoryPreviousButtonProvider {
            if let previousButton = previousButtonProvider.previousHistoryItemButton {
                let routeHistoryItem = previousRouteHistoryItem()
                let tapCompletion = previousButtonProvider.configurePreviousHistoryItem(forButton: previousButton, routeHistoryItemTitle: routeHistoryItem?.title)
                configure(previousButton: previousButton, tapCompletion: tapCompletion)
            }
        }
    }
    
    

    // MARK: private routing methods

    fileprivate func popInternal(completion: @escaping ((RoutingResult) -> Void)) {
        guard lastRecordedSegments.count > 0 else {
            completion(.failure(RoutingErrors.invalidRouteSequence))
            return
        }

        var updatedRecordedSegments = lastRecordedSegments
        let lastRecordedSegment = updatedRecordedSegments.removeLast()
        lastRecordedSegments = updatedRecordedSegments

        let lastSegmentIdentifier = lastRecordedSegment.segmentIdentifier
        if let lastPresenterIdentifier = routerContext.routeSegments[lastSegmentIdentifier]?.presenterIdentifier,
            let reversibleRouteSegmentPresenter = routerContext.presenters[lastPresenterIdentifier] as? ReversibleRouteSegmentPresenterType,
            let lastViewController = lastRecordedSegment.viewController,
            let lastParentViewController = lastViewController.parent ?? lastViewController.presentingViewController {

            let presentationBlock = {
                reversibleRouteSegmentPresenter.reverse(viewController: lastViewController) { presenterResult in

                    switch presenterResult {
                    case .success(_): 
                        completion(.success(lastParentViewController))
                    case .failure(_): 
                        completion(.failure(RoutingErrors.couldNotReversePresentation(lastSegmentIdentifier)))
                    }
                }
            }
            if Thread.isMainThread {
                presentationBlock()
            } else {
                DispatchQueue.main.async(execute: presentationBlock)
            }

        } else if let lastViewController = lastRecordedSegment.viewController,
            let navigationController = lastViewController.navigationController {
            navigationController.pop(animated: true, completion: {
                completion(.success(navigationController))
            })

        } else {
            let previousSequence: [Any] = updatedRecordedSegments.map { $0.segmentIdentifier }
            execute(routeSequence: previousSequence, append: false, completion: completion)
        }
    }

    fileprivate func pop(recordedSegments recordedSegmentsToPop: [RecordedSegment], sequenceCompletion: @escaping ((RoutingResult) -> Void), popCompletion: @escaping (() -> Void)) {
        guard recordedSegmentsToPop.count > 0 else {
            popCompletion()
            return // nothing to do here
        }

        popUsing(recordedSegments: recordedSegmentsToPop, sequenceCompletion: sequenceCompletion, popCompletion: popCompletion)
    }

    fileprivate func popUsing(recordedSegments recordedSegmentsToPop: [RecordedSegment], sequenceCompletion: @escaping ((RoutingResult) -> Void), popCompletion: @escaping (() -> Void)) {
        guard recordedSegmentsToPop.count > 0 else {
            // all finished popping
            popCompletion()
            return
        }
        var newRecordedSegmentsToPop = recordedSegmentsToPop
        let recordedSegment = newRecordedSegmentsToPop.removeFirst()

        popInternal() { [weak self] routingResult in
            switch routingResult {
            case .success(_): 
                self?.popUsing(recordedSegments: newRecordedSegmentsToPop, sequenceCompletion: sequenceCompletion, popCompletion: popCompletion)
            case .failure(_): 
                // if popping this segment failed, do not attempt to pop the next one, just fail
                sequenceCompletion(.failure(RoutingErrors.couldNotReversePresentation(recordedSegment.segmentIdentifier)))
                popCompletion()
            }
        }
    }

    fileprivate func execute(routeSequence source: [Any], append: Bool, completion: @escaping ((RoutingResult) -> Void)) {
        execute(routeSequence: RouteSequence(source: source), append: append, completion: completion)
    }

    fileprivate func execute(routeSequence: RouteSequence, append: Bool, completion: @escaping ((RoutingResult) -> Void)) {
        // routeSequenceTracker is the requested route
        // routeSegmentFIFOPipe is the actual route segments that were successful completed
        guard let routeSequenceTracker = RouteSequenceTracker(routeSequence: routeSequence) else {
            completion(.failure(RoutingErrors.invalidRouteSequence))
            return
        }
        let routeSegmentFIFOPipe = RouteSegmentFIFOPipe(oldRecordedSegments: lastRecordedSegments, appending: append)
        performNextRouteSequenceItem(
            routeSequenceTracker,
            routeSegmentFIFOPipe: routeSegmentFIFOPipe,
            sequenceCompletion: { [weak self] routingResult in
                self?.lastRecordedSegments = routeSegmentFIFOPipe.newRecordedSegments
                completion(routingResult)
            }
        )
    }


    fileprivate func performNextRouteSequenceItem(_ routeSequenceTracker: RouteSequenceTracker, routeSegmentFIFOPipe: RouteSegmentFIFOPipe, sequenceCompletion: @escaping ((RoutingResult) -> Void)) {
        guard let routeSequenceItem = routeSequenceTracker.next() else {
            pop(recordedSegments: routeSegmentFIFOPipe.oldSegmentsToPop,
                                sequenceCompletion: sequenceCompletion,
                                popCompletion: {
                                    // we made it through all the items, so declare success
                                    if let finalViewController = routeSegmentFIFOPipe.peekNewRecordedSegment?.viewController {
                                        sequenceCompletion(.success(finalViewController))
                                    } else {
                                        sequenceCompletion(.failure(RoutingErrors.sequenceEndedWithoutViewController))
                                    }
            })
            return
        }

        let segmentIdentifier = routeSequenceItem.segmentIdentifier
        guard let routeSegment = routerContext.routeSegments[segmentIdentifier] else {
            sequenceCompletion(.failure(RoutingErrors.segmentNotRegistered(segmentIdentifier)))
            return
        }

        let onSuccessfulPresentation: ((RouteSegmentType,UIViewController) -> Void) = { [weak self] (routeSegment, presentedViewController) in

//            print("DBG: onSuccessfulPresentation=\(routeSegment), \(presentedViewController)")

            if routeSegment.shouldBeRecorded {
                routeSegmentFIFOPipe.pushNewSegmentIdentifier(routeSegment.segmentIdentifier, data: routeSequenceItem.data, viewController: presentedViewController)
            }

            let wrappedSC: ((RoutingResult) -> Void) = { routingResult in
                sequenceCompletion(routingResult)
            }

            self?.performNextRouteSequenceItem(
                routeSequenceTracker,
                routeSegmentFIFOPipe: routeSegmentFIFOPipe,
                sequenceCompletion: wrappedSC//sequenceCompletion
            )
        }

        if let oldRecordedSegment = routeSegmentFIFOPipe.popOldRecordedSegment() {
            if oldRecordedSegment.segmentIdentifier == segmentIdentifier {
                if let oldViewController = oldRecordedSegment.viewController {
                    onSuccessfulPresentation(routeSegment, oldViewController)
                    return
                }
            } else {
                pop(recordedSegments: routeSegmentFIFOPipe.oldSegmentsToPop,
                    sequenceCompletion: sequenceCompletion,
                    popCompletion: { [weak self] in
                        self?.finish(routeSequenceItem: routeSequenceItem, routeSegment: routeSegment, routeSegmentFIFOPipe: routeSegmentFIFOPipe, onSuccessfulPresentation: onSuccessfulPresentation, sequenceCompletion: sequenceCompletion)
                })
            }
        } else {
            finish(routeSequenceItem: routeSequenceItem, routeSegment: routeSegment, routeSegmentFIFOPipe: routeSegmentFIFOPipe, onSuccessfulPresentation: onSuccessfulPresentation, sequenceCompletion: sequenceCompletion)
        }
    }

    fileprivate func finish(routeSequenceItem: RouteSequenceItem, routeSegment: RouteSegmentType, routeSegmentFIFOPipe: RouteSegmentFIFOPipe, onSuccessfulPresentation: @escaping ((RouteSegmentType,UIViewController) -> Void), sequenceCompletion: @escaping ((RoutingResult) -> Void)) {
        let presenterIdentifier = routeSegment.presenterIdentifier
        guard let presenter = routerContext.presenters[presenterIdentifier] else {
            sequenceCompletion(.failure(RoutingErrors.presenterNotRegistered(presenterIdentifier)))
            return
        }

        let currentSegment = routeSegmentFIFOPipe.peekNewRecordedSegment
        let currentViewController = currentSegment?.viewController
        if handled(visualPresenter: presenter, parent: currentViewController, routeSegment: routeSegment, routeSequenceData: routeSequenceItem.data, routeSequenceOptions: routeSequenceItem.options, sequenceCompletion: sequenceCompletion, presentationCompletion: onSuccessfulPresentation) {
            return
        }

        sequenceCompletion(.failure(RoutingErrors.invalidConfiguration("Presenter(\(type(of: presenter))) not handled for segment(\(type(of: routeSegment)))")))
    }

    fileprivate func recordHistory(title: String?) -> RouteHistoryItem? {
        let routeSequence = RouteSequence(source: lastRecordedSegments.map { RouteSequenceItem(segmentIdentifier: $0.segmentIdentifier, data: $0.data) })
        let history = historyForIdentifier()
        let routeHistoryItem = RouteHistoryItem(routeSequence: routeSequence, title: title)
        history.recordRouteHistoryItem(routeHistoryItem, ignoreDuplicates: true)
        return routeHistoryItem
    }

    /// return true if this step was handled, otherwise false so another method can be called
    fileprivate func handled(visualPresenter presenter: RouteSegmentPresenterType, parent: UIViewController?, routeSegment: RouteSegmentType, routeSequenceData: Any?, routeSequenceOptions: RouteSequenceOptions, sequenceCompletion: @escaping ((RoutingResult) -> Void), presentationCompletion: @escaping ((RouteSegmentType, UIViewController) -> Void)) -> Bool {
        guard let visualPresenter = presenter as? VisualRouteSegmentPresenterType else {
            return false // this is not the presenter you are looking for, we did not handle it
        }
        guard let visualRouteSegment = routeSegment as? VisualRouteSegmentType else {
            sequenceCompletion(.failure(RoutingErrors.invalidRouteSegment(routeSegment.segmentIdentifier, "expected VisualRouteSegmentType")))
            return true // we handled it by failing the sequence
        }
        let presentingViewController = parent?.actingPresentingController
        let presentationBlock = {
            guard let viewController = visualRouteSegment.viewController() else {
                sequenceCompletion(.failure(RoutingErrors.noViewControllerProduced(routeSegment.segmentIdentifier)))
                return // we handled it by failing the sequence
            }

            visualRouteSegment.set(data: routeSequenceData, withRouter: self, on: viewController, from: presentingViewController)
            visualPresenter.present(viewController: viewController, from: presentingViewController, options: routeSequenceOptions, window: self.window, completion: {
                presenterResult in

                switch presenterResult {
                case .success(_): 
                    presentationCompletion(visualRouteSegment, viewController)
                    case .failure(let error): 
                    sequenceCompletion(.failure(error))
                }
                
            })
        }
        if Thread.isMainThread {
            presentationBlock()
        } else {
            DispatchQueue.main.async(execute: presentationBlock)
        }

        return true // we handled it by presenting the view controller
    }

    fileprivate func historyForIdentifier() -> RouterHistoryType {
        if let existingHistory = historyForIdentifiers {
            return existingHistory
        }
        let result = RouterHistory(historySize: historySize)
        historyForIdentifiers = result
        return result
    }

    fileprivate func debugDefaultRouteBranch(_ msg: String) {
        historyForIdentifiers?.debug(msg)
    }

    fileprivate func debugFullDefaultRouteBranch(_ msg: String) {
        historyForIdentifiers?.debugFull(msg)
    }

    // MARK: private variables

    fileprivate var historyForIdentifiers: RouterHistoryType?
    fileprivate var lastRecordedSegments: [RecordedSegment] = []
    fileprivate var registeredViewControllers: [UIViewController: Identifier] = [: ]

}

private extension Collection {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index]: nil
    }
}

private struct RecordedSegment: Equatable {
    let segmentIdentifier: Identifier
    let data: RouteSegmentDataType?
    let viewController: UIViewController?
}

private func ==(lhs: RecordedSegment, rhs: RecordedSegment) -> Bool {
    return lhs.segmentIdentifier == rhs.segmentIdentifier
        && lhs.viewController == rhs.viewController
}

private class RouteSegmentFIFOPipe {

    init(oldRecordedSegments: [RecordedSegment], appending: Bool) {
        self.oldRecordedSegments = oldRecordedSegments
        self.newRecordedSegments = appending ? oldRecordedSegments: []
    }

    func popOldRecordedSegment() -> RecordedSegment? {
        currentIndexIntoOld += 1
        return currentIndexIntoOld < oldRecordedSegments.count ? oldRecordedSegments[currentIndexIntoOld]: nil
    }

    var peekOldRecordedSegment: RecordedSegment? {
        return (currentIndexIntoOld >= 0) && (currentIndexIntoOld < oldRecordedSegments.count) ? oldRecordedSegments[currentIndexIntoOld]: nil
    }

    var routeChanged: Bool {
        if oldRecordedSegments.count < newRecordedSegments.count {
            return true
        }
        let oldSubset = Array<RecordedSegment>(oldRecordedSegments.prefix(newRecordedSegments.count))
        return oldSubset != newRecordedSegments
    }

    var oldSegmentsToPop: [RecordedSegment] {
        if routeChanged {
            return []
        }
        let remainingOldSegmentsCount = oldRecordedSegments.count - newRecordedSegments.count
        guard remainingOldSegmentsCount > 0 else {
            return []
        }
        let remainingOldSegments = Array<RecordedSegment>(oldRecordedSegments.suffix(remainingOldSegmentsCount))
        return remainingOldSegments.reversed()
    }

    var peekNewRecordedSegment: RecordedSegment? {
        return newRecordedSegments.last
    }

    func pushNewSegmentIdentifier(_ segmentIdentifier: Identifier, data: RouteSegmentDataType?, viewController: UIViewController) {
        let recordedSegment = RecordedSegment(segmentIdentifier: segmentIdentifier, data: data, viewController: viewController)
        newRecordedSegments.append(recordedSegment)
    }

    fileprivate var currentIndexIntoOld = -1
    fileprivate var oldRecordedSegments: [RecordedSegment]
    fileprivate var newRecordedSegments: [RecordedSegment]
}

private class RouteSequenceTracker {

    init?(routeSequence: RouteSequence) {
        self.routeSequence = routeSequence
        if routeSequence.items.count == 0 {
            return nil
        }
    }

    var remainingItems: [RouteSequenceItem] {
        let remainingCount = routeSequence.items.count - currentIndex
        guard remainingCount > 0 else {
            return []
        }
        return Array<RouteSequenceItem>(routeSequence.items.suffix(remainingCount))
    }

    func next() -> RouteSequenceItem? {
        currentIndex += 1
        guard currentIndex < routeSequence.items.count else {
            return nil
        }
        return routeSequence.items[currentIndex]
    }
    
    let routeSequence: RouteSequence
    var currentIndex: Int = -1
}
