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
    case noHistory(Identifier)
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

public protocol RouterType {
    var window: UIWindow? { get }
    var routeSegments: [Identifier: RouteSegmentType] { get }
    var routeBranches: [Identifier: RouteBranchType] { get }
    var presenters: [Identifier: RouteSegmentPresenterType] { get }
    func registerPresenter(_ presenter: RouteSegmentPresenterType)
    func registerRouteSegment(_ routeSegment: RouteSegmentType)
    func registerRouteBranch(_ routeBranch: RouteBranchType)
    func appendRoute(_ source: [Any], completion:@escaping ((RoutingResult) -> Void))
    func appendRoute(_ source: [Any], routeBranch: RouteBranchType, completion:@escaping ((RoutingResult) -> Void))
    func executeRoute(_ source: [Any], completion:@escaping ((RoutingResult) -> Void))
    func executeRoute(_ source: [Any], routeBranch: RouteBranchType, completion:@escaping ((RoutingResult) -> Void))
    func popRoute(_ completion:@escaping ((RoutingResult) -> Void))
    func popRoute(_ routeBranch: RouteBranchType, completion:@escaping ((RoutingResult) -> Void))

    func clearHistory()
    func clearHistory(_ routeBranch: RouteBranchType)
    func previousRouteHistoryItem() -> RouteHistoryItemType?
    func previousRouteHistoryItem(_ routeBranch: RouteBranchType) -> RouteHistoryItemType?
    func nextRouteHistoryItem() -> RouteHistoryItemType?
    func nextRouteHistoryItem(_ routeBranch: RouteBranchType) -> RouteHistoryItemType?
    func goBack(_ completion:@escaping ((RoutingResult) -> Void))
    func goBack(_ routeBranch: RouteBranchType, completion:@escaping ((RoutingResult) -> Void))
    func goForward(_ completion:@escaping ((RoutingResult) -> Void))
    func goForward(_ routeBranch: RouteBranchType, completion:@escaping ((RoutingResult) -> Void))
    func registerDefaultPresenters()

    func configurePreviousButton(_ button: UIButton, titleProducer:((String?) -> String)?, completion:((Void) -> Void)?)
    func configureNextButton(_ button: UIButton, titleProducer:((String?) -> String)?, completion:((Void) -> Void)?)

    func viewControllersForRouteBranchIdentifier(_ branchIdentifier: Identifier) -> [UIViewController]
}

public class Router : RouterType {

    public init(window: UIWindow?) {
        self.window = window
        defaultRouteBranch = RouteBranch(branchIdentifier: Identifier(name: UUID().uuidString), routeSequence: RouteSequence(source: []))
        registerRouteBranch(defaultRouteBranch)
    }

    public func debugString(_ msg: String) -> String {
        var lines: [String] = []
        lines.append("Router(\(msg)), branch.count=\(branchLastRecordedSegments.count)")
        for (branchID, lastRecordedSegments) in branchLastRecordedSegments {
            lines.append("branch[\(branchID)].count=\(lastRecordedSegments.count)")
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
        }
        
        return lines.joined(separator: "\n")
    }

    public func debug(_ msg: String) {
        print("\(debugString(msg))")
    }

    public fileprivate(set) var routeSegments: [Identifier: RouteSegmentType] = [:]
    public fileprivate(set) var routeBranches: [Identifier: RouteBranchType] = [:]
    public fileprivate(set) var presenters: [Identifier: RouteSegmentPresenterType] = [:]

    public let window: UIWindow?
    public let defaultRouteBranch: RouteBranchType

    public func viewControllersForRouteBranchIdentifier(_ routeBranchIdentifier: Identifier) -> [UIViewController] {
        if let lastRecordedSegments = branchLastRecordedSegments[routeBranchIdentifier] {
            return lastRecordedSegments.flatMap { $0.viewController }
        } else {
            return []
        }
    }

