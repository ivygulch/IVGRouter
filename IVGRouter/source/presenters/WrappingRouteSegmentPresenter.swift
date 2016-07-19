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

    var prepareForViewUnwrappingAnimation: ((UIViewController,UIViewController) -> ViewAnimationInfoType) { get }
    var animateViewUnwrapping: ((UIViewController,UIViewController,ViewAnimationInfoType) -> ViewAnimationInfoType) { get }
    var completeViewUnwrappingAnimation: ((UIViewController,UIViewController,ViewAnimationInfoType) -> Void) { get }
}

public class WrappingRouteSegmentPresenter : BaseRouteSegmentPresenter, VisualRouteSegmentPresenterType, ReversibleRouteSegmentPresenterType {

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

    public func presentViewController(presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: (RoutingResult -> Void)) {
        guard let child = presentingViewController else {
            verify(checkNotNil(presentingViewController, "presentingViewController"), completion: completion)
            return
        }
        if presentedViewController == child {
            // TODO: this case seems like a bug
            unwrapChild(child, fromWrapper: presentedViewController, completion: completion)
        } else {
            wrapChild(child, inWrapper: presentedViewController, completion: completion)
        }
    }

    public func reversePresentation(viewControllerToRemove: UIViewController, completion: (RoutingResult -> Void)) {
        let parent = viewControllerToRemove.parentViewController
        guard let _ = parent else {
            verify(checkNotNil(parent, "parent"), completion: completion)
            return
        }
        let firstChild = viewControllerToRemove.childViewControllers.first
        guard let child = firstChild else {
            verify(checkNotNil(firstChild, "child"), completion: completion)
            return
        }

        unwrapChild(child, fromWrapper: viewControllerToRemove, completion: completion)
    }

    // MARK: wrapping methods

    private func wrapChild(child: UIViewController, inWrapper wrapper : UIViewController, completion: (RoutingResult -> Void)) {
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
                completion(.Success(wrapper))
            }
        )
    }

    private func startWrappingViewController(child: UIViewController, inWrapper wrapper : UIViewController) -> (Void -> Void) {
        let parent = child.parentViewController
        if let navigationController = parent as? UINavigationController {
            return startWrappingNavigationController(navigationController, withChild: child, inWrapper: wrapper)
        } else if let _ = parent as? UISplitViewController {
            // TODO: splitViewController not handled yet
            print("WARNING: splitViewController not handled yet")
            return {}
        } else if let _ = parent as? UITabBarController {
            // TODO: tabBarController not handled yet
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
        return {
            child.didMoveToParentViewController(wrapper)
        }
    }

    // MARK: unwrapping methods

    private func unwrapChild(child: UIViewController, fromWrapper wrapper: UIViewController, completion: (RoutingResult -> Void))  {
        let parent = wrapper.parentViewController!
        let child = wrapper.childViewControllers.first!
        child.willMoveToParentViewController(parent)

        var frame = child.view.frame
        frame.origin.x = 0

        let finishUnwrappingViewControllerBlock = startUnwrappingViewController(child, fromWrapper: wrapper)

        var viewAnimationInfo = wrappingRouteSegmentAnimator.prepareForViewUnwrappingAnimation(child, wrapper)

        UIView.animateWithDuration(
            wrappingRouteSegmentAnimator.animationDuration,
            animations:{
                viewAnimationInfo = self.wrappingRouteSegmentAnimator.animateViewUnwrapping(child, wrapper, viewAnimationInfo)
            },
            completion: {
                finished in
                self.wrappingRouteSegmentAnimator.completeViewUnwrappingAnimation(child, wrapper, viewAnimationInfo)
                finishUnwrappingViewControllerBlock()
                completion(.Success(wrapper))
            }
        )

    }

    private func startUnwrappingViewController(child: UIViewController, fromWrapper wrapper : UIViewController) -> (Void -> Void) {
        let parent = wrapper.parentViewController
        if let navigationController = parent as? UINavigationController {
            return startUnwrappingNavigationController(navigationController, withChild: child, fromWrapper: wrapper)
        } else if let _ = parent as? UISplitViewController {
            // TODO: splitViewController not handled yet
            print("WARNING: splitViewController not handled yet")
            return {}
        } else if let _ = parent as? UITabBarController {
            // TODO: tabBarController not handled yet
            print("WARNING: tabBarController not handled yet")
            return {}
        } else {
            return startUnwrappingBasicController(child, fromWrapper: wrapper)
        }
    }

    private func startUnwrappingBasicController(child: UIViewController, fromWrapper wrapper: UIViewController) -> (Void -> Void) {
        let parent = child.parentViewController

        return {
            // do not just add the child back to the parent's view, there were potentially other views in there previously
            wrapper.view.superview?.addSubview(child.view)
            wrapper.view.removeFromSuperview()
            parent?.addChildViewController(child)
            wrapper.willMoveToParentViewController(nil)
            wrapper.removeFromParentViewController()
        }
    }

    private func startUnwrappingNavigationController(navigationController: UINavigationController, withChild child: UIViewController, fromWrapper wrapper : UIViewController) -> (Void -> Void) {
        // UINavigationController will handle *some* of the add/move stuff for us
        var viewControllers = navigationController.viewControllers
        guard let index = viewControllers.indexOf(wrapper) else {
            print("WARNING: parentViewController was UINavigationController, but wrapper was not in the list of viewControllers")
            return {}
        }

        let parent = wrapper.parentViewController
        return {
            wrapper.view.superview?.addSubview(child.view)
            viewControllers[index] = child
            navigationController.viewControllers = viewControllers
            child.didMoveToParentViewController(parent)
        }
    }
    

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