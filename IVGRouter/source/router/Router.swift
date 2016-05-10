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
    case SegmentNotRegistered(Identifier)
    case PresenterNotRegistered(Identifier)
    case SequenceEndedWithoutViewController
    case InvalidRouteSegment(Identifier, String)
    case NoViewControllerProduced(Identifier)
    case InvalidConfiguration(String)
    case CouldNotReversePresentation(Identifier)
}

public enum RoutingResult {
    case Success(UIViewController)
    case Failure(ErrorType)
}

public protocol RouterType {
    var window: UIWindow? { get }
    var routeSegments: [Identifier: RouteSegmentType] { get }
    var presenters: [Identifier: RouteSegmentPresenterType] { get }
    var viewControllers: [UIViewController] { get }
    func registerPresenter(presenter: RouteSegmentPresenterType)
    func registerRouteSegment(routeSegment: RouteSegmentType)
    func appendRoute(source: [Any], completion:(RoutingResult -> Void))
    func executeRoute(source: [Any], completion:(RoutingResult -> Void))
    func popRoute(completion:(RoutingResult -> Void))
    func registerDefaultPresenters()

    var currentSequence:[Any] { get }
    func debug(msg: String)
}

public class Router : RouterType {

    public init(window: UIWindow?) {
        self.window = window
    }

    public func debug(msg: String) {
        print("Router(\(msg)), lastRecordedSegments.count=\(lastRecordedSegments.count)")
        for index in 0..<lastRecordedSegments.count {
            let recordedSegment = lastRecordedSegments[index]
            let segmentIdentifier = recordedSegment.segmentIdentifier
            let vc = recordedSegment.viewController
            var result = "[\(index)]"
            result += "=\(segmentIdentifier.name)"
            result += "," + String(vc.dynamicType)
            if let p = vc?.parentViewController {
                result += ",p=" + String(p.dynamicType)
            }
            print(result)
        }
    }

    public private(set) var routeSegments:[Identifier:RouteSegmentType] = [:]
    public private(set) var presenters:[Identifier:RouteSegmentPresenterType] = [:]

    public let window: UIWindow?

    public var viewControllers:[UIViewController] {
        return lastRecordedSegments.flatMap { $0.viewController }
    }

    public func registerPresenter(presenter:RouteSegmentPresenterType) {
        presenters[presenter.presenterIdentifier] = presenter
    }

    public func registerRouteSegment(routeSegment:RouteSegmentType) {
        routeSegments[routeSegment.segmentIdentifier] = routeSegment
    }

    public func registerDefaultPresenters() {
        registerPresenter(RootRouteSegmentPresenter())
        registerPresenter(TabRouteSegmentPresenter())
        registerPresenter(PushRouteSegmentPresenter())
        registerPresenter(WrappingRouteSegmentPresenter(wrappingRouteSegmentAnimator: SlidingWrappingRouteSegmentAnimator()))
    }

    public var currentSequence:[Any] {
        return lastRecordedSegments.map {
            recordedSegment -> Identifier in
            return recordedSegment.segmentIdentifier
        }
    }

    public func appendRoute(source: [Any], completion:(RoutingResult -> Void)) {
        self.executeRouteSequence(source, append: true, completion: completion)
    }

