//
//  SlidingWrappingRouteSegmentAnimator.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/8/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public struct SlidingWrappingRouteSegmentAnimatorSettings {
    public static let DefaultSlideFactor: CGFloat = 0.8
    public static let DefaultAnimationDuration: TimeInterval = 0.3
}

open class SlidingWrappingRouteSegmentAnimator : WrappingRouteSegmentAnimator {

    open let animationDuration: TimeInterval
    open let slideFactor: CGFloat

    public init(animationDuration: TimeInterval = SlidingWrappingRouteSegmentAnimatorSettings.DefaultAnimationDuration, slideFactor: CGFloat = SlidingWrappingRouteSegmentAnimatorSettings.DefaultSlideFactor) {
        self.animationDuration = animationDuration
        self.slideFactor = slideFactor
    }

    open lazy var prepareForViewWrappingAnimation: ((UIViewController,UIViewController) -> ViewAnimationInfoType) = { [weak self] (child,wrapper) -> ViewAnimationInfoType in
        var frame = child.view.frame
        let slideFactor = self?.slideFactor ?? SlidingWrappingRouteSegmentAnimatorSettings.DefaultSlideFactor
        frame.origin.x = frame.size.width * slideFactor
        return ["frame": NSValue(cgRect: frame)]
    }

    open lazy var animateViewWrapping: ((UIViewController,UIViewController,ViewAnimationInfoType) -> ViewAnimationInfoType) = { (child,wrapper,viewAnimationInfo) in
        if let frame = viewAnimationInfo["frame"] as? NSValue {
            child.view.frame = frame.cgRectValue
        }
        return viewAnimationInfo
    }

    open lazy var completeViewWrappingAnimation: ((UIViewController,UIViewController,ViewAnimationInfoType) -> Void) = { _,_,_  in
        // nothing to do by default
    }

    open lazy var prepareForViewUnwrappingAnimation: ((UIViewController,UIViewController) -> ViewAnimationInfoType) = { [weak self] (child,wrapper) -> ViewAnimationInfoType in
        var frame = child.view.frame
        frame.origin.x = 0
        return ["frame": NSValue(cgRect: frame)]
    }

    open lazy var animateViewUnwrapping: ((UIViewController,UIViewController,ViewAnimationInfoType) -> ViewAnimationInfoType) = { (child,wrapper,viewAnimationInfo) in
        if let frame = viewAnimationInfo["frame"] as? NSValue {
            child.view.frame = frame.cgRectValue
        }
        return viewAnimationInfo
    }

    // nothing to do by default
    open lazy var completeViewUnwrappingAnimation: ((UIViewController,UIViewController,ViewAnimationInfoType) -> Void) = { _,_,_  in }

}
