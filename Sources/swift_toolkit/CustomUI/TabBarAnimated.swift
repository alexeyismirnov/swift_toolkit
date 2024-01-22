//
//  TabBarAnimated.swift
//  swift-toolkit
//
//  Created by Alexey Smirnov on 10/12/17.
//  Copyright © 2017 Alexey Smirnov. All rights reserved.
//

import UIKit

open class UITabBarControllerAnimated: UITabBarController, UITabBarControllerDelegate, UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func animationEnded(_ transitionCompleted: Bool) {
        
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let DampingConstant:CGFloat     = 1.0
        let InitialVelocity:CGFloat     = 0.2
        let PaddingBetweenViews:CGFloat = 0
        
        let inView = transitionContext.containerView
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let fromView = fromVC?.view
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let toView = toVC?.view
        
        let indexFrom = findIndex(viewControllers!) { $0.restorationIdentifier == fromVC?.restorationIdentifier }
        let indexTo = findIndex(viewControllers!) { $0.restorationIdentifier == toVC?.restorationIdentifier }
        
        let centerRect =  transitionContext.finalFrame(for: toVC!)
        let leftRect   = centerRect.offsetBy(dx: -(centerRect.width+PaddingBetweenViews), dy: 0);
        let rightRect  = centerRect.offsetBy(dx: centerRect.width+PaddingBetweenViews, dy: 0);
        
        if (indexTo! > indexFrom!) {
            toView!.frame = rightRect;
            inView.addSubview(toView!)
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                           delay: 0,
                           usingSpringWithDamping: DampingConstant,
                           initialSpringVelocity: InitialVelocity,
                           options: UIView.AnimationOptions(rawValue: 0),
                           animations: { fromView!.frame = leftRect; toView!.frame = centerRect },
                           completion: { (value:Bool) in transitionContext.completeTransition(true) } )
            
            
        } else {
            toView!.frame = leftRect;
            inView.addSubview(toView!)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: Foundation.TimeInterval(0),
                           usingSpringWithDamping: DampingConstant,
                           initialSpringVelocity: -InitialVelocity,
                           options: UIView.AnimationOptions(rawValue: 0),
                           animations: { fromView!.frame = rightRect; toView!.frame = centerRect },
                           completion: { (value:Bool) in transitionContext.completeTransition(true) } )
            
        }
    }
    
}


