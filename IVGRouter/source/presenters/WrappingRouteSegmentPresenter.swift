//
//  WrappingRouteSegmentPresenter.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/8/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public typealias ViewAnimationInfoType = [String: AnyObject]

public protocol WrappingRouteSegmentAnimator {
    var animationDuration: TimeInterval { get }

    var prepareForViewWrappingAnimation: ((UIViewController,UIViewController) -> ViewAnimationInfoType) { get }
    var animateViewWrapping: ((UIViewController,UIViewController,ViewAnimationInfoType) -> ViewAnimationInfoType) { get }
    var completeViewWrappingAnimation: ((UIViewController,UIViewController,ViewAnimationInfoType) -> Void) { get }

    var prepareForViewUnwrappingAnimation: ((UIViewController,UIViewController) -> ViewAnimationInfoType) { get }
    var animateViewUnwrapping: ((UIViewController,UIViewController,ViewAnimationInfoType) -> ViewAnimationInfoType) { get }
    var completeViewUnwrappingAnimation: ((UIViewController,UIViewController,ViewAnimationInfoType) -> Void) { get }
}

open class WrappingRouteSegmentPresenter : BaseRouteSegmentPresenter, VisualRouteSegmentPresenterType, ReversibleRouteSegmentPresenterType {

    // MARK: public methods

    open static let defaultPresenterIdentifier = Identifier(name: String(describing: WrappingRouteSegmentPresenter.self))

    public init(wrappingRouteSegmentAnimator: WrappingRouteSegmentAnimator) {
        self.wrappingRouteSegmentAnimator = wrappingRouteSegmentAnimator
        super.init()
    }

    public init(presenterIdentifier: Identifier, wrappingRouteSegmentAnimator: WrappingRouteSegmentAnimator) {
        self.wrappingRouteSegmentAnimator = wrappingRouteSegmentAnimator
        super.init(presenterIdentifier: presenterIdentifier)
    }

    open func present(viewController presentedViewController : UIViewController, from presentingViewController: UIViewController?, options: RouteSequenceOptions, window: UIWindow?, completion: @escaping ((RoutingResult) -> Void)) {
        guard let child = presentingViewController else {
            _ = verify(checkNotNil(presentingViewController, "presentingViewController"), completion: completion)
            return
        }
        if presentedViewController == child {
            // TODO: this case seems like a bug
            unwrap(childViewController: child, fromWrapper: presentedViewController, completion: completion)
        } else {
            wrap(childViewController: child, inWrapper: presentedViewController, completion: completion)
        }
    }

    open func reverse(viewController viewControllerToRemove: UIViewController, completion: @escaping ((RoutingResult) -> Void)) {
        let parent = viewControllerToRemove.parent
        guard let _ = parent else {
            _ = verify(checkNotNil(parent, "parent"), completion: completion)
            return
        }
        let firstChild = viewControllerToRemove.childViewControllers.first
        guard let child = firstChild else {
            _ = verify(checkNotNil(firstChild, "child"), completion: completion)
            return
        }

        unwrap(childViewController: child, fromWrapper: viewControllerToRemove, completion: completion)
    }

    // MARK: wrapping methods

    fileprivate func wrap(childViewController child: UIViewController, inWrapper wrapper : UIViewController, completion: @escaping ((RoutingResult) -> Void)) {
        let parent = child.parent
        let previousChildViewIndex = parent?.view.subviews.index(of: child.view)

        wrapper.view.frame = child.view.bounds
        wrapper.view.addSubview(child.view)

        if let parent = parent,
            let previousChildViewIndex = previousChildViewIndex {
            parent.view.insertSubview(parent.view, at: previousChildViewIndex)
        }

        let finishWrappingViewControllerBlock = startWrappingViewController(child, inWrapper: wrapper)

        var viewAnimationInfo = wrappingRouteSegmentAnimator.prepareForViewWrappingAnimation(child, wrapper)

        UIView.animate(
            withDuration: wrappingRouteSegmentAnimator.animationDuration,
            animations: {
                viewAnimationInfo = self.wrappingRouteSegmentAnimator.animateViewWrapping(child, wrapper, viewAnimationInfo)
            },
            completion: {
                finished in
                self.wrappingRouteSegmentAnimator.completeViewWrappingAnimation(child, wrapper, viewAnimationInfo)
                finishWrappingViewControllerBlock()
                completion(.success(wrapper))
            }
        )
    }

