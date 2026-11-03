//
//  ArticleTransition.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 03/11/26.
//

import UIKit

// Card to detail animation for the list stack on iOS 26. The detail grows out of the tapped
// card and shrinks back into it, and the bar change runs together with it
final class ArticleTransition: NSObject {

    private weak var sourceView: UIView?
    private weak var navigationController: UINavigationController?

    func push(_ detailViewController: UIViewController, on navigationController: UINavigationController,
              from sourceView: UIView?) {
        self.sourceView = sourceView
        self.navigationController = navigationController
        navigationController.delegate = self
        // Swipe back is handled below, the system swipe would fight with our animation
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        if #available(iOS 26.0, *) {
            navigationController.interactiveContentPopGestureRecognizer?.isEnabled = false
        }

        // Swipe right from anywhere goes back, like the rest of iOS 26
        let backPan = UIPanGestureRecognizer(target: self, action: #selector(handleBackPan(_:)))
        backPan.delegate = self
        detailViewController.view.addGestureRecognizer(backPan)

        navigationController.pushViewController(detailViewController, animated: true)
    }

    // Plays the same pop as the back button. Driving it with the finger crashes inside the
    // iOS 26 bar (NaN bounds while it updates), so the swipe only starts the animation
    @objc private func handleBackPan(_ gesture: UIPanGestureRecognizer) {
        guard gesture.state == .ended, let view = gesture.view else { return }
        if gesture.translation(in: view).x > 80 || gesture.velocity(in: view).x > 500 {
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ArticleTransition: UIGestureRecognizerDelegate {

    // Only a drag to the right starts going back, so scrolling the article still works
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer,
              (navigationController?.viewControllers.count ?? 0) > 1 else { return false }
        let velocity = pan.velocity(in: pan.view)
        return velocity.x > 0 && velocity.x > abs(velocity.y)
    }
}

// MARK: - UINavigationControllerDelegate

extension ArticleTransition: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push where toVC is ArticleDetailViewController:
            return ArticleTransitionAnimator(isPush: true, sourceView: sourceView)
        case .pop where fromVC is ArticleDetailViewController:
            return ArticleTransitionAnimator(isPush: false, sourceView: sourceView)
        default:
            return nil
        }
    }
}

// MARK: - Animator

final class ArticleTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let isPush: Bool
    private weak var sourceView: UIView?

    init(isPush: Bool, sourceView: UIView?) {
        self.isPush = isPush
        self.sourceView = sourceView
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        isPush ? 0.5 : 0.45
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to),
              let fromView = fromVC.view, let toView = toVC.view else {
            transitionContext.completeTransition(false)
            return
        }
        let container = transitionContext.containerView
        let listView = isPush ? fromView : toView
        let detailView = isPush ? toView : fromView
        // The leaving screen has no final frame, so on pop take where it starts
        let detailFrame = isPush ? transitionContext.finalFrame(for: toVC) : transitionContext.initialFrame(for: fromVC)
        if !isPush {
            listView.frame = transitionContext.finalFrame(for: toVC)
            container.insertSubview(listView, belowSubview: detailView)
        }

        let dimView = UIView(frame: container.bounds)
        dimView.backgroundColor = .black
        container.addSubview(dimView)

        // The detail sits scaled down inside a clipping view shaped like the card. A mask
        // would also work but it breaks the glass back button while animating
        let clipView = UIView()
        clipView.clipsToBounds = true
        // The detail keeps its full size inside, only its transform changes
        clipView.autoresizesSubviews = false
        container.addSubview(clipView)
        detailView.transform = .identity
        detailView.frame = CGRect(origin: .zero, size: detailFrame.size)
        clipView.addSubview(detailView)
        // Lay out now so the detail is drawn before it starts growing
        detailView.layoutIfNeeded()

        let cardFrame = cardFrame(for: detailFrame, in: container)
        let scale = cardFrame.width / detailFrame.width
        let onCard = {
            clipView.frame = cardFrame
            clipView.layer.cornerRadius = AppMetrics.cornerRadius
            detailView.transform = CGAffineTransform(scaleX: scale, y: scale)
            detailView.center = CGPoint(x: cardFrame.width / 2, y: detailFrame.height * scale / 2)
            listView.transform = .identity
            dimView.alpha = 0
        }
        let fullScreen = {
            clipView.frame = detailFrame
            clipView.layer.cornerRadius = 0
            detailView.transform = .identity
            detailView.center = CGPoint(x: detailFrame.width / 2, y: detailFrame.height / 2)
            listView.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
            dimView.alpha = 0.15
        }
        isPush ? onCard() : fullScreen()
        // Keep the card itself out of sight so it does not show twice
        sourceView?.alpha = 0

        let finish: (Bool) -> Void = { [isPush, weak sourceView] _ in
            detailView.transform = .identity
            detailView.frame = detailFrame
            if isPush {
                container.addSubview(detailView)
            }
            clipView.removeFromSuperview()
            dimView.removeFromSuperview()
            listView.transform = .identity
            sourceView?.alpha = 1
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        let duration = transitionDuration(using: transitionContext)
        if isPush {
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.86, initialSpringVelocity: 0,
                           options: [], animations: fullScreen, completion: finish)
        } else {
            // Shrinks into the card without bouncing. The detail fades out early while the real card
            // fades in under it, so the two never show on top of each other for long
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0,
                           options: [], animations: onCard, completion: finish)
            UIView.animate(withDuration: duration * 0.35, delay: duration * 0.15, options: .curveEaseIn) {
                clipView.alpha = 0
            }
            UIView.animate(withDuration: duration * 0.5, delay: duration * 0.2, options: .curveEaseOut) { [weak sourceView] in
                sourceView?.alpha = 1
            }
        }
    }

    // Where the card is on screen. Falls back to a slightly smaller detail in the middle
    // when the card has scrolled away or is gone
    private func cardFrame(for frame: CGRect, in container: UIView) -> CGRect {
        let fallback = frame.insetBy(dx: frame.width * 0.05, dy: frame.height * 0.05)
        guard let sourceView, sourceView.window != nil else { return fallback }
        let cardFrame = sourceView.convert(sourceView.bounds, to: container)
        return cardFrame.intersects(container.bounds) ? cardFrame : fallback
    }
}
