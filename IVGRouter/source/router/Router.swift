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

public protocol RouteHistoryPreviousButtonProvider {
    var previousHistoryItemButton: UIButton? { get }
    func configurePreviousHistoryItem(forButton button: UIButton, routeHistoryItemTitle: String?) -> ((Void) -> Void)?
}

public protocol RouteHistoryNextButtonProvider {
    var nextHistoryItemButton: UIButton? { get }
    func configureNextHistoryItem(forButton button: UIButton, routeHistoryItemTitle: String?) -> ((Void) -> Void)?
}

public protocol RouterType {
    var window: UIWindow? { get }
    var routeSegments: [Identifier: RouteSegmentType] { get }
    var routeBranches: [Identifier: RouteBranchType] { get }
    var presenters: [Identifier: RouteSegmentPresenterType] { get }
    var defaultRouteBranch: RouteBranchType { get }

    func register(routeSegmentPresenter: RouteSegmentPresenterType)
    func register(routeSegment: RouteSegmentType)
    func register(routeBranch: RouteBranchType)
    func append(route source: [Any], toRouteBranch routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void))
    func execute(route source: [Any], toRouteBranch routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void))
    func pop(fromRouteBranch routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void))

    func clearHistory(onRouteBranch routeBranch: RouteBranchType)
    func previousRouteHistoryItem(onRouteBranch routeBranch: RouteBranchType) -> RouteHistoryItemType?
    func nextRouteHistoryItem(onRouteBranch routeBranch: RouteBranchType) -> RouteHistoryItemType?
    func goBack(onRouteBranch routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void))
    func goForward(onRouteBranch routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void))
    func registerDefaultPresenters()

    func viewControllers(forRouteBranchIdentifier branchIdentifier: Identifier) -> [UIViewController]
}

extension RouterType {
    public func append(route source: [Any], completion: @escaping ((RoutingResult) -> Void)) {
        append(route: source, toRouteBranch: defaultRouteBranch, completion: completion)
    }

    public func execute(route source: [Any], completion: @escaping ((RoutingResult) -> Void)) {
        execute(route: source, toRouteBranch: defaultRouteBranch, completion: completion)
    }

    public func pop(completion: @escaping ((RoutingResult) -> Void)) {
        pop(fromRouteBranch: defaultRouteBranch, completion: completion)
    }

    public func clearHistory() {
        clearHistory(onRouteBranch: defaultRouteBranch)
    }

    public func previousRouteHistoryItem() -> RouteHistoryItemType? {
        return previousRouteHistoryItem(onRouteBranch: defaultRouteBranch)
    }

    public func nextRouteHistoryItem() -> RouteHistoryItemType? {
        return nextRouteHistoryItem(onRouteBranch: defaultRouteBranch)
    }

    public func goBack(completion: @escaping ((RoutingResult) -> Void)) {
        goBack(onRouteBranch: defaultRouteBranch, completion: completion)
    }

    public func goForward(completion: @escaping ((RoutingResult) -> Void)) {
        goForward(onRouteBranch: defaultRouteBranch, completion: completion)
    }

}

private struct RouterConstants {
    static let defaultTitle = "Previous Page"
}

open class Router : RouterType {

    public init(window: UIWindow?) {
        self.window = window
        defaultRouteBranch = RouteBranch(branchIdentifier: Identifier(name: UUID().uuidString), routeSequence: RouteSequence(source: []))
        register(routeBranch: defaultRouteBranch)
    }