    fileprivate func startWrappingViewController(_ child: UIViewController, inWrapper wrapper : UIViewController) -> ((Void) -> Void) {
        let parent = child.parent
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

    fileprivate func startWrappingBasicController(_ child: UIViewController, inWrapper wrapper: UIViewController) -> ((Void) -> Void) {
        let parent = child.parent
        wrapper.addChildViewController(child)
        parent?.addChildViewController(wrapper)
        return {
            wrapper.didMove(toParentViewController: parent)
            child.didMove(toParentViewController: wrapper)
        }
    }

    fileprivate func startWrappingNavigationController(_ navigationController: UINavigationController, withChild child: UIViewController, inWrapper wrapper : UIViewController) -> ((Void) -> Void) {
        // UINavigationController will handle *some* of the add/move stuff for us
        var viewControllers = navigationController.viewControllers
        guard let index = viewControllers.index(of: child) else {
            print("WARNING: parentViewController was UINavigationController, but child was not in the list of viewControllers")
            return {}
        }

        wrapper.navigationItem.setValuesFrom(child.navigationItem)
        wrapper.addChildViewController(child)
        child.didMove(toParentViewController: wrapper)

        viewControllers[index] = wrapper
        navigationController.viewControllers = viewControllers
        return {
            child.didMove(toParentViewController: wrapper)
        }
    }

    // MARK: unwrapping methods

    fileprivate func unwrap(childViewController child: UIViewController, fromWrapper wrapper: UIViewController, completion: @escaping ((RoutingResult) -> Void))  {
        let parent = wrapper.parent!
        let child = wrapper.childViewControllers.first!
        child.willMove(toParentViewController: parent)

        var frame = child.view.frame
        frame.origin.x = 0

        let finishUnwrappingViewControllerBlock = startUnwrapping(childViewController: child, fromWrapper: wrapper)

        var viewAnimationInfo = wrappingRouteSegmentAnimator.prepareForViewUnwrappingAnimation(child, wrapper)

        UIView.animate(
            withDuration: wrappingRouteSegmentAnimator.animationDuration,
            animations: {
                viewAnimationInfo = self.wrappingRouteSegmentAnimator.animateViewUnwrapping(child, wrapper, viewAnimationInfo)
            },
            completion: {
                finished in
                self.wrappingRouteSegmentAnimator.completeViewUnwrappingAnimation(child, wrapper, viewAnimationInfo)
                finishUnwrappingViewControllerBlock()
                completion(.success(wrapper))
            }
        )

    }

    fileprivate func startUnwrapping(childViewController child: UIViewController, fromWrapper wrapper : UIViewController) -> ((Void) -> Void) {
        let parent = wrapper.parent
        if let navigationController = parent as? UINavigationController {
            return startUnwrapping(navigationController: navigationController, withChild: child, fromWrapper: wrapper)
        } else if let _ = parent as? UISplitViewController {
            // TODO: splitViewController not handled yet
            print("WARNING: splitViewController not handled yet")
            return {}
        } else if let _ = parent as? UITabBarController {
            // TODO: tabBarController not handled yet
            print("WARNING: tabBarController not handled yet")
            return {}
        } else {
            return startUnwrapping(basicViewController: child, fromWrapper: wrapper)
        }
    }

    fileprivate func startUnwrapping(basicViewController child: UIViewController, fromWrapper wrapper: UIViewController) -> ((Void) -> Void) {
        let parent = child.parent

        return {
            // do not just add the child back to the parent's view, there were potentially other views in there previously
            wrapper.view.superview?.addSubview(child.view)
            wrapper.view.removeFromSuperview()
            parent?.addChildViewController(child)
            wrapper.willMove(toParentViewController: nil)
            wrapper.removeFromParentViewController()
        }
    }

    fileprivate func startUnwrapping(navigationController: UINavigationController, withChild child: UIViewController, fromWrapper wrapper : UIViewController) -> ((Void) -> Void) {
        // UINavigationController will handle *some* of the add/move stuff for us
        var viewControllers = navigationController.viewControllers
        guard let index = viewControllers.index(of: wrapper) else {
            print("WARNING: parentViewController was UINavigationController, but wrapper was not in the list of viewControllers")
            return {}
        }

        let parent = wrapper.parent
        return {
            wrapper.view.superview?.addSubview(child.view)
            viewControllers[index] = child
            navigationController.viewControllers = viewControllers
            child.didMove(toParentViewController: parent)
        }
    }
    

    // MARK: private variables

    fileprivate var wrappingRouteSegmentAnimator: WrappingRouteSegmentAnimator
}

extension UINavigationItem {

    fileprivate func setValuesFrom(_ fromNavigationItem: UINavigationItem) {
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
