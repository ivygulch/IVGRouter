//
//  DemoAppCoordinator.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/21/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation
import IVGAppContainer
import IVGRouter

protocol DemoAppCoordinatorType: CoordinatorType {
}

class DemoAppCoordinator: DemoAppCoordinatorType {

    let rootSegmentIdentifier = Identifier(name: "DemoAppCoordinator.root")
    let welcomeSegmentIdentifier = Identifier(name: "DemoAppCoordinator.welcome")
    let nextSegmentIdentifier = Identifier(name: "DemoAppCoordinator.next")
    let wrapperSegmentIdentifier = Identifier(name: "DemoAppCoordinator.wrapper")

    lazy var welcomeRouteSequence:[Any] = [self.rootSegmentIdentifier,self.welcomeSegmentIdentifier]
    lazy var nextRouteSequence:[Any] = [self.rootSegmentIdentifier,self.welcomeSegmentIdentifier,self.nextSegmentIdentifier]

    required init(container: ApplicationContainerType) {
        self.container = container
    }

    func registerRouteSegments(router: RouterType) {
        router.registerRouteSegment(buildRootSegment())
        router.registerRouteSegment(buildWelcomeSegment())
        router.registerRouteSegment(buildNextSegment())
        router.registerRouteSegment(buildWrapperSegment())
    }

    private func buildRootSegment() -> RouteSegment {
        return RouteSegment(
            segmentIdentifier: rootSegmentIdentifier,
            presenterIdentifier: RootRouteSegmentPresenter.defaultPresenterIdentifier,
            isSingleton: true,
            loadViewController:{ return { return RootViewController() } }
        )
    }

    private func buildWelcomeSegment() -> RouteSegment  {
        return RouteSegment(
            segmentIdentifier: welcomeSegmentIdentifier,
            presenterIdentifier: PushRouteSegmentPresenter.defaultPresenterIdentifier,
            isSingleton: true,
            loadViewController:{ return {
                let result = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(String(WelcomeViewController)) as! WelcomeViewController
                result.nextAction = {
                    self.container.router.executeRoute(self.nextRouteSequence)
                }
                return result
                } }
        )
    }

    private func buildNextSegment() -> RouteSegment  {
        return RouteSegment(
            segmentIdentifier: nextSegmentIdentifier,
            presenterIdentifier: PushRouteSegmentPresenter.defaultPresenterIdentifier,
            isSingleton: true,
            loadViewController:{ return {
                let result = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(String(NextScreenViewController)) as! NextScreenViewController

                result.navigationItem.hidesBackButton = true
                let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.nextScreenBack))
                result.navigationItem.leftBarButtonItem = newBackButton;

                result.returnAction = {
                    self.container.router.executeRoute(self.welcomeRouteSequence)
                }
                result.wrapAction = {
                    self.container.router.appendRoute([self.wrapperSegmentIdentifier])
                }
                return result
                } }
        )
    }

    private func buildWrapperSegment() -> RouteSegment  {
        return RouteSegment(
            segmentIdentifier: wrapperSegmentIdentifier,
            presenterIdentifier: WrappingRouteSegmentPresenter.defaultPresenterIdentifier,
            isSingleton: true,
            loadViewController:{ return {
                let result = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(String(WrapperViewController)) as! WrapperViewController

                result.unwrapAction = {
                    print("do unwrap")
                }
                return result
                } }
        )
    }

    @objc func nextScreenBack(bbi: UIBarButtonItem) {
        self.container.router.executeRoute(self.welcomeRouteSequence)
    }
    
    let container: ApplicationContainerType
}