    open func debugString(_ msg: String) -> String {
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

    open func debug(_ msg: String) {
        print("\(debugString(msg))")
    }

    open fileprivate(set) var routeSegments: [Identifier: RouteSegmentType] = [: ]
    open fileprivate(set) var routeBranches: [Identifier: RouteBranchType] = [: ]
    open fileprivate(set) var presenters: [Identifier: RouteSegmentPresenterType] = [: ]

    open let window: UIWindow?
    open let defaultRouteBranch: RouteBranchType

    open func viewControllers(forRouteBranchIdentifier routeBranchIdentifier: Identifier) -> [UIViewController] {
        if let lastRecordedSegments = branchLastRecordedSegments[routeBranchIdentifier] {
            return lastRecordedSegments.flatMap { $0.viewController }
        } else {
            return []
        }
    }

    open func register(routeSegmentPresenter: RouteSegmentPresenterType) {
        presenters[routeSegmentPresenter.presenterIdentifier] = routeSegmentPresenter
    }

    open func register(routeSegment: RouteSegmentType) {
        routeSegments[routeSegment.segmentIdentifier] = routeSegment
    }

    open func register(routeBranch: RouteBranchType) {
        routeBranches[routeBranch.branchIdentifier] = routeBranch
    }

    open func registerDefaultPresenters() {
        register(routeSegmentPresenter: RootRouteSegmentPresenter())
        register(routeSegmentPresenter: BranchRouteSegmentPresenter())
        register(routeSegmentPresenter: PushRouteSegmentPresenter())
        register(routeSegmentPresenter: PresentRouteSegmentPresenter())
        register(routeSegmentPresenter: SetRouteSegmentPresenter())
        register(routeSegmentPresenter: WrappingRouteSegmentPresenter(wrappingRouteSegmentAnimator: SlidingWrappingRouteSegmentAnimator()))
    }

    // MARK: public routing methods

    open func append(route source: [Any], toRouteBranch routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void)) {
        let routeBranchIdentifier = routeBranch.branchIdentifier
        let wrappedCompletion: ((RoutingResult) -> Void) = { [weak self] routingResult in
            if case .success(let viewController) = routingResult {
                _ = self?.recordHistory(forRouteBranchIdentifier: routeBranchIdentifier, title: viewController.title)
                self?.configureHistoryButtons(onRouteBranch: routeBranch, presented: viewController)
            }
            completion(routingResult)
        }
        execute(routeSequence: source, append: true, routeBranch: routeBranch, completion: wrappedCompletion)
    }

