//
//  WrappingRouteSegmentPresenter.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/8/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public typealias ViewAnimationInfoType = [String:AnyObject]

public protocol WrappingRouteSegmentAnimator {
    var animationDuration: NSTimeInterval { get }

    var prepareForViewWrappingAnimation: ((UIViewController,UIViewController) -> ViewAnimationInfoType) { get }
    var animateViewWrapping: ((UIViewController,UIViewController,ViewAnimationInfoType) -> ViewAnimationInfoType) { get }
    var completeViewWrappingAnimation: ((UIViewController,UIViewController,ViewAnimationInfoType) -> Void) { get }

//    var prepareForViewUnwrappingAnimation: ((UIViewController,UIViewController) -> ViewAnimationInfoType) { get }
//    var animateViewUnwrapping: ((UIViewController,UIViewController,ViewAnimationInfoType) -> ViewAnimationInfoType) { get }
//    var completeViewUnwrappingAnimation: ((UIViewController,UIViewController,ViewAnimationInfoType) -> Void) { get }
}

public class WrappingRouteSegmentPresenter : BaseRouteSegmentPresenter, RouteSegmentPresenterType {

    // MARK: public methods

    public static let defaultPresenterIdentifier = Identifier(name: String(WrappingRouteSegmentPresenter))

    public init(wrappingRouteSegmentAnimator: WrappingRouteSegmentAnimator) {
        self.wrappingRouteSegmentAnimator = wrappingRouteSegmentAnimator
        super.init()
    }

    public init(presenterIdentifier: Identifier, wrappingRouteSegmentAnimator: WrappingRouteSegmentAnimator) {
        self.wrappingRouteSegmentAnimator = wrappingRouteSegmentAnimator
        super.init(presenterIdentifier: presenterIdentifier)
    }

    public func presentViewController(presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: ((Bool) -> Void)) -> UIViewController?{
        guard let child = presentingViewController else {
            verify(checkNotNil(presentingViewController, "presentingViewController"), completion: completion)
            return nil
        }
        if presentedViewController == child {
            return unwrapChild(child, fromWrapper: presentedViewController, completion: completion)
        } else {
            return wrapChild(child, inWrapper: presentedViewController, completion: completion)
        }
    }

    // MARK: wrapping methods

    private func wrapChild(child: UIViewController, inWrapper wrapper : UIViewController, completion: ((Bool) -> Void)) -> UIViewController {
        let parent = child.parentViewController
        let previousChildViewIndex = parent?.view.subviews.indexOf(child.view)

        wrapper.view.frame = child.view.bounds
        wrapper.view.addSubview(child.view)

        if let parent = parent,
            let previousChildViewIndex = previousChildViewIndex {
            parent.view.insertSubview(parent.view, atIndex: previousChildViewIndex)
        }

        let finishWrappingViewControllerBlock = startWrappingViewController(child, inWrapper: wrapper)

        var viewAnimationInfo = wrappingRouteSegmentAnimator.prepareForViewWrappingAnimation(child, wrapper)

        UIView.animateWithDuration(
            wrappingRouteSegmentAnimator.animationDuration,
            animations:{
                viewAnimationInfo = self.wrappingRouteSegmentAnimator.animateViewWrapping(child, wrapper, viewAnimationInfo)
            },
            completion: {
                finished in
                self.wrappingRouteSegmentAnimator.completeViewWrappingAnimation(child, wrapper, viewAnimationInfo)
                finishWrappingViewControllerBlock()
                completion(true)
            }
        )

        return wrapper
    }

    private func startWrappingViewController(child: UIViewController, inWrapper wrapper : UIViewController) -> (Void -> Void) {
        let parent = child.parentViewController
        if let navigationController = parent as? UINavigationController {
            return startWrappingNavigationController(navigationController, withChild: child, inWrapper: wrapper)
        } else if let _ = parent as? UISplitViewController {
            print("WARNING: splitViewController not handled yet")
            return {}
        } else if let _ = parent as? UITabBarController {
            print("WARNING: tabBarController not handled yet")
            return {}
        } else {
            return startWrappingBasicController(child, inWrapper: wrapper)
        }
    }