    public func registerPresenter(_ presenter:RouteSegmentPresenterType) {
        presenters[presenter.presenterIdentifier] = presenter
    }

    public func registerRouteSegment(_ routeSegment:RouteSegmentType) {
        routeSegments[routeSegment.segmentIdentifier] = routeSegment
    }

    public func registerRouteBranch(_ routeBranch: RouteBranchType) {
        routeBranches[routeBranch.branchIdentifier] = routeBranch
    }

    public func registerDefaultPresenters() {
        registerPresenter(RootRouteSegmentPresenter())
        registerPresenter(BranchRouteSegmentPresenter())
        registerPresenter(PushRouteSegmentPresenter())
        registerPresenter(SetRouteSegmentPresenter())
        registerPresenter(WrappingRouteSegmentPresenter(wrappingRouteSegmentAnimator: SlidingWrappingRouteSegmentAnimator()))
    }

    // MARK: public routing methods

    public func appendRoute(_ source: [Any], completion:@escaping ((RoutingResult) -> Void)) {
        appendRoute(source, routeBranch: defaultRouteBranch, completion: completion)
    }

    public func appendRoute(_ source: [Any], routeBranch: RouteBranchType, completion:@escaping ((RoutingResult) -> Void)) {
        let routeBranchIdentifier = routeBranch.branchIdentifier
        let wrappedCompletion: ((RoutingResult) -> Void) = {
            [weak self] routingResult in
            if case .success(let viewController) = routingResult {
                self?.recordHistory(routeBranchIdentifier, title: viewController.title)
            }
            completion(routingResult)
        }
        executeRouteSequence(source, append: true, routeBranch: routeBranch, completion: wrappedCompletion)
    }

    public func popRoute(_ completion:@escaping ((RoutingResult) -> Void)) {
        popRoute(defaultRouteBranch, completion: completion)
    }

    public func popRoute(_ routeBranch: RouteBranchType, completion:@escaping ((RoutingResult) -> Void)) {
        let routeBranchIdentifier = routeBranch.branchIdentifier
        let wrappedCompletion: ((RoutingResult) -> Void) = {
            [weak self] routingResult in
            if case .success(let viewController) = routingResult {
                self?.recordHistory(routeBranchIdentifier, title: viewController.title)
            }
            completion(routingResult)
        }

        popRouteInternal(routeBranch, completion: wrappedCompletion)
    }

    public func clearHistory() {
        clearHistory(defaultRouteBranch)
    }

    public func clearHistory(_ routeBranch: RouteBranchType) {
        historyForIdentifiers[routeBranch.branchIdentifier] = nil
    }

    public func previousRouteHistoryItem() -> RouteHistoryItemType? {
        return previousRouteHistoryItem(defaultRouteBranch)
    }

    public func previousRouteHistoryItem(_ routeBranch: RouteBranchType) -> RouteHistoryItemType? {
        return historyForIdentifiers[routeBranch.branchIdentifier]?.previousRouteHistoryItem
    }

    public func nextRouteHistoryItem() -> RouteHistoryItemType? {
        return nextRouteHistoryItem(defaultRouteBranch)
    }

    public func nextRouteHistoryItem(_ routeBranch: RouteBranchType) -> RouteHistoryItemType? {
        return historyForIdentifiers[routeBranch.branchIdentifier]?.nextRouteHistoryItem
    }

    public func goBack(_ completion:@escaping ((RoutingResult) -> Void)) {
        goBack(defaultRouteBranch, completion: completion)
    }

    public func goBack(_ routeBranch: RouteBranchType, completion:@escaping ((RoutingResult) -> Void)) {
        let branchIdentifier = routeBranch.branchIdentifier
        let history = historyForIdentifier(branchIdentifier)
        guard let previousRouteHistoryItem = history.previousRouteHistoryItem else {
            completion(.failure(RoutingErrors.noHistory(branchIdentifier)))
            return
        }

        let wrappedCompletion: ((RoutingResult) -> Void) = {
            routingResult in
            if case .success = routingResult {
                history.moveBackward()
            }
            completion(routingResult)
        }
        executeRouteSequence(previousRouteHistoryItem.routeSequence, append: false, routeBranch: routeBranch, completion: wrappedCompletion)
    }

