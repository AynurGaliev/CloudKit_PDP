//
//  PopoverPresentationController.swift
//  iCloud_PDP
//
//  Created by Galiev Aynur on 21.06.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class PopoverPresentationController: UIPresentationController {

    var duration: NSTimeInterval = 0.25
    private var dimmingView: UIView = UIView()
    
    override func adaptivePresentationStyle() -> UIModalPresentationStyle {
        return UIModalPresentationStyle.FullScreen
    }
    
    override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        self.setupNotifications()
    }
    
    private func setupNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PopoverPresentationController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PopoverPresentationController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue() else { return }
        guard let lPresentedView = self.presentedView() else { return }
        lPresentedView.frame = CGRectOffset(lPresentedView.frame, 0, -keyboardFrame.size.height)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue() else { return }
        guard let lPresentedView = self.presentedView() else { return }
        lPresentedView.frame = CGRectOffset(lPresentedView.frame, 0, keyboardFrame.size.height)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        guard let lContainerView = self.containerView else { return CGRectZero }
        return CGRect(x     : lContainerView.fs_width*0.1,
                      y     : lContainerView.fs_height*0.1,
                      width : lContainerView.fs_width*0.8,
                      height: lContainerView.fs_height*0.8)
    }

    override func containerViewWillLayoutSubviews() {
        let frame = self.frameOfPresentedViewInContainerView()
        self.presentedView()?.frame = frame
        self.presentedView()?.layer.cornerRadius = 5.0
    }
    
    override func presentationTransitionWillBegin() {
        
        guard let lContainerView = self.containerView else { return }
        self.dimmingView.frame = lContainerView.frame
        self.dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PopoverPresentationController.backgroundDidTapped(_:))))
        self.dimmingView.backgroundColor = UIColor.clearColor()
        self.containerView?.addSubview(self.dimmingView)
        
        guard let lPresentedView = self.presentedView() else { return }
        
        lPresentedView.frame = CGRectOffset(self.frameOfPresentedViewInContainerView(), 0, -0.9*lContainerView.fs_height)
        lContainerView.addSubview(lPresentedView)
        
        let coordinator = self.presentedViewController.transitionCoordinator()
        coordinator?.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext) in
            self.dimmingView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
            lPresentedView.frame = self.frameOfPresentedViewInContainerView()
        }, completion: { (context: UIViewControllerTransitionCoordinatorContext) in
            
        })
    }
    
    override func dismissalTransitionWillBegin() {
        
        guard let lPresentedView = self.presentedView() else { return }
        guard let lContainerView = self.containerView else { return }
        
        let coordinator = self.presentedViewController.transitionCoordinator()
        coordinator?.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext) in
            self.dimmingView.backgroundColor = UIColor.clearColor()
            lPresentedView.frame = CGRectOffset(self.frameOfPresentedViewInContainerView(), 0, -0.9*lContainerView.fs_height)

        }, completion: { (context: UIViewControllerTransitionCoordinatorContext) in
            self.dimmingView.removeFromSuperview()
        })
    }

    func backgroundDidTapped(sender: AnyObject) {
        self.presentedViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
