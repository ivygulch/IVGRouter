//
//  DemoRouteCoordinator.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 3/21/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation
import IVGRouter

enum DemoSequenceType {
    case execute
    case branch(branch: RouteBranch)
    case append
}

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

    let tab1BranchIdentifier = Identifier(name: "B1")
    let tab2BranchIdentifier = Identifier(name: "B2")

    lazy var routeSequenceWelcome: [Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier]
    lazy var routeSequenceWA: [Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier,self.pushASegmentIdentifier]
    lazy var routeSequenceWAB: [Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier,self.pushASegmentIdentifier,self.pushBSegmentIdentifier]
    lazy var routeSequenceWABC: [Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier,self.pushASegmentIdentifier,self.pushBSegmentIdentifier,self.pushCSegmentIdentifier]
    lazy var routeSequenceWD: [Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier,self.pushDSegmentIdentifier]
    lazy var routeSequenceWDE: [Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier,self.pushDSegmentIdentifier,self.pushESegmentIdentifier]
    lazy var routeSequenceWDEF: [Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier,self.pushDSegmentIdentifier,self.pushESegmentIdentifier,self.pushFSegmentIdentifier]
    lazy var routeSequenceWDEFG: [Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier,self.pushDSegmentIdentifier,self.pushESegmentIdentifier,self.pushFSegmentIdentifier,self.pushGSegmentIdentifier]
    lazy var routeSequenceWAFE: [Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier,self.pushASegmentIdentifier,self.pushFSegmentIdentifier,self.pushESegmentIdentifier]
    lazy var routeSequenceWrapper: [Any] = [self.wrapperSegmentIdentifier]

    lazy var routeBranchSequenceTab1: [Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier,self.pushTBCSegmentIdentifier,self.tab1SegmentIdentifier]
    lazy var routeBranchSequenceTab2: [Any] = [self.rootSegmentIdentifier,self.pushWelcomeSegmentIdentifier,self.pushTBCSegmentIdentifier,self.tab2SegmentIdentifier]

    lazy var routeSequenceNCA: [Any] = [self.setNCSegmentIdentifier,self.pushASegmentIdentifier]
    lazy var routeSequenceNCAF: [Any] = [self.setNCSegmentIdentifier,self.pushASegmentIdentifier,self.pushFSegmentIdentifier]
    lazy var routeSequenceZ: [Any] = [self.setZSegmentIdentifier]

    lazy var routeBranchTab1: RouteBranch = RouteBranch(branchIdentifier: self.tab1BranchIdentifier, routeSequence: RouteSequence(source: self.routeBranchSequenceTab1))
    lazy var routeBranchTab2: RouteBranch = RouteBranch(branchIdentifier: self.tab2BranchIdentifier, routeSequence: RouteSequence(source: self.routeBranchSequenceTab2))

    lazy var sequences: [(String,(DemoSequenceType,[Any]))] = [
        ("Welcome", (.execute,self.routeSequenceWelcome)),
        ("WA", (.execute,self.routeSequenceWA)),
        ("WAB", (.execute,self.routeSequenceWAB)),
        ("WABC", (.execute,self.routeSequenceWABC)),
        ("WD", (.execute,self.routeSequenceWD)),
        ("WDE", (.execute,self.routeSequenceWDE)),
        ("WDEF", (.execute,self.routeSequenceWDEF)),
        ("WDEFG", (.execute,self.routeSequenceWDEFG)),
        ("WAFE", (.execute,self.routeSequenceWAFE)),
        ("T1.NCA", (.branch(branch: self.routeBranchTab1),self.routeSequenceNCA)),
        ("T1.NCAF", (.branch(branch: self.routeBranchTab1),self.routeSequenceNCAF)),
        ("T2.Z", (.branch(branch: self.routeBranchTab2),self.routeSequenceZ)),
        ("Wrapper", (.append,self.routeSequenceWrapper))
    ]

    init(window: UIWindow?) {
        router = Router(window: window)
        router.registerDefaultPresenters()
        registerRouteSegments()
    }

    func startupAction() {
        router.execute(route: routeSequenceWelcome) { _ in }
    }

    func registerRouteSegments() {
        router.register(routeSegment: buildRootSegment())
        router.register(routeSegment: buildPushSegment(pushWelcomeSegmentIdentifier))
        router.register(routeSegment: buildPushSegment(pushASegmentIdentifier))
        router.register(routeSegment: buildPushSegment(pushBSegmentIdentifier))
        router.register(routeSegment: buildPushSegment(pushCSegmentIdentifier))
        router.register(routeSegment: buildPushSegment(pushDSegmentIdentifier))
        router.register(routeSegment: buildPushSegment(pushESegmentIdentifier))
        router.register(routeSegment: buildPushSegment(pushFSegmentIdentifier))
        router.register(routeSegment: buildPushSegment(pushGSegmentIdentifier))
        router.register(routeSegment: buildTrunkSegment(pushTBCSegmentIdentifier))
        router.register(routeSegment: buildBranchSegment(tab1SegmentIdentifier))
        router.register(routeSegment: buildSetNCSegment(setNCSegmentIdentifier))
        router.register(routeSegment: buildBranchSegment(tab2SegmentIdentifier))
        router.register(routeSegment: buildSetSegment(setZSegmentIdentifier))
        router.register(routeSegment: buildWrapperSegment())

        router.register(routeBranch: routeBranchTab1);
        router.register(routeBranch: routeBranchTab2);
    }

    fileprivate func buildRootSegment() -> VisualRouteSegmentType {
        return buildVisualSegment(rootSegmentIdentifier, presenterIdentifier: RootRouteSegmentPresenter.defaultPresenterIdentifier, viewControllerLoaderFunction: {
            return {
                return RootViewController()
            }
        })
    }

    fileprivate func buildTrunkSegment(_ segmentIdentifier: Identifier) -> VisualRouteSegmentType {
        return VisualRouteSegment(
            segmentIdentifier: segmentIdentifier,
            presenterIdentifier: PushRouteSegmentPresenter.defaultPresenterIdentifier,
            isSingleton: true,
            loadViewController: { return {
                let result = TabBarController(name: segmentIdentifier.name)
                result.view.backgroundColor = UIColor.orange

                result.rightAction = {
                    self.displayOptionMenu(result)
                }

                result.backAction = {
                    self.router.pop() { _ in }
                }

                return result
                } }
        )
    }

    fileprivate func buildBranchSegment(_ segmentIdentifier: Identifier) -> BranchRouteSegmentType {
        return BranchRouteSegment(
            segmentIdentifier: segmentIdentifier,
            presenterIdentifier: BranchRouteSegmentPresenter.defaultPresenterIdentifier
        )
    }

    func defaultViewControllerLoader(_ segmentIdentifier: Identifier) -> ViewControllerLoaderFunction {
        return {
            return {
                let result = ViewController(name: segmentIdentifier.name)

                for (title,(type,sequence)) in self.sequences {
                    _ = result.addAction(title, action: {
                        switch type {
                        case .execute: 
                            self.router.execute(route: sequence) { _ in }
                        case .branch(let branch): 
                            self.router.execute(route: sequence, toRouteBranch: branch) { _ in }
                        case .append: 
                            self.router.append(route: sequence) { _ in }
                        }
                    })
                }

                result.rightAction = {
                    self.displayOptionMenu(result)
                }

                result.backAction = {
                    self.router.pop() { _ in }
                }
                
                return result
            }
        }
    }

    fileprivate func buildPushSegment(_ segmentIdentifier: Identifier) -> VisualRouteSegmentType  {
        return buildVisualSegment(segmentIdentifier, presenterIdentifier: PushRouteSegmentPresenter.defaultPresenterIdentifier, viewControllerLoaderFunction: defaultViewControllerLoader(segmentIdentifier))
    }

    fileprivate func buildSetSegment(_ segmentIdentifier: Identifier) -> VisualRouteSegmentType  {
        return buildVisualSegment(segmentIdentifier, presenterIdentifier: SetRouteSegmentPresenter.defaultPresenterIdentifier, viewControllerLoaderFunction: defaultViewControllerLoader(segmentIdentifier))
    }
    
    fileprivate func buildSetNCSegment(_ segmentIdentifier: Identifier) -> VisualRouteSegmentType  {
        return buildVisualSegment(segmentIdentifier, presenterIdentifier: SetRouteSegmentPresenter.defaultPresenterIdentifier, viewControllerLoaderFunction: {
            {
                return UINavigationController()
            }
        })
    }

    fileprivate func buildVisualSegment(_ segmentIdentifier: Identifier, presenterIdentifier: Identifier, viewControllerLoaderFunction: @escaping ViewControllerLoaderFunction) -> VisualRouteSegmentType  {
        return VisualRouteSegment(
            segmentIdentifier: segmentIdentifier,
            presenterIdentifier: presenterIdentifier,
            isSingleton: true,
            loadViewController: viewControllerLoaderFunction
        )
    }

    fileprivate func debug(_ vc: UIViewController) {
        print("debug: \(type(of: vc))")
        if let rvc = router.window?.rootViewController {
            debug(rvc, margin: "  ")
        }
    }

    fileprivate func debug(_ vc: UIViewController, margin: String) {
        print("\(margin)\(vc)")
        for childVC in vc.childViewControllers {
            debug(childVC, margin: margin+"  ")
        }
    }

    fileprivate func buildWrapperSegment() -> VisualRouteSegment  {
        return VisualRouteSegment(
            segmentIdentifier: wrapperSegmentIdentifier,
            presenterIdentifier: WrappingRouteSegmentPresenter.defaultPresenterIdentifier,
            isSingleton: true,
            loadViewController: { return {
                let result = ViewController(name: self.wrapperSegmentIdentifier.name)
                result.view.backgroundColor = UIColor.yellow

                result.didAppearAction = {
                    self.router.debug("unwrap didAppear")
                }

                _ = result.addAction("Unwrap", titleColor: UIColor.black, action: {
                    self.router.debug("before unwrap")
                    self.router.pop() { _ in
                        self.router.debug("after unwrap")
                    }
                })

                return result
                } }
        )
    }

    fileprivate func displayOptionMenu(_ viewController: UIViewController) {
        let alert = UIAlertController(title: "options", message: "Options", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "debug", style: .default) { _ in
            self.debug(viewController)
            self.router.debug("debug")
            })
        if let previousItem = router.previousRouteHistoryItem() {
            let title = "back [\(previousItem.title ?? "")]"
            alert.addAction(UIAlertAction(title: title, style: .default) { _ in
                self.router.goBack() { _ in }
                })
        }
        if let nextItem = router.nextRouteHistoryItem() {
            let title = "next [\(nextItem.title ?? "")]"
            alert.addAction(UIAlertAction(title: title, style: .default) { _ in
                self.router.goForward() { _ in }
                })
        }
        viewController.present(alert, animated: true) {}
    }

}
