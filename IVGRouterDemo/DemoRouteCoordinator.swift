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

    let rootSegmentIdentifier = Identifier(name: "ID.root")
    let pushWelcomeSegmentIdentifier = Identifier(name: "ID.welcome")
    let pushASegmentIdentifier = Identifier(name: "ID.a")
    let pushBSegmentIdentifier = Identifier(name: "ID.b")
    let pushCSegmentIdentifier = Identifier(name: "ID.c")
    let pushDSegmentIdentifier = Identifier(name: "ID.d")
    let pushESegmentIdentifier = Identifier(name: "ID.e")
    let pushFSegmentIdentifier = Identifier(name: "ID.f")
    let pushGSegmentIdentifier = Identifier(name: "ID.g")
    let pushTBCSegmentIdentifier = Identifier(name: "ID.tbc")
    let tab1SegmentIdentifier = Identifier(name: "ID.tab1")
    let setNCSegmentIdentifier = Identifier(name: "ID.setNC")
    let tab2SegmentIdentifier = Identifier(name: "ID.tab2")
    let setZSegmentIdentifier = Identifier(name: "ID.setZ")
    let wrapperSegmentIdentifier = Identifier(name: "ID.wrapper")

    lazy var routeSequenceWelcome:[Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier]
    lazy var routeSequenceWA:[Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier,self.pushASegmentIdentifier]
    lazy var routeSequenceWAB:[Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier,self.pushASegmentIdentifier,self.pushBSegmentIdentifier]
    lazy var routeSequenceWABC:[Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier,self.pushASegmentIdentifier,self.pushBSegmentIdentifier,self.pushCSegmentIdentifier]
    lazy var routeSequenceWD:[Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier,self.pushDSegmentIdentifier]
    lazy var routeSequenceWDE:[Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier,self.pushDSegmentIdentifier,self.pushESegmentIdentifier]
    lazy var routeSequenceWDEF:[Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier,self.pushDSegmentIdentifier,self.pushESegmentIdentifier,self.pushFSegmentIdentifier]
    lazy var routeSequenceWDEFG:[Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier,self.pushDSegmentIdentifier,self.pushESegmentIdentifier,self.pushFSegmentIdentifier,self.pushGSegmentIdentifier]
    lazy var routeSequenceWAFE:[Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier,self.pushASegmentIdentifier,self.pushFSegmentIdentifier,self.pushESegmentIdentifier]
    lazy var routeSequenceWrapper:[Any] = [self.wrapperSegmentIdentifier]

    lazy var routeBranchSequenceTab1:[Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier,self.pushTBCSegmentIdentifier,self.tab1SegmentIdentifier]
    lazy var routeBranchSequenceTab2:[Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier,self.pushTBCSegmentIdentifier,self.tab2SegmentIdentifier]

    lazy var routeSequenceNCA:[Any] = [self.setNCSegmentIdentifier,self.pushASegmentIdentifier]
    lazy var routeSequenceNCAF:[Any] = [self.setNCSegmentIdentifier,self.pushASegmentIdentifier,self.pushFSegmentIdentifier]
    lazy var routeSequenceZ:[Any] = [self.setZSegmentIdentifier]

    lazy var sequences:[(String,[Any])] = [
        ("Welcome", self.routeSequenceWelcome),
        ("WA", self.routeSequenceWA),
        ("WAB", self.routeSequenceWAB),
        ("WABC", self.routeSequenceWABC),
        ("WD", self.routeSequenceWD),
        ("WDE", self.routeSequenceWDE),
        ("WDEF", self.routeSequenceWDEF),
        ("WDEFG", self.routeSequenceWDEFG),
        ("WAFE", self.routeSequenceWAFE),
        ("NCA", self.routeSequenceNCA),
        ("NCAF", self.routeSequenceNCAF),
        ("Z", self.routeSequenceZ),
        ("Wrapper", self.routeSequenceWrapper)
    ]

    lazy var routeBranchTab1: RouteBranch = RouteBranch(branchIdentifier: self.tab1SegmentIdentifier, routeSequence: RouteSequence(source: self.routeBranchSequenceTab1))
    lazy var routeBranchTab2: RouteBranch = RouteBranch(branchIdentifier: self.tab2SegmentIdentifier, routeSequence: RouteSequence(source: self.routeBranchSequenceTab2))

    init(window: UIWindow?) {
        router = Router(window: window)
        router.registerDefaultPresenters()
        registerRouteSegments()
    }

    func executeDefaultRouteSequence() {
        router.executeRoute(routeSequenceWelcome) {
            _ in
        }
    }

    func registerRouteSegments() {
        router.registerRouteSegment(buildRootSegment())
        router.registerRouteSegment(buildPushSegment(pushWelcomeSegmentIdentifier))
        router.registerRouteSegment(buildPushSegment(pushASegmentIdentifier))
        router.registerRouteSegment(buildPushSegment(pushBSegmentIdentifier))
        router.registerRouteSegment(buildPushSegment(pushCSegmentIdentifier))
        router.registerRouteSegment(buildPushSegment(pushDSegmentIdentifier))
        router.registerRouteSegment(buildPushSegment(pushESegmentIdentifier))
        router.registerRouteSegment(buildPushSegment(pushFSegmentIdentifier))
        router.registerRouteSegment(buildPushSegment(pushGSegmentIdentifier))
        router.registerRouteSegment(buildTrunkSegment(pushTBCSegmentIdentifier))
        router.registerRouteSegment(buildBranchSegment(tab1SegmentIdentifier))
        router.registerRouteSegment(buildSetNCSegment(setNCSegmentIdentifier))
        router.registerRouteSegment(buildBranchSegment(tab2SegmentIdentifier))
        router.registerRouteSegment(buildSetSegment(setZSegmentIdentifier))
        router.registerRouteSegment(buildWrapperSegment())

        router.registerRouteBranch(routeBranchTab1);
        router.registerRouteBranch(routeBranchTab2);
    }

    private func buildRootSegment() -> VisualRouteSegmentType {
        return buildVisualSegment(rootSegmentIdentifier, presenterIdentifier: RootRouteSegmentPresenter.defaultPresenterIdentifier, viewControllerLoaderFunction: {
            return {
                return RootViewController()
            }
        })
    }

    private func buildTrunkSegment(segmentIdentifier: Identifier) -> VisualRouteSegmentType {
        return VisualRouteSegment(
            segmentIdentifier: segmentIdentifier,
            presenterIdentifier: PushRouteSegmentPresenter.defaultPresenterIdentifier,
            isSingleton: true,
            loadViewController:{ return {
                let result = TabBarController(name: segmentIdentifier.name)

                result.rightAction = {
                    self.debug(result)
                    self.router.debug("debug")
                }

                result.backAction = {
                    self.router.popRoute() {
                        _ in
                    }
                }

                return result
                } }
        )
    }

    private func buildBranchSegment(segmentIdentifier: Identifier) -> BranchRouteSegmentType {
        return BranchRouteSegment(
            segmentIdentifier: segmentIdentifier,
            presenterIdentifier: BranchRouteSegmentPresenter.defaultPresenterIdentifier
        )
    }

    func defaultViewControllerLoader(segmentIdentifier: Identifier) -> ViewControllerLoaderFunction {
        return {
            return {
                let result = ViewController(name: segmentIdentifier.name)

                for (title,sequence) in self.sequences {
                    result.addAction(title, action: {
                        self.router.executeRoute(sequence) {
                            _ in
                        }
                    })
                }

                result.rightAction = {
                    self.debug(result)
                    self.router.debug("debug")
                }

                result.backAction = {
                    self.router.popRoute() {
                        _ in
                    }
                }
                
                return result
            }
        }
    }

    private func buildPushSegment(segmentIdentifier: Identifier) -> VisualRouteSegmentType  {
        return buildVisualSegment(segmentIdentifier, presenterIdentifier: PushRouteSegmentPresenter.defaultPresenterIdentifier, viewControllerLoaderFunction: defaultViewControllerLoader(segmentIdentifier))
    }

    private func buildSetSegment(segmentIdentifier: Identifier) -> VisualRouteSegmentType  {
        return buildVisualSegment(segmentIdentifier, presenterIdentifier: SetRouteSegmentPresenter.defaultPresenterIdentifier, viewControllerLoaderFunction: defaultViewControllerLoader(segmentIdentifier))
    }
    
    private func buildSetNCSegment(segmentIdentifier: Identifier) -> VisualRouteSegmentType  {
        return buildVisualSegment(segmentIdentifier, presenterIdentifier: SetRouteSegmentPresenter.defaultPresenterIdentifier, viewControllerLoaderFunction: {
            {
                return UINavigationController()
            }
        })
    }

    private func buildVisualSegment(segmentIdentifier: Identifier, presenterIdentifier: Identifier, viewControllerLoaderFunction: ViewControllerLoaderFunction) -> VisualRouteSegmentType  {
        return VisualRouteSegment(
            segmentIdentifier: segmentIdentifier,
            presenterIdentifier: presenterIdentifier,
            isSingleton: true,
            loadViewController: viewControllerLoaderFunction
        )
    }

    private func debug(vc: UIViewController) {
        print("debug: \(vc.dynamicType)")
        if let rvc = router.window?.rootViewController {
            debug(rvc, margin:"  ")
        }
    }

    private func debug(vc: UIViewController, margin: String) {
        print("\(margin)\(vc)")
        for childVC in vc.childViewControllers {
            debug(childVC, margin: margin+"  ")
        }
    }

    private func buildWrapperSegment() -> VisualRouteSegment  {
        return VisualRouteSegment(
            segmentIdentifier: wrapperSegmentIdentifier,
            presenterIdentifier: WrappingRouteSegmentPresenter.defaultPresenterIdentifier,
            isSingleton: true,
            loadViewController:{ return {
                let result = ViewController(name: self.wrapperSegmentIdentifier.name)

                result.addAction("Unwrap", action: {
                    self.router.popRoute() {
                        _ in
                    }
                })

                return result
                } }
        )
    }

}