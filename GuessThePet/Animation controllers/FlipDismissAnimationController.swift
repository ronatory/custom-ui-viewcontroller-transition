//
//  FlipDismissAnimationController.swift
//  GuessThePet
//
//  Created by ronatory on 07/12/2016.
//  Copyright © 2016 ronatory All rights reserved.
//

import UIKit

class FlipDismissAnimationController: NSObject {
  
  // MARK: - Properties
  
  var destinationFrame = CGRect.zero
		
}

// MARK: - Extensions -

// MARK: - UIViewControllerAnimatedTransitioning
extension FlipDismissAnimationController: UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.6
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView
    guard let fromVC = transitionContext.viewController(forKey: .from),
      let toVC = transitionContext.viewController(forKey: .to) else {
        return
    }
    
    // since the animation shrinks the view, you'll need to flip the initial and final frames
    // Note: compare to FlipPresentAnimationController
    let initialFrame = transitionContext.initialFrame(for: fromVC)
    let finalFrame = destinationFrame
    
    // compared to FlipPresentAnimationController, you manipulate this time the "from" view so you take a snapshot of that
    guard let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false) else {
      return
    }
    snapshot.frame = initialFrame
    snapshot.layer.cornerRadius = 25
    snapshot.layer.masksToBounds = true
    
    // just like in FlipPresentAnimationController, you add the "to" view and the snapshot to the container view
    // then hide the "from" view, so that it doesn't conflict with the snapshot
    containerView.addSubview(toVC.view)
    containerView.addSubview(snapshot)
    fromVC.view.isHidden = true
    
    AnimationHelper.perspectiveTransformForContainerView(containerView)
    
    // finally hide the "to" view via the same rotation technique
    toVC.view.layer.transform = AnimationHelper.yRotation(-M_PI_2)
    
    let duration = transitionDuration(using: transitionContext)
    
    // the inverse of FlipPresentAnimationController
    UIView.animateKeyframes(
      withDuration: duration,
      delay: 0,
      options: .calculationModeCubic,
      animations: {
        // scale the first view, then hide the snapshot with the rotation
        // next you reveal the "to" view by rotating it halfway around the y-axis but in the opposite direction
        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/3, animations: {
          snapshot.frame = finalFrame
        })
        
        UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: {
          snapshot.layer.transform = AnimationHelper.yRotation(M_PI_2)
        })
        
        UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
          toVC.view.layer.transform = AnimationHelper.yRotation(0.0)
        })
      },
      completion: { _ in
        // finally remove the snapshot and inform the context that the transition is complete
        // this allows UIKit to update the view controller hierarchy and tidy up the views it created to run the transition
        fromVC.view.isHidden = false
        snapshot.removeFromSuperview()
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      })
  }
}
