//
//  ApplicationContainer.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/19/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import IVGRouter

public enum ContainerState {
    case Uninitialized
    case Launching
    case Inactive
    case Active
    case Background
    case Terminating
}

public protocol ApplicationContainerType: class {
    var window: UIWindow? { get }
    var containerState: ContainerState { get }
    var router: RouterType { get }
    var defaultRouteSequence: [Any] { get set }
    func executeDefaultRouteSequence()

    var resourceCount: Int { get }
    func resource<T>(type: T.Type) -> T?
    func addResource<T>(resource: ResourceType, forProtocol: T.Type)
    var serviceCount: Int { get }
    func service<T>(type: T.Type) -> T?
    func addService<T>(service: ServiceType, forProtocol: T.Type)
    var coordinatorCount: Int { get }
    func coordinator<T>(type: T.Type) -> T?
    func addCoordinator<T>(coordinator: CoordinatorType, forProtocol: T.Type)

    func willFinishLaunching() -> Bool
    func didFinishLaunching() -> Bool
    func didBecomeActive()
    func willResignActive()
    func willTerminate()
    func didEnterBackground()
    func willEnterForeground()
}

public class ApplicationContainer : ApplicationContainerType {

    public let window: UIWindow?
    public var containerState: ContainerState {
        get {
            return synchronizer.valueOf {
                return self._containerState
            }
        }
        set {
            synchronizer.execute {
                self._containerState = newValue
            }
        }
    }

    public let router:RouterType

    public init(window: UIWindow?) {
        self.window = window
        router = Router(window: window)
        router.registerDefaultPresenters()
    }

    public var defaultRouteSequence: [Any] = []

    public func executeDefaultRouteSequence() {
        router.executeRoute(defaultRouteSequence)
    }

    // MARK: - Resources

    public var resourceCount: Int {
        return synchronizer.valueOf {
            return self.resources.count
        }
    }

    public func resource<T>(type: T.Type) -> T? {
        return synchronizer.valueOf {
            return self.resources[TypeKey(type)] as? T
        }
    }

    public func addResource<T>(resource: ResourceType, forProtocol: T.Type) {
        synchronizer.execute {
            self.resources[TypeKey(T)] = resource
        }
    }

    // MARK: - Services

    public var serviceCount: Int {
        return synchronizer.valueOf {
            return self.services.count
        }
    }

    public func service<T>(type: T.Type) -> T? {
        return synchronizer.valueOf {
            return self.services[TypeKey(T)] as? T
        }
    }

    public func addService<T>(service: ServiceType, forProtocol: T.Type) {
        synchronizer.execute {
            let key = TypeKey(T)
            if let index = self.serviceKeyOrder.indexOf(key) {
                self.serviceKeyOrder.removeAtIndex(index)
            }
            self.services[key] = service
            self.serviceKeyOrder.append(key)

            // if container state has progressed past uninitialized, then call methods that were missed
            switch self._containerState {
            case .Launching:
                service.willFinishLaunching()
            case .Inactive:
                service.willFinishLaunching()
                service.didFinishLaunching()
            case .Active:
                service.willFinishLaunching()
                service.didFinishLaunching()
                service.didBecomeActive()
            case .Background:
                service.willFinishLaunching()
                service.didFinishLaunching()
                service.didEnterBackground()
            default:
                break // no extra steps necessary
            }
        }
    }

    // MARK: - Coordinators

    public var coordinatorCount: Int {
        return synchronizer.valueOf {
            return self.coordinators.count
        }
    }

    public func coordinator<T>(type: T.Type) -> T? {
        return synchronizer.valueOf {
            return self.coordinators[TypeKey(T)] as? T
        }
    }

    public func addCoordinator<T>(coordinator: CoordinatorType, forProtocol: T.Type) {
        synchronizer.execute {
            self.coordinators[TypeKey(T)] = coordinator
        }
        coordinator.registerRouteSegments(router)
    }

    // MARK: - Lifecycle

    private func orderedServices() -> [ServiceType] {
        return synchronizer.valueOf {
            return self.serviceKeyOrder
                .filter { self.services[$0] != nil }
                .map { self.services[$0]! }
        }
    }

    private func conditionallyForEachOrderedService(block: (ServiceType) -> Bool) -> Bool {
        for service in orderedServices() {
            if !block(service) {
                return false
            }
        }
        return true
    }

    private func forEachOrderedService(block: (ServiceType) -> Void) {
        for service in orderedServices() {
            block(service)
        }
    }

    public func willFinishLaunching() -> Bool {
        containerState = .Launching
        return conditionallyForEachOrderedService {
            service -> Bool in
            return service.willFinishLaunching()
        }
    }

    public func didFinishLaunching() -> Bool {
        containerState = .Inactive
        return conditionallyForEachOrderedService {
            service -> Bool in
            return service.didFinishLaunching()
        }
    }

    public func didBecomeActive() {
        containerState = .Active
        return forEachOrderedService {
            service in
            service.didBecomeActive()
        }
    }

    public func willResignActive() {
        containerState = .Inactive
        return forEachOrderedService {
            service in
            service.willResignActive()
        }
    }

    public func willTerminate() {
        containerState = .Terminating
        return forEachOrderedService {
            service in
            service.willTerminate()
        }
    }

    public func didEnterBackground() {
        containerState = .Background
        return forEachOrderedService {
            service in
            service.didEnterBackground()
        }
    }

    public func willEnterForeground() {
        containerState = .Inactive
        return forEachOrderedService {
            service in
            service.willEnterForeground()
        }
    }

    // MARK: - Private variables

    private var resources: [TypeKey: ResourceType] = [:]
    private var services: [TypeKey: ServiceType] = [:]
    private var serviceKeyOrder: [TypeKey] = []
    private var coordinators: [TypeKey: CoordinatorType] = [:]
    private let synchronizer = Synchronizer()
    private var _containerState: ContainerState = .Uninitialized
}
