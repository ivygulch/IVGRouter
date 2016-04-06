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

    required init?(container: ApplicationContainerType) {
        self.container = container
    }

    func registerRouteSegments(router: RouterType) {
        router.registerRouteSegment(rootRouteSegment())
        router.registerRouteSegment(welcomeRouteSegment())
        router.registerRouteSegment(page2RouteSegment())
    }

    private func rootRouteSegment() -> RouteSegment {
        return RouteSegment(segmentType: DemoAppRouteSegmentTypes.Root, presentationType: .Root) {
            return { return RootViewController() }
        }
    }

    private func welcomeRouteSegment() -> RouteSegment  {
        return RouteSegment(segmentType: DemoAppRouteSegmentTypes.Welcome, presentationType: .PopStack) {
            return {
                let result = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("WelcomeViewController") as! WelcomeViewController
                result.nextAction = {
                    self.container.router.executeRoute([
                        DemoAppRouteSegmentTypes.Root,
                        DemoAppRouteSegmentTypes.Welcome,
                        DemoAppRouteSegmentTypes.Page2
                        ])
                }
                return result
            }
        }
    }

    private func page2RouteSegment() -> RouteSegment  {
        return RouteSegment(segmentType: DemoAppRouteSegmentTypes.Page2, presentationType: .Push) {
            return {
                let result = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("NextScreenViewController") as! NextScreenViewController

                result.navigationItem.hidesBackButton = true
                let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.nextScreenBack))
                result.navigationItem.leftBarButtonItem = newBackButton;

                result.returnAction = {
                    self.container.router.executeRoute([
                        DemoAppRouteSegmentTypes.Root,
                        DemoAppRouteSegmentTypes.Welcome
                        ])
                }
                return result
            }
        }
    }

    @objc func nextScreenBack(bbi: UIBarButtonItem) {
        self.container.router.executeRoute([
            DemoAppRouteSegmentTypes.Root,
            DemoAppRouteSegmentTypes.Welcome
            ])
    }
    
    let container: ApplicationContainerType
}