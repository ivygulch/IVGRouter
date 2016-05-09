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
    let welcomeSegmentIdentifier = Identifier(name: "ID.welcome")
    let aSegmentIdentifier = Identifier(name: "ID.a")
    let bSegmentIdentifier = Identifier(name: "ID.b")
    let cSegmentIdentifier = Identifier(name: "ID.c")
    let dSegmentIdentifier = Identifier(name: "ID.d")
    let eSegmentIdentifier = Identifier(name: "ID.e")
    let fSegmentIdentifier = Identifier(name: "ID.f")
    let gSegmentIdentifier = Identifier(name: "ID.g")
    let wrapperSegmentIdentifier = Identifier(name: "ID.wrapper")

    lazy var routeSequenceWelcome:[Any] = [self.rootSegmentIdentifier,self.welcomeSegmentIdentifier]
    lazy var routeSequenceWA:[Any] = [self.rootSegmentIdentifier,self.welcomeSegmentIdentifier,self.aSegmentIdentifier]
    lazy var routeSequenceWAB:[Any] = [self.rootSegmentIdentifier,self.welcomeSegmentIdentifier,self.aSegmentIdentifier,self.bSegmentIdentifier]
    lazy var routeSequenceWABC:[Any] = [self.rootSegmentIdentifier,self.welcomeSegmentIdentifier,self.aSegmentIdentifier,self.bSegmentIdentifier,self.cSegmentIdentifier]
    lazy var routeSequenceWD:[Any] = [self.rootSegmentIdentifier,self.welcomeSegmentIdentifier,self.dSegmentIdentifier]
    lazy var routeSequenceWDE:[Any] = [self.rootSegmentIdentifier,self.welcomeSegmentIdentifier,self.dSegmentIdentifier,self.eSegmentIdentifier]
    lazy var routeSequenceWDEF:[Any] = [self.rootSegmentIdentifier,self.welcomeSegmentIdentifier,self.dSegmentIdentifier,self.eSegmentIdentifier,self.fSegmentIdentifier]
    lazy var routeSequenceWDEFG:[Any] = [self.rootSegmentIdentifier,self.welcomeSegmentIdentifier,self.dSegmentIdentifier,self.eSegmentIdentifier,self.fSegmentIdentifier,self.gSegmentIdentifier]
    lazy var routeSequenceWAFE:[Any] = [self.rootSegmentIdentifier,self.welcomeSegmentIdentifier,self.aSegmentIdentifier,self.fSegmentIdentifier,self.eSegmentIdentifier]
    lazy var routeSequenceWrapper:[Any] = [self.wrapperSegmentIdentifier]

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
        ("Wrapper", self.routeSequenceWrapper)
    ]

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
        router.registerRouteSegment(buildSegment(welcomeSegmentIdentifier))
        router.registerRouteSegment(buildSegment(aSegmentIdentifier))
        router.registerRouteSegment(buildSegment(bSegmentIdentifier))
        router.registerRouteSegment(buildSegment(cSegmentIdentifier))
        router.registerRouteSegment(buildSegment(dSegmentIdentifier))
        router.registerRouteSegment(buildSegment(eSegmentIdentifier))
        router.registerRouteSegment(buildSegment(fSegmentIdentifier))
        router.registerRouteSegment(buildSegment(gSegmentIdentifier))
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

    private func buildSegment(segmentIdentifier: Identifier) -> VisualRouteSegment  {
        return VisualRouteSegment(
            segmentIdentifier: segmentIdentifier,
            presenterIdentifier: PushRouteSegmentPresenter.defaultPresenterIdentifier,
            isSingleton: true,
            loadViewController:{ return {
                let result = ViewController(name: segmentIdentifier.name)

                for (title,sequence) in self.sequences {
                    result.addAction(title, action: {
                        self.router.executeRoute(sequence) {
                            _ in
                        }
                    })
                }

                result.addAction("Debug", action: {
                    self.debug(result)
                })

                return result
                } }
        )
    }

    private func debug(vc: UIViewController) {
        print("debug: \(vc.dynamicType)")
        let rvc = router.window!.rootViewController
        print("  root=\(rvc.dynamicType)")
        if let nc = rvc as? UINavigationController {
            print("  vc=\(nc.viewControllers)")
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