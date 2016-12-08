//
//  FlipPresentAnimationController.swift
//  GuessThePet
//
//  Created by ronatory on 07/12/2016.
//  Copyright © 2016 ronatory. All rights reserved.
//

import UIKit

class FlipPresentAnimationController: NSObject {

  // MARK: - Properties
  
  var originFrame = CGRect.zero
}


// MARK: - UIViewControllerAnimatedTransitioning
extension FlipPresentAnimationController: UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.6
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    // the transition context will provide the view controllers and views participating in the transition
    // you use the appropriate keys to obtain them
    let containerView = transitionContext.containerView
    guard let fromVC = transitionContext.viewController(forKey: .from), let toVC = transitionContext.viewController(forKey: .to) else {
      return
    }
    
    // specify the starting and final frames for the "to" view. in this case the transition starts from the card's frame and scales to fill the whole screen
    let initialFrame = originFrame
    let finalFrame = transitionContext.finalFrame(for: toVC)
    
    // UIView snapshotting captures the "to" view and renders it into a lightweight view, this lets you animate the view together with its hierarchy
    // the snapshots frame starts off as the card's frame, you also modify the corner radius to match the card
    guard let snapshot = toVC.view.snapshotView(afterScreenUpdates: true) else {
      return
    }
    snapshot.frame = initialFrame
    snapshot.layer.cornerRadius = 25
    snapshot.layer.masksToBounds = true
    
    // think of the container view as the dance floor upon which your transition shakes its stuff 
    // the container view already contains the "from" view, but it's your responsibility to add the "to" view
    // also ad the snapshot view to the container and hide the real view for now
    // the completed animation will rotate the snapshot out of view and hide it from the user
    containerView.addSubview(toVC.view)
    containerView.addSubview(snapshot)
    toVC.view.isHidden = true
    
    AnimationHelper.perspectiveTransformForContainerView(containerView)
    snapshot.layer.transform = AnimationHelper.yRotation(M_PI_2)
    
    // specify the duration of the animation
    // you need the duration of your animations to match up with the
    // duration you've declared for the whole transition so UIKit can keep things sync
    let duration = transitionDuration(using: transitionContext)
    
    UIView.animateKeyframes(
      withDuration: duration,
      delay: 0,
      options: .calculationModeCubic,
      animations: {
        // start by rotating the "from" view halfway around its y-axis to hide it from view
        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/3, animations: {
          fromVC.view.layer.transform = AnimationHelper.yRotation(-M_PI_2)
        })
        
        // next, reveal the snapshot using the same technique
        UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: {
          snapshot.layer.transform = AnimationHelper.yRotation(0.0)
        })
        
        // set the frame of the snapshot to fill the screen
        UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
          snapshot.frame = finalFrame
        })
      },
      completion: { _ in
        // finally, it's sage to reveal the real "to" view
        // you remove the snapshot sice it's no longer useful
        // then you rotate the "from" view back in place
        // otherwise it would hidden when transitioning back
        // calling completeTransition informs the transitioning context that the
        // animation is complete
        // UIKit will ensure the final state is consistent and remove the "from" view from the container
        toVC.view.isHidden = false
        fromVC.view.layer.transform = AnimationHelper.yRotation(0.0)
        snapshot.removeFromSuperview()
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    })
  }
}
