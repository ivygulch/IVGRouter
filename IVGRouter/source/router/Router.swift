//
//  Router.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 3/22/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public enum RoutingErrors: ErrorType {
    case InvalidRouteSequence
    case NoHistory(Identifier)
    case SegmentNotRegistered(Identifier)
    case PresenterNotRegistered(Identifier)
    case SequenceEndedWithoutViewController
    case InvalidRouteSegment(Identifier, String)
    case NoViewControllerProduced(Identifier)
    case InvalidConfiguration(String)
    case CouldNotReversePresentation(Identifier)
    case CannotPresent(Identifier,String)
}

public enum RoutingResult {
    case Success(UIViewController)
    case Failure(ErrorType)
}

public protocol RouterType {
    var window: UIWindow? { get }
    var routeSegments: [Identifier: RouteSegmentType] { get }
    var routeBranches: [Identifier: RouteBranchType] { get }
    var presenters: [Identifier: RouteSegmentPresenterType] { get }
    func registerPresenter(presenter: RouteSegmentPresenterType)
    func registerRouteSegment(routeSegment: RouteSegmentType)
    func registerRouteBranch(routeBranch: RouteBranchType)
    func appendRoute(source: [Any], completion:(RoutingResult -> Void))
    func appendRoute(source: [Any], routeBranch: RouteBranchType, completion:(RoutingResult -> Void))
    func executeRoute(source: [Any], completion:(RoutingResult -> Void))
    func executeRoute(source: [Any], routeBranch: RouteBranchType, completion:(RoutingResult -> Void))
    func popRoute(completion:(RoutingResult -> Void))
    func popRoute(routeBranch: RouteBranchType, completion:(RoutingResult -> Void))

    func clearHistory()
    func clearHistory(routeBranch: RouteBranchType)
    func previousRouteHistoryItem() -> RouteHistoryItemType?
    func previousRouteHistoryItem(routeBranch: RouteBranchType) -> RouteHistoryItemType?
    func nextRouteHistoryItem() -> RouteHistoryItemType?
    func nextRouteHistoryItem(routeBranch: RouteBranchType) -> RouteHistoryItemType?
    func goBack(completion:(RoutingResult -> Void))
    func goBack(routeBranch: RouteBranchType, completion:(RoutingResult -> Void))
    func goForward(completion:(RoutingResult -> Void))
    func goForward(routeBranch: RouteBranchType, completion:(RoutingResult -> Void))
    func registerDefaultPresenters()

    func configurePreviousButton(button: UIButton, titleProducer:(String? -> String)?, completion:(Void -> Void)?)
    func configureNextButton(button: UIButton, titleProducer:(String? -> String)?, completion:(Void -> Void)?)

    func viewControllersForRouteBranchIdentifier(branchIdentifier: Identifier) -> [UIViewController]
}

public class Router : RouterType {

    public init(window: UIWindow?) {
        self.window = window
        defaultRouteBranch = RouteBranch(branchIdentifier: Identifier(name: NSUUID().UUIDString), routeSequence: RouteSequence(source: []))
        registerRouteBranch(defaultRouteBranch)
    }