    public func popRoute(completion:(RoutingResult -> Void)) {
        guard self.lastRecordedSegments.count > 0 else {
            completion(.Failure(RoutingErrors.InvalidRouteSequence))
            return
        }

        let lastRecordedSegment = lastRecordedSegments.removeLast()

        let lastSegmentIdentifier = lastRecordedSegment.segmentIdentifier
        if let lastPresenterIdentifier = routeSegments[lastSegmentIdentifier]?.presenterIdentifier,
            let reversibleRouteSegmentPresenter = presenters[lastPresenterIdentifier] as? ReversibleRouteSegmentPresenterType,
            let lastViewController = lastRecordedSegment.viewController,
            let lastParentViewController = lastViewController.parentViewController {

            reversibleRouteSegmentPresenter.reversePresentation(lastViewController) {
                success in
                if success {
                    completion(.Success(lastParentViewController))
                } else {
                    completion(.Failure(RoutingErrors.CouldNotReversePresentation(lastSegmentIdentifier)))
                }
            }

        } else if let lastViewController = lastRecordedSegment.viewController,
            let navigationController = lastViewController.navigationController {
            navigationController.popViewControllerAnimated(true, completion: {
                completion(.Success(navigationController))
            })

        } else {
            let previousSequence: [Any] = self.lastRecordedSegments.map { $0.segmentIdentifier }
            self.executeRouteSequence(previousSequence, append: false, completion: completion)
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

        popRoute() {
            routingResult in
            switch routingResult {
            case .Success(_):
                self.popRouteUsingRouteSegmentsToPop(newRecordedSegmentsToPop, sequenceCompletion: sequenceCompletion, popCompletion: popCompletion)
            case .Failure(_):
                // if popping this segment failed, do not attempt to pop the next one, just fail
                sequenceCompletion(.Failure(RoutingErrors.PresenterNotRegistered(recordedSegment.segmentIdentifier)))
                popCompletion()
            }
        }
    }

    public func executeRoute(source: [Any], completion:(RoutingResult -> Void)) {
        self.executeRouteSequence(source, append: false, completion: completion)
    }

    private func executeRouteSequence(source: [Any], append: Bool, completion:(RoutingResult -> Void)) {
        // routeSequenceTracker is the requested route
        // routeSegmentFIFOPipe is the actual route segments that were successful completed
        guard let routeSequenceTracker = RouteSequenceTracker(routeSequence: RouteSequence(source: source)) else {
            completion(.Failure(RoutingErrors.InvalidRouteSequence))
            return
        }
        let routeSegmentFIFOPipe = RouteSegmentFIFOPipe(oldRecordedSegments: lastRecordedSegments, appending: append)
        performNextRouteSequenceItem(
            routeSequenceTracker,
            routeSegmentFIFOPipe: routeSegmentFIFOPipe,
            sequenceCompletion: {
                routingResult in
                self.lastRecordedSegments = routeSegmentFIFOPipe.newRecordedSegments
                completion(routingResult)
            }
        )
    }


    private func performNextRouteSequenceItem(routeSequenceTracker: RouteSequenceTracker, routeSegmentFIFOPipe: RouteSegmentFIFOPipe,  sequenceCompletion:(RoutingResult -> Void)) {
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
            (routeSegment, presentedViewController) in

            routeSegmentFIFOPipe.pushNewSegmentIdentifier(routeSegment.segmentIdentifier, viewController: presentedViewController)

            self.performNextRouteSequenceItem(
                routeSequenceTracker,
                routeSegmentFIFOPipe: routeSegmentFIFOPipe,
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
                                        self.finishRouteSequenceItem(routeSequenceItem, routeSegment: routeSegment, routeSegmentFIFOPipe: routeSegmentFIFOPipe, onSuccessfulPresentation: onSuccessfulPresentation, sequenceCompletion: sequenceCompletion)
                })
            }
        } else {
            finishRouteSequenceItem(routeSequenceItem, routeSegment: routeSegment, routeSegmentFIFOPipe: routeSegmentFIFOPipe, onSuccessfulPresentation: onSuccessfulPresentation, sequenceCompletion: sequenceCompletion)
        }
    }

    private func finishRouteSequenceItem(routeSequenceItem: RouteSequenceItemType, routeSegment: RouteSegmentType, routeSegmentFIFOPipe: RouteSegmentFIFOPipe, onSuccessfulPresentation: ((RouteSegmentType,UIViewController) -> Void), sequenceCompletion:(RoutingResult -> Void)) {
        let presenterIdentifier = routeSegment.presenterIdentifier
        guard let presenter = presenters[presenterIdentifier] else {
            sequenceCompletion(.Failure(RoutingErrors.PresenterNotRegistered(presenterIdentifier)))
            return
        }

        if handledVisualPresenter(presenter, parent: routeSegmentFIFOPipe.peekNewRecordedSegment?.viewController, routeSegment: routeSegment, routeSequenceOptions: routeSequenceItem.options, sequenceCompletion: sequenceCompletion, presentationCompletion: onSuccessfulPresentation) {
            return
        }

        if let parentSegmentIdentifier = routeSegmentFIFOPipe.peekNewRecordedSegment?.segmentIdentifier,
            let parentSegment = routeSegments[parentSegmentIdentifier] {
            if handledBranchPresenter(presenter, parentRouteSegment: parentSegment, routeSegment: routeSegment, routeSequenceOptions: routeSequenceItem.options, sequenceCompletion: sequenceCompletion, presentationCompletion: onSuccessfulPresentation) {
                return
            }
        }

        sequenceCompletion(.Failure(RoutingErrors.InvalidConfiguration("Presenter(\(presenter.dynamicType)) not handled for segment(\(routeSegment.dynamicType))")))
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

        visualPresenter.presentViewController(viewController, from: parent, options: routeSequenceOptions, window: window, completion: {
            success in

            if success {
                presentationCompletion(visualRouteSegment, viewController)
            } else {
                sequenceCompletion(.Failure(RoutingErrors.NoViewControllerProduced(routeSegment.segmentIdentifier)))
            }

        })
        return true // we handled it by presenting the view controller
    }

    /// return true if this step was handled, otherwise false so another method can be called
    private func handledBranchPresenter(presenter: RouteSegmentPresenterType, parentRouteSegment: RouteSegmentType?, routeSegment: RouteSegmentType, routeSequenceOptions: RouteSequenceOptions, sequenceCompletion:(RoutingResult -> Void), presentationCompletion:((RouteSegmentType,UIViewController) -> Void)) -> Bool {
        guard let branchPresenter = presenter as? BranchRouteSegmentPresenterType else {
            return false // this is not the presenter you are looking for, we did not handle it
        }
        guard let branchRouteSegment = routeSegment as? BranchRouteSegmentType else {
            sequenceCompletion(.Failure(RoutingErrors.InvalidRouteSegment(routeSegment.segmentIdentifier, "expected BranchRouteSegmentType")))
            return true // we handled it by failing the sequence
        }
        guard let _ = parentRouteSegment as? TrunkRouteSegmentType else {
            sequenceCompletion(.Failure(RoutingErrors.InvalidRouteSegment(routeSegment.segmentIdentifier, "segment must be child segment of TrunkRouteSegmentType")))
            return true // we handled it by failing the sequence
        }

        // TODO: handle branchPresenter & branchRouteSegment
        let message = "WARNING: handle \(branchPresenter) & \(branchRouteSegment)"
        sequenceCompletion(.Failure(RoutingErrors.InvalidConfiguration(message)))
        return true
    }

    private var lastRecordedSegments:[RecordedSegment] = []
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

    init?(routeSequence: RouteSequenceType) {
        self.routeSequence = routeSequence
        if routeSequence.items.count == 0 {
            return nil
        }
    }

    var remainingItems: [RouteSequenceItemType] {
        let remainingCount = routeSequence.items.count - currentIndex
        guard remainingCount > 0 else {
            return []
        }
        return Array<RouteSequenceItemType>(routeSequence.items.suffix(remainingCount))
    }

    func next() -> RouteSequenceItemType? {
        currentIndex += 1
        guard currentIndex < routeSequence.items.count else {
            return nil
        }
        return routeSequence.items[currentIndex]
    }
    
    let routeSequence: RouteSequenceType
    var currentIndex: Int = -1
}