    public func goForward(_ completion:@escaping ((RoutingResult) -> Void)) {
        goForward(defaultRouteBranch, completion: completion)
    }

    public func goForward(_ routeBranch: RouteBranchType, completion:@escaping ((RoutingResult) -> Void)) {
        let branchIdentifier = routeBranch.branchIdentifier
        let history = historyForIdentifier(branchIdentifier)
        guard let nextRouteHistoryItem = history.nextRouteHistoryItem else {
            completion(.failure(RoutingErrors.noHistory(branchIdentifier)))
            return
        }

        let wrappedCompletion: ((RoutingResult) -> Void) = {
            routingResult in
            if case .success = routingResult {
                history.moveForward()
            }
            completion(routingResult)
        }
        executeRouteSequence(nextRouteHistoryItem.routeSequence, append: false, routeBranch: routeBranch, completion: wrappedCompletion)
    }
    
    public func executeRoute(_ source: [Any], completion:@escaping ((RoutingResult) -> Void)) {
        executeRoute(source, routeBranch: defaultRouteBranch, completion: completion)
    }

    public func executeRoute(_ source: [Any], routeBranch: RouteBranchType, completion:@escaping ((RoutingResult) -> Void)) {
        let routeBranchIdentifier = routeBranch.branchIdentifier
        let wrappedCompletion: ((RoutingResult) -> Void) = {
            [weak self] routingResult in
            if case .success(let viewController) = routingResult {
                self?.recordHistory(routeBranchIdentifier, title: viewController.title)
            }
            completion(routingResult)
            if let history = self?.historyForIdentifier(routeBranchIdentifier) as? RouterHistory {
                history.debugFull("after execute")
            }
        }
        if routeBranchIdentifier != defaultRouteBranch.branchIdentifier {
            // make sure the defaultBranch is set to the proper place for this branch
            let defaultSource = routeBranch.routeSequence.items.map {
                routeSequenceItem -> Any in
                return routeSequenceItem
            }
            executeRouteSequence(defaultSource, append: false, routeBranch: defaultRouteBranch) {
                [weak self] routeResult in
                switch routeResult {
                case .success:
                    // if we successfully switched to the correct spot on the default branch, append the rest
                    self?.executeRouteSequence(source, append: false, routeBranch: routeBranch, completion: wrappedCompletion)
                case .failure:
                    // we could not reset the default branch, so just give up
                    wrappedCompletion(routeResult)
                }
            }
        } else {
            executeRouteSequence(source, append: false, routeBranch: routeBranch, completion: wrappedCompletion)
        }
    }

    // MARK: UIButton configuration

    fileprivate var previousButtonCompletions: [UIButton: ((Void) -> Void)] = [:]
    fileprivate var nextButtonCompletions: [UIButton: ((Void) -> Void)] = [:]

    @objc fileprivate func previousButtonAction(_ button: UIButton) {
        let buttonCompletion = previousButtonCompletions[button]
        goBack() {
            _ in
            buttonCompletion?()
        }
    }

    @objc fileprivate func nextButtonAction(_ button: UIButton) {
        let buttonCompletion = nextButtonCompletions[button]
        goForward() {
            _ in
            buttonCompletion?()
        }
    }

    public func configurePreviousButton(_ button: UIButton, titleProducer:((String?) -> String)?, completion:((Void) -> Void)?) {
        let selector = #selector(Router.previousButtonAction(_:))
        if let historyItem = previousRouteHistoryItem() {
            let title = (titleProducer == nil) ? historyItem.title : titleProducer?(historyItem.title)
            button.setTitle(title, for:UIControlState())
            button.isHidden = false
            previousButtonCompletions[button] = completion
            button.addTarget(self, action:selector, for: .touchUpInside)
            print("DBG: PPB<\(Unmanaged.passUnretained(button).toOpaque())>.addTarget")
        } else {
            button.isHidden = true
            previousButtonCompletions[button] = nil
            button.removeTarget(self, action:selector, for:.touchUpInside)
            button.setTitle(nil, for:UIControlState())
            print("DBG: PPB<\(Unmanaged.passUnretained(button).toOpaque())>.removeTarget")
        }
    }

