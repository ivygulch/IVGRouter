//
//  DemoRouteCoordinator.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 3/21/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation
import IVGRouter

class DemoRouteCoordinator {

    let router: Router

    let rootSegmentIdentifier = Identifier(name: "DemoRouteCoordinator.root")
    let welcomeSegmentIdentifier = Identifier(name: "DemoRouteCoordinator.welcome")
    let nextSegmentIdentifier = Identifier(name: "DemoRouteCoordinator.next")
    let wrapperSegmentIdentifier = Identifier(name: "DemoRouteCoordinator.wrapper")

    lazy var welcomeRouteSequence:[Any] = [self.rootSegmentIdentifier,self.welcomeSegmentIdentifier]
    lazy var nextRouteSequence:[Any] = [self.rootSegmentIdentifier,self.welcomeSegmentIdentifier,self.nextSegmentIdentifier]

    init(window: UIWindow?) {
        router = Router(window: window)
        router.registerDefaultPresenters()
        registerRouteSegments()
    }

    func executeDefaultRouteSequence() {
        router.executeRoute(welcomeRouteSequence)
    }

    func registerRouteSegments() {
        router.registerRouteSegment(buildRootSegment())
        router.registerRouteSegment(buildWelcomeSegment())
        router.registerRouteSegment(buildNextSegment())
        router.registerRouteSegment(buildWrapperSegment())
    }

    private func buildRootSegment() -> VisualRouteSegment {
        return VisualRouteSegment(
            segmentIdentifier: rootSegmentIdentifier,
            presenterIdentifier: RootRouteSegmentPresenter.defaultPresenterIdentifier,
            isSingleton: true,
            loadViewController:{ return { return RootViewController() } }
        )
    }

    private func buildWelcomeSegment() -> VisualRouteSegment  {
        return VisualRouteSegment(
            segmentIdentifier: welcomeSegmentIdentifier,
            presenterIdentifier: PushRouteSegmentPresenter.defaultPresenterIdentifier,
            isSingleton: true,
            loadViewController:{ return {
                let result = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(String(WelcomeViewController)) as! WelcomeViewController
                result.nextAction = {
                    self.router.executeRoute(self.nextRouteSequence)
                }
                return result
                } }
        )
    }

    private func buildNextSegment() -> VisualRouteSegment  {
        return VisualRouteSegment(
            segmentIdentifier: nextSegmentIdentifier,
            presenterIdentifier: PushRouteSegmentPresenter.defaultPresenterIdentifier,
            isSingleton: true,
            loadViewController:{ return {
                let result = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(String(NextScreenViewController)) as! NextScreenViewController

                result.navigationItem.hidesBackButton = true
                let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.nextScreenBack))
                result.navigationItem.leftBarButtonItem = newBackButton;

                result.returnAction = {
                    self.router.executeRoute(self.welcomeRouteSequence)
                }
                result.wrapAction = {
                    self.router.appendRoute([self.wrapperSegmentIdentifier])
                }
                return result
                } }
        )
    }

    private func buildWrapperSegment() -> VisualRouteSegment  {
        return VisualRouteSegment(
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
        self.router.executeRoute(self.welcomeRouteSequence)
    }
    
}