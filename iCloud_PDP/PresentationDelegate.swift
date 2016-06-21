//
//  PresentationDelegate.swift
//  iCloud_PDP
//
//  Created by Galiev Aynur on 20.06.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class PresentationDelegate: NSObject {

    private var duration: NSTimeInterval = 0.25
    
    init(duration: NSTimeInterval) {
        self.duration = duration
    }
}

extension PresentationDelegate: UIViewControllerTransitioningDelegate {
    
//    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        self.isPresenting = true
//        return self
//    }
//    
//    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        self.isPresenting = false
//        return self
//    }
    
//    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
//        return PopoverPresentationController(duration: self.duration)
//    }
}

//extension PresentationDelegate: UIViewControllerAnimatedTransitioning {
//    
//    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
//        return self.duration
//    }
//    
//    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
//        
//        let containerView = transitionContext.containerView()
//        
//        let to_view = transitionContext.viewForKey(UITransitionContextToViewKey)
//        let from_view = transitionContext.viewForKey(UITransitionContextFromViewKey)
//        
//        guard let toView = to_view, let fromView = from_view else { transitionContext.completeTransition(true); return }
//        
//        if self.isPresenting {
//            
//            containerView?.backgroundColor = UIColor.clearColor()
//            
//            toView.frame = CGRect(x: fromView.fs_width/2, y: fromView.fs_height/2, width: 0, height: 0)
//            containerView?.addSubview(toView)
//            
//            UIView.animateWithDuration(self.duration, animations: { 
//                containerView?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
//                toView.frame = CGRect(x: fromView.fs_width*0.1, y: fromView.fs_height*0.1, width: fromView.fs_width*0.8, height: fromView.fs_height*0.8)
//                containerView?.layoutIfNeeded()
//            }, completion: { (success) in
//                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
//            })
//            
//        } else {
//            
//            containerView?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
//            
//            UIView.animateWithDuration(self.duration, animations: { 
//                containerView?.backgroundColor = UIColor.clearColor()
//                fromView.frame = CGRect(x: toView.fs_width/2, y: toView.fs_height/2, width: 0, height: 0)
//            }, completion: { (success) in
//                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
//            })
//            
//        }
//    }
//    
//    func animationEnded(transitionCompleted: Bool) { }
//}

extension UIView {
    
    var fs_width: CGFloat {
        return self.frame.size.width
    }
    
    var fs_height: CGFloat {
        return self.frame.size.height
    }
}