    public func configureNextButton(_ button: UIButton, titleProducer:((String?) -> String)?, completion:((Void) -> Void)?) {
        let selector = #selector(Router.nextButtonAction(_:))
        if let historyItem = nextRouteHistoryItem() {
            let title = (titleProducer == nil) ? historyItem.title : titleProducer?(historyItem.title)
            button.setTitle(title, for:UIControlState())
            button.isHidden = false
            nextButtonCompletions[button] = completion
            button.addTarget(self, action:selector, for: .touchUpInside)
        } else {
            button.isHidden = true
            nextButtonCompletions[button] = nil
            button.removeTarget(self, action:selector, for:.touchUpInside)
            button.setTitle(nil, for:UIControlState())
        }
    }

    // MARK: private routing methods

    fileprivate func popRouteInternal(_ completion:@escaping ((RoutingResult) -> Void)) {
        popRouteInternal(defaultRouteBranch, completion: completion)
    }

    fileprivate func popRouteInternal(_ routeBranch: RouteBranchType, completion:@escaping ((RoutingResult) -> Void)) {
        let routeBranchIdentifier = routeBranch.branchIdentifier
        guard let lastRecordedSegments = branchLastRecordedSegments[routeBranchIdentifier], lastRecordedSegments.count > 0 else {
            completion(.failure(RoutingErrors.invalidRouteSequence))
            return
        }

        var updatedRecordedSegments = lastRecordedSegments
        let lastRecordedSegment = updatedRecordedSegments.removeLast()
        branchLastRecordedSegments[routeBranchIdentifier] = updatedRecordedSegments

        let lastSegmentIdentifier = lastRecordedSegment.segmentIdentifier
        if let lastPresenterIdentifier = routeSegments[lastSegmentIdentifier]?.presenterIdentifier,
            let reversibleRouteSegmentPresenter = presenters[lastPresenterIdentifier] as? ReversibleRouteSegmentPresenterType,
            let lastViewController = lastRecordedSegment.viewController,
            let lastParentViewController = lastViewController.parent {

            let presentationBlock = {
                reversibleRouteSegmentPresenter.reversePresentation(lastViewController) {
                    presenterResult in
//                    [weak self] presenterResult in

                    switch presenterResult {
                    case .success(_):
                        completion(.success(lastParentViewController))
//                        self?.debug("popRoute reversible")
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
            navigationController.popViewControllerAnimated(true, completion: {
//                [weak self] in
                completion(.success(navigationController))
//                self?.debug("popRoute navigationController")
            })

        } else {
            let previousSequence: [Any] = updatedRecordedSegments.map { $0.segmentIdentifier }
            executeRouteSequence(previousSequence, append: false, routeBranch: defaultRouteBranch, completion: completion)
        }
    }

    fileprivate func popRecordedSegments(_ recordedSegmentsToPop: [RecordedSegment], sequenceCompletion:@escaping ((RoutingResult) -> Void), popCompletion:@escaping ((Void) -> Void)) {
        guard recordedSegmentsToPop.count > 0 else {
            popCompletion()
            return // nothing to do here
        }

        popRouteUsingRouteSegmentsToPop(recordedSegmentsToPop, sequenceCompletion: sequenceCompletion, popCompletion: popCompletion)
    }

    fileprivate func popRouteUsingRouteSegmentsToPop(_ recordedSegmentsToPop: [RecordedSegment], sequenceCompletion:@escaping ((RoutingResult) -> Void), popCompletion:@escaping ((Void) -> Void)) {
        guard recordedSegmentsToPop.count > 0 else {
            // all finished popping
            popCompletion()
            return
        }
        var newRecordedSegmentsToPop = recordedSegmentsToPop
        let recordedSegment = newRecordedSegmentsToPop.removeFirst()

        popRouteInternal() {
            [weak self] routingResult in
            switch routingResult {
            case .success(_):
                self?.popRouteUsingRouteSegmentsToPop(newRecordedSegmentsToPop, sequenceCompletion: sequenceCompletion, popCompletion: popCompletion)
            case .failure(_):
                // if popping this segment failed, do not attempt to pop the next one, just fail
                sequenceCompletion(.failure(RoutingErrors.couldNotReversePresentation(recordedSegment.segmentIdentifier)))
                popCompletion()
            }
        }
    }

    fileprivate func executeRouteSequence(_ source: [Any], append: Bool, routeBranch: RouteBranchType, completion:@escaping ((RoutingResult) -> Void)) {
        executeRouteSequence(RouteSequence(source: source), append: append, routeBranch: routeBranch, completion: completion)
    }

    fileprivate func executeRouteSequence(_ routeSequence: RouteSequence, append: Bool, routeBranch: RouteBranchType, completion:@escaping ((RoutingResult) -> Void)) {
        // routeSequenceTracker is the requested route
        // routeSegmentFIFOPipe is the actual route segments that were successful completed
        let routeBranchIdentifier = routeBranch.branchIdentifier
        let lastRecordedSegments = branchLastRecordedSegments[routeBranchIdentifier] ?? []
        guard let routeSequenceTracker = RouteSequenceTracker(routeSequence: routeSequence) else {
            completion(.failure(RoutingErrors.invalidRouteSequence))
            return
        }
        let routeSegmentFIFOPipe = RouteSegmentFIFOPipe(oldRecordedSegments: lastRecordedSegments, appending: append)
        performNextRouteSequenceItem(
            routeSequenceTracker,
            routeSegmentFIFOPipe: routeSegmentFIFOPipe,
            routeBranchIdentifier: routeBranchIdentifier,
            sequenceCompletion: {
                [weak self] routingResult in
                self?.branchLastRecordedSegments[routeBranchIdentifier] = routeSegmentFIFOPipe.newRecordedSegments
//                self?.debug("sequenceCompletion")
                completion(routingResult)
            }
        )
    }


    fileprivate func performNextRouteSequenceItem(_ routeSequenceTracker: RouteSequenceTracker, routeSegmentFIFOPipe: RouteSegmentFIFOPipe,  routeBranchIdentifier: Identifier, sequenceCompletion:@escaping ((RoutingResult) -> Void)) {
        guard let routeSequenceItem = routeSequenceTracker.next() else {
            popRecordedSegments(routeSegmentFIFOPipe.oldSegmentsToPop,
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
        guard let routeSegment = routeSegments[segmentIdentifier] else {
            sequenceCompletion(.failure(RoutingErrors.segmentNotRegistered(segmentIdentifier)))
            return
        }

        let onSuccessfulPresentation: ((RouteSegmentType,UIViewController) -> Void) = {
            [weak self] (routeSegment, presentedViewController) in

            routeSegmentFIFOPipe.pushNewSegmentIdentifier(routeSegment.segmentIdentifier, viewController: presentedViewController)

            self?.performNextRouteSequenceItem(
                routeSequenceTracker,
                routeSegmentFIFOPipe: routeSegmentFIFOPipe,
                routeBranchIdentifier: routeBranchIdentifier,
                sequenceCompletion: sequenceCompletion
            )
        }

        if let oldRecordedSegment = routeSegmentFIFOPipe.popOldRecordedSegment() {
            if oldRecordedSegment.segmentIdentifier == segmentIdentifier {
                if let oldViewController = oldRecordedSegment.viewController {
                    onSuccessfulPresentation(routeSegment, oldViewController)
                    return
                }
            } else {
                popRecordedSegments(routeSegmentFIFOPipe.oldSegmentsToPop,
                                    sequenceCompletion: sequenceCompletion,
                                    popCompletion: {
                                        [weak self] in
                                        self?.finishRouteSequenceItem(routeSequenceItem, routeSegment: routeSegment, routeSegmentFIFOPipe: routeSegmentFIFOPipe, routeBranchIdentifier: routeBranchIdentifier, onSuccessfulPresentation: onSuccessfulPresentation, sequenceCompletion: sequenceCompletion)
                })
            }
        } else {
            finishRouteSequenceItem(routeSequenceItem, routeSegment: routeSegment, routeSegmentFIFOPipe: routeSegmentFIFOPipe, routeBranchIdentifier: routeBranchIdentifier, onSuccessfulPresentation: onSuccessfulPresentation, sequenceCompletion: sequenceCompletion)
        }
    }

    fileprivate func finishRouteSequenceItem(_ routeSequenceItem: RouteSequenceItem, routeSegment: RouteSegmentType, routeSegmentFIFOPipe: RouteSegmentFIFOPipe, routeBranchIdentifier: Identifier, onSuccessfulPresentation: @escaping ((RouteSegmentType,UIViewController) -> Void), sequenceCompletion:@escaping ((RoutingResult) -> Void)) {
        let presenterIdentifier = routeSegment.presenterIdentifier
        guard let presenter = presenters[presenterIdentifier] else {
            sequenceCompletion(.failure(RoutingErrors.presenterNotRegistered(presenterIdentifier)))
            return
        }

        let currentSegment = routeSegmentFIFOPipe.peekNewRecordedSegment
        let currentViewController = currentSegment?.viewController
        if handledVisualPresenter(presenter, parent: currentViewController, routeSegment: routeSegment, routeSequenceOptions: routeSequenceItem.options, sequenceCompletion: sequenceCompletion, presentationCompletion: onSuccessfulPresentation) {
            return
        }

        if handledBranchPresenter(presenter, parent: currentViewController, routeSegment: routeSegment, routeSequenceOptions: routeSequenceItem.options, sequenceCompletion: sequenceCompletion, presentationCompletion: onSuccessfulPresentation) {
            return
        }

        sequenceCompletion(.failure(RoutingErrors.invalidConfiguration("Presenter(\(type(of: presenter))) not handled for segment(\(type(of: routeSegment)))")))
    }

    fileprivate func recordHistory(_ routeBranchIdentifier: Identifier, title: String?) {
        guard let lastRecordedSegments = branchLastRecordedSegments[routeBranchIdentifier] else {
            return
        }
        let routeSequence = RouteSequence(source: lastRecordedSegments.map { $0.segmentIdentifier })
        let history = historyForIdentifier(routeBranchIdentifier)
//        print("DBG: recordHistory \(routeSequence)")
        history.recordRouteHistoryItem(RouteHistoryItem(routeSequence: routeSequence, title: title), ignoreDuplicates: true)
    }

    /// return true if this step was handled, otherwise false so another method can be called
    fileprivate func handledVisualPresenter(_ presenter: RouteSegmentPresenterType, parent: UIViewController?, routeSegment: RouteSegmentType, routeSequenceOptions: RouteSequenceOptions, sequenceCompletion:@escaping ((RoutingResult) -> Void), presentationCompletion: @escaping ((RouteSegmentType, UIViewController) -> Void)) -> Bool {
        guard let visualPresenter = presenter as? VisualRouteSegmentPresenterType else {
            return false // this is not the presenter you are looking for, we did not handle it
        }
        guard let visualRouteSegment = routeSegment as? VisualRouteSegmentType else {
            sequenceCompletion(.failure(RoutingErrors.invalidRouteSegment(routeSegment.segmentIdentifier, "expected VisualRouteSegmentType")))
            return true // we handled it by failing the sequence
        }
        guard let viewController = visualRouteSegment.viewController() else {
            sequenceCompletion(.failure(RoutingErrors.noViewControllerProduced(routeSegment.segmentIdentifier)))
            return true // we handled it by failing the sequence
        }

        let presentingViewController = parent?.actingPresentingController
        let presentationBlock = {
            visualPresenter.presentViewController(viewController, from: presentingViewController, options: routeSequenceOptions, window: self.window, completion: {
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

    /// return true if this step was handled, otherwise false so another method can be called
    fileprivate func handledBranchPresenter(_ presenter: RouteSegmentPresenterType, parent: UIViewController?, routeSegment: RouteSegmentType, routeSequenceOptions: RouteSequenceOptions, sequenceCompletion:@escaping ((RoutingResult) -> Void), presentationCompletion:@escaping ((RouteSegmentType,UIViewController) -> Void)) -> Bool {
        guard let branchPresenter = presenter as? BranchRouteSegmentPresenterType else {
            return false // this is not the presenter you are looking for, we did not handle it
        }
        guard let branchRouteSegment = routeSegment as? BranchRouteSegmentType else {
            sequenceCompletion(.failure(RoutingErrors.invalidRouteSegment(routeSegment.segmentIdentifier, "expected BranchRouteSegmentType")))
            return true // we handled it by failing the sequence
        }
        guard let trunkRouteController = parent as? TrunkRouteController else {
            sequenceCompletion(.failure(RoutingErrors.invalidRouteSegment(routeSegment.segmentIdentifier, "segment must be child segment of TrunkRouteController")))
            return true // we handled it by failing the sequence
        }

        branchPresenter.selectBranch(branchRouteSegment.segmentIdentifier, from: trunkRouteController, options: routeSequenceOptions, completion: {
            presenterResult in

            switch presenterResult {
            case .success(let selectedViewController):
                presentationCompletion(branchRouteSegment, selectedViewController)
            case .failure(let error):
                sequenceCompletion(.failure(error))
            }
        })
        return true
    }

    fileprivate func historyForIdentifier(_ identifier: Identifier) -> RouterHistoryType {
        if let existingHistory = historyForIdentifiers[identifier] {
            return existingHistory
        }
        let result = RouterHistory()
        historyForIdentifiers[identifier] = result
        return result
    }

    // MARK: private variables

    fileprivate var historyForIdentifiers:[Identifier:RouterHistoryType] = [:]
    fileprivate var branchLastRecordedSegments:[Identifier:[RecordedSegment]] = [:]
    fileprivate var registeredViewControllers:[UIViewController:Identifier] = [:]

}

private extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

private struct RecordedSegment: Equatable {
    let segmentIdentifier: Identifier

    let viewController: UIViewController?
}

private func ==(lhs: RecordedSegment, rhs: RecordedSegment) -> Bool {
    return lhs.segmentIdentifier == rhs.segmentIdentifier
        && lhs.viewController == rhs.viewController
}

private class RouteSegmentFIFOPipe {

    init(oldRecordedSegments: [RecordedSegment], appending: Bool) {
        self.oldRecordedSegments = oldRecordedSegments
        self.newRecordedSegments = appending ? oldRecordedSegments : []
    }

    func popOldRecordedSegment() -> RecordedSegment? {
        currentIndexIntoOld += 1
        return currentIndexIntoOld < oldRecordedSegments.count ? oldRecordedSegments[currentIndexIntoOld] : nil
    }

    var peekOldRecordedSegment: RecordedSegment? {
        return (currentIndexIntoOld >= 0) && (currentIndexIntoOld < oldRecordedSegments.count) ? oldRecordedSegments[currentIndexIntoOld] : nil
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

    func pushNewSegmentIdentifier(_ segmentIdentifier: Identifier, viewController: UIViewController) {
        let recordedSegment = RecordedSegment(segmentIdentifier: segmentIdentifier, viewController: viewController)
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