    private func startWrappingBasicController(child: UIViewController, inWrapper wrapper: UIViewController) -> (Void -> Void) {
        let parent = child.parentViewController
        wrapper.addChildViewController(child)
        parent?.addChildViewController(wrapper)
        return {
            wrapper.didMoveToParentViewController(parent)
            child.didMoveToParentViewController(wrapper)
        }
    }

    private func startWrappingNavigationController(navigationController: UINavigationController, withChild child: UIViewController, inWrapper wrapper : UIViewController) -> (Void -> Void) {
        // UINavigationController will handle *some* of the add/move stuff for us
        var viewControllers = navigationController.viewControllers
        guard let index = viewControllers.indexOf(child) else {
            print("WARNING: parentViewController was UINavigationController, but child was not in the list of viewControllers")
            return {}
        }

        wrapper.navigationItem.setValuesFrom(child.navigationItem)
        wrapper.addChildViewController(child)
        child.didMoveToParentViewController(wrapper)

        viewControllers[index] = wrapper
        navigationController.viewControllers = viewControllers
        return { child.didMoveToParentViewController(wrapper) }
    }

    // MARK: unwrapping methods

    private func unwrapChild(child: UIViewController, fromWrapper wrapper: UIViewController, completion: ((Bool) -> Void)) -> UIViewController {
        let parent = wrapper.parentViewController!
        let child = wrapper.childViewControllers.first!
        child.willMoveToParentViewController(parent)

        var frame = child.view.frame
        frame.origin.x = 0

        UIView.animateWithDuration(
            0.3,
            animations: {
                child.view.frame = frame
            },
            completion: {
                finished in

                parent.view.addSubview(child.view)
                wrapper.view.removeFromSuperview()
                parent.addChildViewController(child)
                wrapper.willMoveToParentViewController(nil)
                wrapper.removeFromParentViewController()
                completion(true)
            }
        )

        return child
    }

    //    if let navigationController = presentedViewController.navigationController,
    //    let actualChild = presentedViewController.childViewControllers.first {
    //        return unwrapChild(actualChild, toNavigationController: navigationController, withMenu: presentedViewController, completion: completion)
    //    } else {
    //    return remove(presentedViewController, completion: completion)
    //    }
    /*
     func unwrapChild2(child: UIViewController, fromWrapper wrapper: UIViewController, completion: ((Bool) -> Void)) -> UIViewController {
     var newViewControllers = navigationController.viewControllers
     if let index = newViewControllers.indexOf(menu) {
     newViewControllers[index] = child
     }

     child.willMoveToParentViewController(navigationController)

     var frame = child.view.frame
     frame.origin.x = 0

     UIView.animateWithDuration(
     0.3,
     animations: {
     child.view.frame = frame
     },
     completion: {
     finished in

     menu.view.removeFromSuperview()
     menu.willMoveToParentViewController(nil)

     navigationController.viewControllers = newViewControllers
     child.didMoveToParentViewController(navigationController)
     navigationController.popViewControllerAnimated(true)
     completion(true)
     }
     )

     return child
     }
     */

    // MARK: private variables

    private var wrappingRouteSegmentAnimator: WrappingRouteSegmentAnimator
}

extension UINavigationItem {

    private func setValuesFrom(fromNavigationItem: UINavigationItem) {
        title = fromNavigationItem.title
        titleView = fromNavigationItem.titleView
        prompt = fromNavigationItem.prompt
        backBarButtonItem = fromNavigationItem.backBarButtonItem
        hidesBackButton = fromNavigationItem.hidesBackButton
        leftBarButtonItems = fromNavigationItem.leftBarButtonItems
        rightBarButtonItems = fromNavigationItem.rightBarButtonItems
        leftItemsSupplementBackButton = fromNavigationItem.leftItemsSupplementBackButton
        hidesBackButton = fromNavigationItem.hidesBackButton
    }


}