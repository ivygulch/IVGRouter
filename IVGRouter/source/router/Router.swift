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
    func appendRouteOnMain(source: [Any], completion:(RoutingResult -> Void))
    func executeRouteOnMain(source: [Any], completion:(RoutingResult -> Void))
    func appendRoute(source: [Any], completion:(RoutingResult -> Void))
    func executeRoute(source: [Any], completion:(RoutingResult -> Void))
    func registerDefaultPresenters()

    var currentSequence:[Any] { get }
    func debug(msg: String)
}

public class Router : RouterType {

    public init(window: UIWindow?) {
        self.window = window
    }

    public func debug(msg: String) {
        print("Router(\(msg))")
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

    public func appendRouteOnMain(source: [Any], completion:(RoutingResult -> Void)) {
        dispatch_async(dispatch_get_main_queue()) {
            self.appendRoute(source, completion: completion)
        }
    }

    public func executeRouteOnMain(source: [Any], completion:(RoutingResult -> Void)) {
        dispatch_async(dispatch_get_main_queue()) {
            self.executeRoute(source, completion: completion)
        }
    }

    public func appendRoute(source: [Any], completion:(RoutingResult -> Void)) {
        self.executeRouteSequence(source, append: true, completion: completion)
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
            // we made it through all the items, so declare success
            if let finalViewController = routeSegmentFIFOPipe.peekNewRecordedSegment?.viewController {
                sequenceCompletion(.Success(finalViewController))
            } else {
                sequenceCompletion(.Failure(RoutingErrors.SequenceEndedWithoutViewController))
            }
            return
        }

        let oldRecordedSegment = routeSegmentFIFOPipe.popOldRecordedSegment()
        let nextOldRecordedSegment = routeSegmentFIFOPipe.peekOldRecordedSegment

        let segmentIdentifier = routeSequenceItem.segmentIdentifier
        print("DBG: segmentIdentifier=\(segmentIdentifier)")
        guard let routeSegment = routeSegments[segmentIdentifier] else {
            sequenceCompletion(.Failure(RoutingErrors.SegmentNotRegistered(segmentIdentifier)))
            return
        }

        let presenterIdentifier = routeSegment.presenterIdentifier
        print("DBG: presenter=\(presenters[presenterIdentifier])")

        let onSuccessfulPresentation: ((RouteSegmentType,UIViewController) -> Void) = {
            (routeSegment, presentedViewController) in

            routeSegmentFIFOPipe.pushNewSegmentIdentifier(routeSegment.segmentIdentifier, viewController: presentedViewController)

            self.performNextRouteSequenceItem(
                routeSequenceTracker,
                routeSegmentFIFOPipe: routeSegmentFIFOPipe,
                sequenceCompletion: sequenceCompletion
            )
        }

        guard let presenter = presenters[presenterIdentifier] else {
            sequenceCompletion(.Failure(RoutingErrors.PresenterNotRegistered(presenterIdentifier)))
            return
        }


        if handledVisualPresenter(presenter, parent: routeSegmentFIFOPipe.peekNewRecordedSegment?.viewController, routeSegment: routeSegment, routeSequenceOptions: routeSequenceItem.options, sequenceCompletion: sequenceCompletion, presentationCompletion: onSuccessfulPresentation) {
            return
        }

        if let parentSegmentIdentifier = routeSegmentFIFOPipe.peekNewRecordedSegment?.segmentIdentifier,
            let parentSegment = routeSegments[parentSegmentIdentifier] {
            if handledBranchedPresenter(presenter, parentRouteSegment: parentSegment, routeSegment: routeSegment, routeSequenceOptions: routeSequenceItem.options, sequenceCompletion: sequenceCompletion, presentationCompletion: onSuccessfulPresentation) {
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
    private func handledBranchedPresenter(presenter: RouteSegmentPresenterType, parentRouteSegment: RouteSegmentType?, routeSegment: RouteSegmentType, routeSequenceOptions: RouteSequenceOptions, sequenceCompletion:(RoutingResult -> Void), presentationCompletion:((RouteSegmentType,UIViewController) -> Void)) -> Bool {
        guard let branchedPresenter = presenter as? BranchedRouteSegmentPresenterType else {
            return false // this is not the presenter you are looking for, we did not handle it
        }
        guard let branchedRouteSegment = routeSegment as? BranchedRouteSegmentType else {
            sequenceCompletion(.Failure(RoutingErrors.InvalidRouteSegment(routeSegment.segmentIdentifier, "expected BranchedRouteSegmentType")))
            return true // we handled it by failing the sequence
        }
        guard let _ = parentRouteSegment as? BranchingRouteSegmentType else {
            sequenceCompletion(.Failure(RoutingErrors.InvalidRouteSegment(routeSegment.segmentIdentifier, "segment must be child segment of BranchingRouteSegmentType")))
            return true // we handled it by failing the sequence
        }

        let message = "WARNING: handle \(branchedPresenter) & \(branchedRouteSegment)"
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
        return currentIndexIntoOld < oldRecordedSegments.count ? oldRecordedSegments[currentIndexIntoOld] : nil
    }

    var routeChanged: Bool {
        if oldRecordedSegments.count < newRecordedSegments.count {
            return true
        }
        let oldSubset = Array<RecordedSegment>(oldRecordedSegments.prefix(newRecordedSegments.count))
        return oldSubset != newRecordedSegments
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
