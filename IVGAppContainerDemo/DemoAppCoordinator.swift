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

protocol DemoAppCoordinatorType: AppCoordinatorType {
}

class DemoAppCoordinator: DemoAppCoordinatorType {

    let rootSegmentIdentifier = Identifier(name: "DemoAppCoordinator.root")
    let welcomeSegmentIdentifier = Identifier(name: "DemoAppCoordinator.welcome")
    let page2SegmentIdentifier = Identifier(name: "DemoAppCoordinator.page2")

    lazy var welcomeRouteSequence:[Any] = [self.rootSegmentIdentifier,self.welcomeSegmentIdentifier]
    lazy var page2RouteSequence:[Any] = [self.rootSegmentIdentifier,self.welcomeSegmentIdentifier,self.page2SegmentIdentifier]

    required init?(container: ApplicationContainerType) {
        self.container = container
    }

    func registerRouteSegments(router: RouterType) {
        router.registerRouteSegment(buildRootSegment())
        router.registerRouteSegment(buildWelcomeSegment())
        router.registerRouteSegment(buildPage2Segment())
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
                let result = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("WelcomeViewController") as! WelcomeViewController
                result.nextAction = {
                    self.container.router.executeRoute(self.page2RouteSequence)
                }
                return result
                } }
        )
    }

    private func buildPage2Segment() -> RouteSegment  {
        return RouteSegment(
            segmentIdentifier: page2SegmentIdentifier,
            presenterIdentifier: PushRouteSegmentPresenter.defaultPresenterIdentifier,
            isSingleton: true,
            loadViewController:{ return {
                let result = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("NextScreenViewController") as! NextScreenViewController

                result.navigationItem.hidesBackButton = true
                let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.nextScreenBack))
                result.navigationItem.leftBarButtonItem = newBackButton;

                result.returnAction = {
                    self.container.router.executeRoute(self.welcomeRouteSequence)
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