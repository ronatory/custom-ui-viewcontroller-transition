//
//  SwipeInteractionController.swift
//  GuessThePet
//
//  Created by ronatory on 08/12/2016.
//  Copyright © 2016 ronatory All rights reserved.
//

import UIKit

class SwipeInteractionController: UIPercentDrivenInteractiveTransition {
  
  // MARK: - Properties
  
  /// whether an interaction is already in progress
  var interactionInProgress = false
  /// internally usage to control the transition
  private var shouldCompleteTransition = false
  /// the interaction controller directly presents and dismisses view controllers, 
  /// so you hold onto the current view controller in viewController
  private weak var viewController: UIViewController!
  
  // MARK: - Methods
  
  /// obtain a reference to the view controller and set up a gesture recognizer in its view
  func wireToViewController(viewController: UIViewController!) {
    self.viewController = viewController
    prepareGestureRecognizerInView(view: viewController.view)
  }
  
  /// declare a gesture recognizer, which will be triggered by a left edge swipe and add it to the view
  private func prepareGestureRecognizerInView(view: UIView) {
    let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleGesture(gestureRecognizer:)))
    gesture.edges = .left
    view.addGestureRecognizer(gesture)
  }
  
  func handleGesture(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
    // local variables to track the progress
    // you'll record the translation in the view and calculate the progress
    let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
    // a swipe of 200 points will lead to 100% completion, so you use this number to measure the transition's progress
    var progress = (translation.x / 200)
    progress = CGFloat(fmin(fmax(Float(progress), 0.0), 1.0))
    
    switch gestureRecognizer.state {
      
    case .began:
      // when the gesture starts, you adjust interactionInProgress accordingly and trigger the dismissal of the view controller
      interactionInProgress = true
      viewController.dismiss(animated: true, completion: nil)
    
    case .changed:
      // while the gesture is moving, you continously call update() with the progress amount
      // this is a method on UIPercentDrivenInteractiveTransition which moves the transition along by the percentage amount you pass in
      shouldCompleteTransition = progress > 0.5
      update(progress)
    
    case .cancelled:
      // if the gesture is cancelled, you update interactionInProgress and roll back the transition
      interactionInProgress = false
      cancel()
      
    case .ended:
      // once the gesture has ended, you use the current progress of the transition to decide whether to cancel it or finish it for the user
      interactionInProgress = false
      
      if !shouldCompleteTransition {
        cancel()
      } else {
        finish()
      }
      
    default:
      print("Unsupported")
    }
    
  }
  
}
