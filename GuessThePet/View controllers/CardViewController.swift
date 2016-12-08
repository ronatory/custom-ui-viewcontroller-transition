/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

private let revealSequeId = "revealSegue"
private let flipPresentAnimationController = FlipPresentAnimationController()
private let flipDismissAnimationController = FlipDismissAnimationController()
private let swipeInteractionController = SwipeInteractionController()

class CardViewController: UIViewController {
  
  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var titleLabel: UILabel!
  
  var pageIndex: Int?
  var petCard: PetCard?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    titleLabel.text = petCard?.description
    cardView.layer.cornerRadius = 25
    cardView.layer.masksToBounds = true
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    cardView.addGestureRecognizer(tapRecognizer)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == revealSequeId, let destinationViewController = segue.destination as? RevealViewController {
      destinationViewController.petCard = petCard
      // Important Note: The view controller being presented needs a transition delegate, not
      // the view controller doing the presenting
      destinationViewController.transitioningDelegate = self
      // this gives the interaction controller a reference to the presented view controller
      swipeInteractionController.wireToViewController(viewController: destinationViewController)
    }
  }
  
  func handleTap() {
    performSegue(withIdentifier: revealSequeId, sender: nil)
  }
}

extension CardViewController: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    // here you return your custom animation controller instance
    // the method will also ensure the transition starts from the correct frame
    flipPresentAnimationController.originFrame = cardView.frame
    return flipPresentAnimationController
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    // passes the correct frame to the dismissing animation controller and returns it
    flipDismissAnimationController.destinationFrame = cardView.frame
    return flipDismissAnimationController
  }
  
  /// UIKit queries the transition delegate for an interaction controller in interactionControllerForDismissal(_:)
  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    // this implementation checks whether the view is currently detecting a gesture, which means there's an interaction in progress
    // It returns the appropriate interaction controller
    return swipeInteractionController.interactionInProgress ? swipeInteractionController : nil
  }
}
