//
//  UIViewController+BarStyle.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 03/11/26.
//

import UIKit

extension UIViewController {

    // Changes the bar style and fades it in or out together with the push or pop
    func setNavigationBarStyle(_ style: UIUserInterfaceStyle, alpha: CGFloat) {
        guard let navigationBar = navigationController?.navigationBar else { return }
        let update = {
            navigationBar.overrideUserInterfaceStyle = style
            navigationBar.alpha = alpha
        }
        if let transitionCoordinator {
            let oldStyle = navigationBar.overrideUserInterfaceStyle
            let oldAlpha = navigationBar.alpha
            // The bar is drawn above both screens, so fade it out in the first half and back in
            // during the second half. That way it never sits on top of the other screen
            transitionCoordinator.animate(alongsideTransition: { context in
                let half = context.transitionDuration / 2
                UIView.animate(withDuration: half, delay: alpha > 0 ? half : 0,
                               options: [.overrideInheritedDuration, .overrideInheritedCurve], animations: update)
            }, completion: { context in
                // The iOS 18 zoom can be swiped back halfway and cancelled, the bar has to go back too
                if context.isCancelled {
                    navigationBar.overrideUserInterfaceStyle = oldStyle
                    navigationBar.alpha = oldAlpha
                }
            })
        } else {
            update()
        }
    }
}