    open func pop(fromRouteBranch routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void)) {
        let routeBranchIdentifier = routeBranch.branchIdentifier
        let wrappedCompletion: ((RoutingResult) -> Void) = { [weak self] routingResult in
            if case .success(let viewController) = routingResult {
                _ = self?.recordHistory(forRouteBranchIdentifier: routeBranchIdentifier, title: viewController.title)
                self?.configureHistoryButtons(onRouteBranch: routeBranch, presented: viewController)
            }
            completion(routingResult)
        }

        popInternal(routeBranch: routeBranch, completion: wrappedCompletion)
    }

    open func clearHistory(onRouteBranch routeBranch: RouteBranchType) {
        historyForIdentifiers[routeBranch.branchIdentifier] = nil
    }

    open func previousRouteHistoryItem(onRouteBranch routeBranch: RouteBranchType) -> RouteHistoryItemType? {
        return historyForIdentifiers[routeBranch.branchIdentifier]?.previousRouteHistoryItem
    }

    open func nextRouteHistoryItem(onRouteBranch routeBranch: RouteBranchType) -> RouteHistoryItemType? {
        return historyForIdentifiers[routeBranch.branchIdentifier]?.nextRouteHistoryItem
    }

    open func goBack(onRouteBranch routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void)) {
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
        execute(routeSequence: previousRouteHistoryItem.routeSequence, append: false, routeBranch: routeBranch, completion: wrappedCompletion)
    }

    open func goForward(onRouteBranch routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void)) {
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
        execute(routeSequence: nextRouteHistoryItem.routeSequence, append: false, routeBranch: routeBranch, completion: wrappedCompletion)
    }
    
    open func execute(route source: [Any], toRouteBranch routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void)) {
        let routeBranchIdentifier = routeBranch.branchIdentifier
        let wrappedCompletion: ((RoutingResult) -> Void) = { [weak self] routingResult in
            if case .success(let viewController) = routingResult {
                _ = self?.recordHistory(forRouteBranchIdentifier: routeBranchIdentifier, title: viewController.title)
                self?.configureHistoryButtons(onRouteBranch: routeBranch, presented: viewController)
            }
            completion(routingResult)
        }
        if routeBranchIdentifier != defaultRouteBranch.branchIdentifier {
            // make sure the defaultBranch is set to the proper place for this branch
            let defaultSource = routeBranch.routeSequence.items.map {
                routeSequenceItem -> Any in
                return routeSequenceItem
            }
            execute(routeSequence: defaultSource, append: false, routeBranch: defaultRouteBranch) { [weak self] routeResult in
                switch routeResult {
                case .success: 
                    // if we successfully switched to the correct spot on the default branch, append the rest
                    self?.execute(routeSequence: source, append: false, routeBranch: routeBranch, completion: wrappedCompletion)
                case .failure: 
                    // we could not reset the default branch, so just give up
                    wrappedCompletion(routeResult)
                }
            }
        } else {
            execute(routeSequence: source, append: false, routeBranch: routeBranch, completion: wrappedCompletion)
        }
    }

    // MARK: UIButton configuration

    fileprivate var previousButtonCompletions: [UIButton: ((Void) -> Void)] = [: ]
    fileprivate var nextButtonCompletions: [UIButton: ((Void) -> Void)] = [: ]

    @objc fileprivate func previousButtonAction(_ button: UIButton) {
        let buttonCompletion = previousButtonCompletions[button]
        goBack() { _ in
            buttonCompletion?()
        }
    }

    @objc fileprivate func nextButtonAction(_ button: UIButton) {
        let buttonCompletion = nextButtonCompletions[button]
        goForward() { _ in
            buttonCompletion?()
        }
    }

    fileprivate func configure(previousButton button: UIButton, onRouteBranch routeBranch: RouteBranchType, tapCompletion: ((Void) -> Void)?) {
        let selector = #selector(Router.previousButtonAction(_: ))
        if previousRouteHistoryItem(onRouteBranch: routeBranch) != nil {
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

    fileprivate func configure(nextButton button: UIButton, onRouteBranch routeBranch: RouteBranchType, tapCompletion: ((Void) -> Void)?) {
        let selector = #selector(Router.nextButtonAction(_: ))
        if nextRouteHistoryItem(onRouteBranch: routeBranch) != nil {
            button.isHidden = false
            nextButtonCompletions[button] = tapCompletion
            button.addTarget(self, action: selector, for: .touchUpInside)
        } else {
            button.isHidden = true
            nextButtonCompletions[button] = nil
            button.removeTarget(self, action: selector, for: .touchUpInside)
            button.setTitle(nil, for: .normal)
        }
    }

    open func configureNextButton(_ button: UIButton, historyTitleHandler: ((String?) -> Void)?, tapCompletion: ((Void) -> Void)?) {
        let selector = #selector(Router.nextButtonAction(_: ))
        if let historyItem = nextRouteHistoryItem() {
            if let historyTitleHandler = historyTitleHandler {
                historyTitleHandler(historyItem.title)
            } else {
                button.setTitle(historyItem.title ?? RouterConstants.defaultTitle, for: .normal)
            }
            button.isHidden = false
            nextButtonCompletions[button] = tapCompletion
            button.addTarget(self, action: selector, for: .touchUpInside)
        } else {
            button.isHidden = true
            nextButtonCompletions[button] = nil
            button.removeTarget(self, action: selector, for: .touchUpInside)
            button.setTitle(nil, for: .normal)
        }
    }

    fileprivate func configureHistoryButtons(onRouteBranch routeBranch: RouteBranchType, presented: Any) {
        if let previousButtonProvider = presented as? RouteHistoryPreviousButtonProvider {
            if let previousButton = previousButtonProvider.previousHistoryItemButton {
                let routeHistoryItem = previousRouteHistoryItem(onRouteBranch: routeBranch)
                let tapCompletion = previousButtonProvider.configurePreviousHistoryItem(forButton: previousButton, routeHistoryItemTitle: routeHistoryItem?.title)
                configure(previousButton: previousButton, onRouteBranch: routeBranch, tapCompletion: tapCompletion)
            }
        }
        if let nextButtonProvider = presented as? RouteHistoryNextButtonProvider {
            if let nextButton = nextButtonProvider.nextHistoryItemButton {
                let routeHistoryItem = nextRouteHistoryItem(onRouteBranch: routeBranch)
                let tapCompletion = nextButtonProvider.configureNextHistoryItem(forButton: nextButton, routeHistoryItemTitle: routeHistoryItem?.title)
                configure(nextButton: nextButton, onRouteBranch: routeBranch, tapCompletion: tapCompletion)
            }
        }
    }
    
    

    // MARK: private routing methods

    fileprivate func popInternal(completion: @escaping ((RoutingResult) -> Void)) {
        popInternal(routeBranch: defaultRouteBranch, completion: completion)
    }

    fileprivate func popInternal(routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void)) {
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
            execute(routeSequence: previousSequence, append: false, routeBranch: defaultRouteBranch, completion: completion)
        }
    }

    fileprivate func pop(recordedSegments recordedSegmentsToPop: [RecordedSegment], sequenceCompletion: @escaping ((RoutingResult) -> Void), popCompletion: @escaping ((Void) -> Void)) {
        guard recordedSegmentsToPop.count > 0 else {
            popCompletion()
            return // nothing to do here
        }

        popUsing(recordedSegments: recordedSegmentsToPop, sequenceCompletion: sequenceCompletion, popCompletion: popCompletion)
    }

    fileprivate func popUsing(recordedSegments recordedSegmentsToPop: [RecordedSegment], sequenceCompletion: @escaping ((RoutingResult) -> Void), popCompletion: @escaping ((Void) -> Void)) {
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

    fileprivate func execute(routeSequence source: [Any], append: Bool, routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void)) {
        execute(routeSequence: RouteSequence(source: source), append: append, routeBranch: routeBranch, completion: completion)
    }

    fileprivate func execute(routeSequence: RouteSequence, append: Bool, routeBranch: RouteBranchType, completion: @escaping ((RoutingResult) -> Void)) {
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
            sequenceCompletion: { [weak self] routingResult in
                self?.branchLastRecordedSegments[routeBranchIdentifier] = routeSegmentFIFOPipe.newRecordedSegments
                completion(routingResult)
            }
        )
    }


    fileprivate func performNextRouteSequenceItem(_ routeSequenceTracker: RouteSequenceTracker, routeSegmentFIFOPipe: RouteSegmentFIFOPipe,  routeBranchIdentifier: Identifier, sequenceCompletion: @escaping ((RoutingResult) -> Void)) {
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
        guard let routeSegment = routeSegments[segmentIdentifier] else {
            sequenceCompletion(.failure(RoutingErrors.segmentNotRegistered(segmentIdentifier)))
            return
        }

        let onSuccessfulPresentation: ((RouteSegmentType,UIViewController) -> Void) = { [weak self] (routeSegment, presentedViewController) in

//            print("DBG: onSuccessfulPresentation=\(routeSegment), \(presentedViewController)")

            routeSegmentFIFOPipe.pushNewSegmentIdentifier(routeSegment.segmentIdentifier, viewController: presentedViewController)

            let wrappedSC: ((RoutingResult) -> Void) = { routingResult in
                sequenceCompletion(routingResult)
            }

            self?.performNextRouteSequenceItem(
                routeSequenceTracker,
                routeSegmentFIFOPipe: routeSegmentFIFOPipe,
                routeBranchIdentifier: routeBranchIdentifier,
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
                        self?.finish(routeSequenceItem: routeSequenceItem, routeSegment: routeSegment, routeSegmentFIFOPipe: routeSegmentFIFOPipe, routeBranchIdentifier: routeBranchIdentifier, onSuccessfulPresentation: onSuccessfulPresentation, sequenceCompletion: sequenceCompletion)
                })
            }
        } else {
            finish(routeSequenceItem: routeSequenceItem, routeSegment: routeSegment, routeSegmentFIFOPipe: routeSegmentFIFOPipe, routeBranchIdentifier: routeBranchIdentifier, onSuccessfulPresentation: onSuccessfulPresentation, sequenceCompletion: sequenceCompletion)
        }
    }

    fileprivate func finish(routeSequenceItem: RouteSequenceItem, routeSegment: RouteSegmentType, routeSegmentFIFOPipe: RouteSegmentFIFOPipe, routeBranchIdentifier: Identifier, onSuccessfulPresentation: @escaping ((RouteSegmentType,UIViewController) -> Void), sequenceCompletion: @escaping ((RoutingResult) -> Void)) {
        let presenterIdentifier = routeSegment.presenterIdentifier
        guard let presenter = presenters[presenterIdentifier] else {
            sequenceCompletion(.failure(RoutingErrors.presenterNotRegistered(presenterIdentifier)))
            return
        }

        let currentSegment = routeSegmentFIFOPipe.peekNewRecordedSegment
        let currentViewController = currentSegment?.viewController
        if handled(visualPresenter: presenter, parent: currentViewController, routeSegment: routeSegment, routeSequenceOptions: routeSequenceItem.options, sequenceCompletion: sequenceCompletion, presentationCompletion: onSuccessfulPresentation) {
            return
        }

        if handledBranchPresenter(presenter, parent: currentViewController, routeSegment: routeSegment, routeSequenceOptions: routeSequenceItem.options, sequenceCompletion: sequenceCompletion, presentationCompletion: onSuccessfulPresentation) {
            return
        }

        sequenceCompletion(.failure(RoutingErrors.invalidConfiguration("Presenter(\(type(of: presenter))) not handled for segment(\(type(of: routeSegment)))")))
    }

    fileprivate func recordHistory(forRouteBranchIdentifier routeBranchIdentifier: Identifier, title: String?) -> RouteHistoryItem? {
        guard let lastRecordedSegments = branchLastRecordedSegments[routeBranchIdentifier] else {
            return nil
        }
        let routeSequence = RouteSequence(source: lastRecordedSegments.map { $0.segmentIdentifier })
        let history = historyForIdentifier(routeBranchIdentifier)
        let routeHistoryItem = RouteHistoryItem(routeSequence: routeSequence, title: title)
        history.recordRouteHistoryItem(routeHistoryItem, ignoreDuplicates: true)
        return routeHistoryItem
    }

    /// return true if this step was handled, otherwise false so another method can be called
    fileprivate func handled(visualPresenter presenter: RouteSegmentPresenterType, parent: UIViewController?, routeSegment: RouteSegmentType, routeSequenceOptions: RouteSequenceOptions, sequenceCompletion: @escaping ((RoutingResult) -> Void), presentationCompletion: @escaping ((RouteSegmentType, UIViewController) -> Void)) -> Bool {
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

    /// return true if this step was handled, otherwise false so another method can be called
    fileprivate func handledBranchPresenter(_ presenter: RouteSegmentPresenterType, parent: UIViewController?, routeSegment: RouteSegmentType, routeSequenceOptions: RouteSequenceOptions, sequenceCompletion: @escaping ((RoutingResult) -> Void), presentationCompletion: @escaping ((RouteSegmentType,UIViewController) -> Void)) -> Bool {
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

        branchPresenter.select(branchRouteSegmentIdentifier: branchRouteSegment.segmentIdentifier, from: trunkRouteController, options: routeSequenceOptions, completion: {
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

    fileprivate func debugDefaultRouteBranch(_ msg: String) {
        historyForIdentifiers[defaultRouteBranch.branchIdentifier]?.debug(msg)
    }

    fileprivate func debugFullDefaultRouteBranch(_ msg: String) {
        historyForIdentifiers[defaultRouteBranch.branchIdentifier]?.debugFull(msg)
    }

    // MARK: private variables

    fileprivate var historyForIdentifiers: [Identifier: RouterHistoryType] = [: ]
    fileprivate var branchLastRecordedSegments: [Identifier: [RecordedSegment]] = [: ]
    fileprivate var registeredViewControllers: [UIViewController: Identifier] = [: ]

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
