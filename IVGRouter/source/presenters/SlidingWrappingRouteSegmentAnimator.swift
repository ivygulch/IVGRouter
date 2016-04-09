//
//  SlidingWrappingRouteSegmentAnimator.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/8/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public struct SlidingWrappingRouteSegmentAnimatorSettings {
    static let DefaultSlideFactor: CGFloat = 0.8
    static let DefaultAnimationDuration: NSTimeInterval = 0.3
}

public class SlidingWrappingRouteSegmentAnimator : WrappingRouteSegmentAnimator {

    public let animationDuration: NSTimeInterval
    public let slideFactor: CGFloat

    public init(animationDuration: NSTimeInterval = SlidingWrappingRouteSegmentAnimatorSettings.DefaultAnimationDuration, slideFactor: CGFloat = SlidingWrappingRouteSegmentAnimatorSettings.DefaultSlideFactor) {
        self.animationDuration = animationDuration
        self.slideFactor = slideFactor
    }

    public lazy var prepareForViewWrappingAnimation: ((UIViewController,UIViewController) -> ViewAnimationInfoType) = {
        [weak self] (child,wrapper) -> ViewAnimationInfoType in
        var frame = child.view.frame
        let slideFactor = self?.slideFactor ?? SlidingWrappingRouteSegmentAnimatorSettings.DefaultSlideFactor
        frame.origin.x = frame.size.width * slideFactor
        return ["frame":NSValue(CGRect:frame)]
    }

    public lazy var animateViewWrapping: ((UIViewController,UIViewController,ViewAnimationInfoType) -> ViewAnimationInfoType) = {
        (child,wrapper,viewAnimationInfo) in
        if let frame = viewAnimationInfo["frame"] as? NSValue {
            child.view.frame = frame.CGRectValue()
        }
        return viewAnimationInfo
    }

    public lazy var completeViewWrappingAnimation: ((UIViewController,UIViewController,ViewAnimationInfoType) -> Void) = {
        _ in
        // nothing to do by default
    }
    
}