    public func debugString(msg: String) -> String {
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
                result += "," + String(vc)
                if let p = vc?.parentViewController {
                    result += ",p=" + String(p)
                }
                lines.append(result)
                if let children = vc?.childViewControllers where children.count > 1 {
                    for childIndex in 0..<children.count {
                        let child = children[childIndex]
                        lines.append("   child\(childIndex)=\(String(child))")
                    }
                }
            }
        }
        
        return lines.joinWithSeparator("\n")
    }

    public func debug(msg: String) {
        print("\(debugString(msg))")
    }

    public private(set) var routeSegments: [Identifier: RouteSegmentType] = [:]
    public private(set) var routeBranches: [Identifier: RouteBranchType] = [:]
    public private(set) var presenters: [Identifier: RouteSegmentPresenterType] = [:]

    public let window: UIWindow?
    public let defaultRouteBranch: RouteBranchType

    public func viewControllersForRouteBranchIdentifier(routeBranchIdentifier: Identifier) -> [UIViewController] {
        if let lastRecordedSegments = branchLastRecordedSegments[routeBranchIdentifier] {
            return lastRecordedSegments.flatMap { $0.viewController }
        } else {
            return []
        }
    }

    public func registerPresenter(presenter:RouteSegmentPresenterType) {
        presenters[presenter.presenterIdentifier] = presenter
    }

    public func registerRouteSegment(routeSegment:RouteSegmentType) {
        routeSegments[routeSegment.segmentIdentifier] = routeSegment
    }

    public func registerRouteBranch(routeBranch: RouteBranchType) {
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

    public func appendRoute(source: [Any], completion:(RoutingResult -> Void)) {
        appendRoute(source, routeBranch: defaultRouteBranch, completion: completion)
    }

    public func appendRoute(source: [Any], routeBranch: RouteBranchType, completion:(RoutingResult -> Void)) {
        executeRouteSequence(source, append: true, routeBranch: routeBranch, completion: completion)
    }

    public func popRoute(completion:(RoutingResult -> Void)) {
        popRoute(defaultRouteBranch, completion: completion)
    }

    public func popRoute(routeBranch: RouteBranchType, completion:(RoutingResult -> Void)) {
        let routeBranchIdentifier = routeBranch.branchIdentifier
        let wrappedCompletion: (RoutingResult -> Void) = {
            [weak self] routingResult in
            if case .Success(let viewController) = routingResult {
                self?.recordHistory(routeBranchIdentifier, title: viewController.title)
            }
            completion(routingResult)
        }

        popRouteInternal(routeBranch, completion: wrappedCompletion)
    }

    public func clearHistory() {
        clearHistory(defaultRouteBranch)
    }

    public func clearHistory(routeBranch: RouteBranchType) {
        historyForIdentifiers[routeBranch.branchIdentifier] = nil
    }

    public func previousRouteHistoryItem() -> RouteHistoryItemType? {
        return previousRouteHistoryItem(defaultRouteBranch)
    }

    public func previousRouteHistoryItem(routeBranch: RouteBranchType) -> RouteHistoryItemType? {
        return historyForIdentifiers[routeBranch.branchIdentifier]?.previousRouteHistoryItem
    }

    public func nextRouteHistoryItem() -> RouteHistoryItemType? {
        return nextRouteHistoryItem(defaultRouteBranch)
    }

    public func nextRouteHistoryItem(routeBranch: RouteBranchType) -> RouteHistoryItemType? {
        return historyForIdentifiers[routeBranch.branchIdentifier]?.nextRouteHistoryItem
    }

    public func goBack(completion:(RoutingResult -> Void)) {
        goBack(defaultRouteBranch, completion: completion)
    }

    public func goBack(routeBranch: RouteBranchType, completion:(RoutingResult -> Void)) {
        let branchIdentifier = routeBranch.branchIdentifier
        let history = historyForIdentifier(branchIdentifier)
        guard let previousRouteHistoryItem = history.previousRouteHistoryItem else {
            completion(.Failure(RoutingErrors.NoHistory(branchIdentifier)))
            return
        }

        let wrappedCompletion: (RoutingResult -> Void) = {
            routingResult in
            if case .Success = routingResult {
                history.moveBackward()
            }
            completion(routingResult)
        }
        executeRouteSequence(previousRouteHistoryItem.routeSequence, append: false, routeBranch: routeBranch, completion: wrappedCompletion)
    }

    public func goForward(completion:(RoutingResult -> Void)) {
        goForward(defaultRouteBranch, completion: completion)
    }

    public func goForward(routeBranch: RouteBranchType, completion:(RoutingResult -> Void)) {
        let branchIdentifier = routeBranch.branchIdentifier
        let history = historyForIdentifier(branchIdentifier)
        guard let nextRouteHistoryItem = history.nextRouteHistoryItem else {
            completion(.Failure(RoutingErrors.NoHistory(branchIdentifier)))
            return
        }

        let wrappedCompletion: (RoutingResult -> Void) = {
            routingResult in
            if case .Success = routingResult {
                history.moveForward()
            }
            completion(routingResult)
        }
        executeRouteSequence(nextRouteHistoryItem.routeSequence, append: false, routeBranch: routeBranch, completion: wrappedCompletion)
    }
    
    public func executeRoute(source: [Any], completion:(RoutingResult -> Void)) {
        executeRoute(source, routeBranch: defaultRouteBranch, completion: completion)
    }

    public func executeRoute(source: [Any], routeBranch: RouteBranchType, completion:(RoutingResult -> Void)) {
        let routeBranchIdentifier = routeBranch.branchIdentifier
        let wrappedCompletion: (RoutingResult -> Void) = {
            [weak self] routingResult in
            if case .Success(let viewController) = routingResult {
                self?.recordHistory(routeBranchIdentifier, title: viewController.title)
            }
            completion(routingResult)
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
                case .Success:
                    // if we successfully switched to the correct spot on the default branch, append the rest
                    self?.executeRouteSequence(source, append: false, routeBranch: routeBranch, completion: wrappedCompletion)
                case .Failure:
                    // we could not reset the default branch, so just give up
                    wrappedCompletion(routeResult)
                }
            }
        } else {
            executeRouteSequence(source, append: false, routeBranch: routeBranch, completion: wrappedCompletion)
        }
    }

    // MARK: UIButton configuration

    private var previousButtonCompletions: [UIButton: (Void -> Void)] = [:]
    private var nextButtonCompletions: [UIButton: (Void -> Void)] = [:]

    @objc private func previousButtonAction(button: UIButton) {
        let buttonCompletion = previousButtonCompletions[button]
        goBack() {
            _ in
            buttonCompletion?()
        }
    }

    @objc private func nextButtonAction(button: UIButton) {
        let buttonCompletion = nextButtonCompletions[button]
        goForward() {
            _ in
            buttonCompletion?()
        }
    }

    public func configurePreviousButton(button: UIButton, titleProducer:(String? -> String)?, completion:(Void -> Void)?) {
        let selector = #selector(Router.previousButtonAction(_:))
        if let historyItem = previousRouteHistoryItem() {
            let title = (titleProducer == nil) ? historyItem.title : titleProducer?(historyItem.title)
            button.setTitle(title, forState:.Normal)
            button.hidden = false
            previousButtonCompletions[button] = completion
            button.addTarget(self, action:selector, forControlEvents: .TouchUpInside)
        } else {
            button.hidden = true
            previousButtonCompletions[button] = nil
            button.removeTarget(self, action:selector, forControlEvents:.TouchUpInside)
            button.setTitle(nil, forState:.Normal)
        }
    }

    public func configureNextButton(button: UIButton, titleProducer:(String? -> String)?, completion:(Void -> Void)?) {
        let selector = #selector(Router.nextButtonAction(_:))
        if let historyItem = nextRouteHistoryItem() {
            let title = (titleProducer == nil) ? historyItem.title : titleProducer?(historyItem.title)
            button.setTitle(title, forState:.Normal)
            button.hidden = false
            nextButtonCompletions[button] = completion
            button.addTarget(self, action:selector, forControlEvents: .TouchUpInside)
        } else {
            button.hidden = true
            nextButtonCompletions[button] = nil
            button.removeTarget(self, action:selector, forControlEvents:.TouchUpInside)
            button.setTitle(nil, forState:.Normal)
        }
    }

    // MARK: private routing methods

    private func popRouteInternal(completion:(RoutingResult -> Void)) {
        popRouteInternal(defaultRouteBranch, completion: completion)
    }

    private func popRouteInternal(routeBranch: RouteBranchType, completion:(RoutingResult -> Void)) {
        let routeBranchIdentifier = routeBranch.branchIdentifier
        guard let lastRecordedSegments = branchLastRecordedSegments[routeBranchIdentifier] where lastRecordedSegments.count > 0 else {
            completion(.Failure(RoutingErrors.InvalidRouteSequence))
            return
        }

        var updatedRecordedSegments = lastRecordedSegments
        let lastRecordedSegment = updatedRecordedSegments.removeLast()
        branchLastRecordedSegments[routeBranchIdentifier] = updatedRecordedSegments

        let lastSegmentIdentifier = lastRecordedSegment.segmentIdentifier
        if let lastPresenterIdentifier = routeSegments[lastSegmentIdentifier]?.presenterIdentifier,
            let reversibleRouteSegmentPresenter = presenters[lastPresenterIdentifier] as? ReversibleRouteSegmentPresenterType,
            let lastViewController = lastRecordedSegment.viewController,
            let lastParentViewController = lastViewController.parentViewController {

            let presentationBlock = {
                reversibleRouteSegmentPresenter.reversePresentation(lastViewController) {
                    [weak self] presenterResult in

                    switch presenterResult {
                    case .Success(_):
                        completion(.Success(lastParentViewController))
//                        self?.debug("popRoute reversible")
                    case .Failure(_):
                        completion(.Failure(RoutingErrors.CouldNotReversePresentation(lastSegmentIdentifier)))
                    }
                }
            }
            if NSThread.isMainThread() {
                presentationBlock()
            } else {
                dispatch_async(dispatch_get_main_queue(), presentationBlock)
            }

        } else if let lastViewController = lastRecordedSegment.viewController,
            let navigationController = lastViewController.navigationController {
            navigationController.popViewControllerAnimated(true, completion: {
                [weak self] in
                completion(.Success(navigationController))
//                self?.debug("popRoute navigationController")
            })

        } else {
            let previousSequence: [Any] = updatedRecordedSegments.map { $0.segmentIdentifier }
            executeRouteSequence(previousSequence, append: false, routeBranch: defaultRouteBranch, completion: completion)
        }
    }

    private func popRecordedSegments(recordedSegmentsToPop: [RecordedSegment], sequenceCompletion:(RoutingResult -> Void), popCompletion:(Void -> Void)) {
        guard recordedSegmentsToPop.count > 0 else {
            popCompletion()
            return // nothing to do here
        }

        popRouteUsingRouteSegmentsToPop(recordedSegmentsToPop, sequenceCompletion: sequenceCompletion, popCompletion: popCompletion)
    }

    private func popRouteUsingRouteSegmentsToPop(recordedSegmentsToPop: [RecordedSegment], sequenceCompletion:(RoutingResult -> Void), popCompletion:(Void -> Void)) {
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
            case .Success(_):
                self?.popRouteUsingRouteSegmentsToPop(newRecordedSegmentsToPop, sequenceCompletion: sequenceCompletion, popCompletion: popCompletion)
            case .Failure(_):
                // if popping this segment failed, do not attempt to pop the next one, just fail
                sequenceCompletion(.Failure(RoutingErrors.CouldNotReversePresentation(recordedSegment.segmentIdentifier)))
                popCompletion()
            }
        }
    }

    private func executeRouteSequence(source: [Any], append: Bool, routeBranch: RouteBranchType, completion:(RoutingResult -> Void)) {
        executeRouteSequence(RouteSequence(source: source), append: append, routeBranch: routeBranch, completion: completion)
    }

    private func executeRouteSequence(routeSequence: RouteSequence, append: Bool, routeBranch: RouteBranchType, completion:(RoutingResult -> Void)) {
        // routeSequenceTracker is the requested route
        // routeSegmentFIFOPipe is the actual route segments that were successful completed
        let routeBranchIdentifier = routeBranch.branchIdentifier
        let lastRecordedSegments = branchLastRecordedSegments[routeBranchIdentifier] ?? []
        guard let routeSequenceTracker = RouteSequenceTracker(routeSequence: routeSequence) else {
            completion(.Failure(RoutingErrors.InvalidRouteSequence))
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


    private func performNextRouteSequenceItem(routeSequenceTracker: RouteSequenceTracker, routeSegmentFIFOPipe: RouteSegmentFIFOPipe,  routeBranchIdentifier: Identifier, sequenceCompletion:(RoutingResult -> Void)) {
        guard let routeSequenceItem = routeSequenceTracker.next() else {
            popRecordedSegments(routeSegmentFIFOPipe.oldSegmentsToPop,
                                sequenceCompletion: sequenceCompletion,
                                popCompletion: {
                                    // we made it through all the items, so declare success
                                    if let finalViewController = routeSegmentFIFOPipe.peekNewRecordedSegment?.viewController {
                                        sequenceCompletion(.Success(finalViewController))
                                    } else {
                                        sequenceCompletion(.Failure(RoutingErrors.SequenceEndedWithoutViewController))
                                    }
            })
            return
        }

        let segmentIdentifier = routeSequenceItem.segmentIdentifier
        guard let routeSegment = routeSegments[segmentIdentifier] else {
            sequenceCompletion(.Failure(RoutingErrors.SegmentNotRegistered(segmentIdentifier)))
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

    private func finishRouteSequenceItem(routeSequenceItem: RouteSequenceItem, routeSegment: RouteSegmentType, routeSegmentFIFOPipe: RouteSegmentFIFOPipe, routeBranchIdentifier: Identifier, onSuccessfulPresentation: ((RouteSegmentType,UIViewController) -> Void), sequenceCompletion:(RoutingResult -> Void)) {
        let presenterIdentifier = routeSegment.presenterIdentifier
        guard let presenter = presenters[presenterIdentifier] else {
            sequenceCompletion(.Failure(RoutingErrors.PresenterNotRegistered(presenterIdentifier)))
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

        sequenceCompletion(.Failure(RoutingErrors.InvalidConfiguration("Presenter(\(presenter.dynamicType)) not handled for segment(\(routeSegment.dynamicType))")))
    }

    private func recordHistory(routeBranchIdentifier: Identifier, title: String?) {
        guard let lastRecordedSegments = branchLastRecordedSegments[routeBranchIdentifier] else {
            return
        }
        let routeSequence = RouteSequence(source: lastRecordedSegments.map { $0.segmentIdentifier })
        let history = historyForIdentifier(routeBranchIdentifier)
        print("DBG: recordHistory \(routeSequence)")
        history.recordRouteHistoryItem(RouteHistoryItem(routeSequence: routeSequence, title: title), ignoreDuplicates: true)
    }

    /// return true if this step was handled, otherwise false so another method can be called
    private func handledVisualPresenter(presenter: RouteSegmentPresenterType, parent: UIViewController?, routeSegment: RouteSegmentType, routeSequenceOptions: RouteSequenceOptions, sequenceCompletion:(RoutingResult -> Void), presentationCompletion: ((RouteSegmentType, UIViewController) -> Void)) -> Bool {
        guard let visualPresenter = presenter as? VisualRouteSegmentPresenterType else {
            return false // this is not the presenter you are looking for, we did not handle it
        }
        guard let visualRouteSegment = routeSegment as? VisualRouteSegmentType else {
            sequenceCompletion(.Failure(RoutingErrors.InvalidRouteSegment(routeSegment.segmentIdentifier, "expected VisualRouteSegmentType")))
            return true // we handled it by failing the sequence
        }
        guard let viewController = visualRouteSegment.viewController() else {
            sequenceCompletion(.Failure(RoutingErrors.NoViewControllerProduced(routeSegment.segmentIdentifier)))
            return true // we handled it by failing the sequence
        }

        let presentingViewController = parent?.actingPresentingController
        let presentationBlock = {
            visualPresenter.presentViewController(viewController, from: presentingViewController, options: routeSequenceOptions, window: self.window, completion: {
                presenterResult in

                switch presenterResult {
                case .Success(_):
                    presentationCompletion(visualRouteSegment, viewController)
                case .Failure(let error):
                    sequenceCompletion(.Failure(error))
                }
                
            })
        }
        if NSThread.isMainThread() {
            presentationBlock()
        } else {
            dispatch_async(dispatch_get_main_queue(), presentationBlock)
        }

        return true // we handled it by presenting the view controller
    }

    /// return true if this step was handled, otherwise false so another method can be called
    private func handledBranchPresenter(presenter: RouteSegmentPresenterType, parent: UIViewController?, routeSegment: RouteSegmentType, routeSequenceOptions: RouteSequenceOptions, sequenceCompletion:(RoutingResult -> Void), presentationCompletion:((RouteSegmentType,UIViewController) -> Void)) -> Bool {
        guard let branchPresenter = presenter as? BranchRouteSegmentPresenterType else {
            return false // this is not the presenter you are looking for, we did not handle it
        }
        guard let branchRouteSegment = routeSegment as? BranchRouteSegmentType else {
            sequenceCompletion(.Failure(RoutingErrors.InvalidRouteSegment(routeSegment.segmentIdentifier, "expected BranchRouteSegmentType")))
            return true // we handled it by failing the sequence
        }
        guard let trunkRouteController = parent as? TrunkRouteController else {
            sequenceCompletion(.Failure(RoutingErrors.InvalidRouteSegment(routeSegment.segmentIdentifier, "segment must be child segment of TrunkRouteController")))
            return true // we handled it by failing the sequence
        }

        branchPresenter.selectBranch(branchRouteSegment.segmentIdentifier, from: trunkRouteController, options: routeSequenceOptions, completion: {
            presenterResult in

            switch presenterResult {
            case .Success(let selectedViewController):
                presentationCompletion(branchRouteSegment, selectedViewController)
            case .Failure(let error):
                sequenceCompletion(.Failure(error))
            }
        })
        return true
    }

    private func historyForIdentifier(identifier: Identifier) -> RouterHistoryType {
        if let existingHistory = historyForIdentifiers[identifier] {
            return existingHistory
        }
        let result = RouterHistory()
        historyForIdentifiers[identifier] = result
        return result
    }

    // MARK: private variables

    private var historyForIdentifiers:[Identifier:RouterHistoryType] = [:]
    private var branchLastRecordedSegments:[Identifier:[RecordedSegment]] = [:]
    private var registeredViewControllers:[UIViewController:Identifier] = [:]

}

private extension CollectionType {
    subscript (safe index: Index) -> Generator.Element? {
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
        return remainingOldSegments.reverse()
    }

    var peekNewRecordedSegment: RecordedSegment? {
        return newRecordedSegments.last
    }

    func pushNewSegmentIdentifier(segmentIdentifier: Identifier, viewController: UIViewController) {
        let recordedSegment = RecordedSegment(segmentIdentifier: segmentIdentifier, viewController: viewController)
        newRecordedSegments.append(recordedSegment)
    }

    private var currentIndexIntoOld = -1
    private var oldRecordedSegments: [RecordedSegment]
    private var newRecordedSegments: [RecordedSegment]
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
