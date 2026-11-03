//
//  SceneDelegate.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import UIKit
import Swinject

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let window,
              let navigationController = window.rootViewController as? UINavigationController,
              let listViewController = navigationController.topViewController as? ArticleListViewController,
              let router = appDelegate.container.resolve(AppRouter.self) else { return }

        listViewController.articleManager = appDelegate.container.resolve(ArticleManager.self)
        listViewController.router = router

        // List and detail side by side on iPad, collapses to a single stack on iPhone
        let splitViewController = UISplitViewController(style: .doubleColumn)
        splitViewController.preferredDisplayMode = .oneBesideSecondary
        splitViewController.preferredSplitBehavior = .tile
        splitViewController.delegate = self
        splitViewController.setViewController(navigationController, for: .primary)
        splitViewController.setViewController(router.makeEmptyDetailViewController(), for: .secondary)
        window.rootViewController = splitViewController
    }
}

// MARK: - UISplitViewControllerDelegate

extension SceneDelegate: UISplitViewControllerDelegate {

    // Start with the list on iPhone, but keep the open article when an iPad window gets narrow
    func splitViewController(_ svc: UISplitViewController,
                             topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
        let detailNavigationController = svc.viewController(for: .secondary) as? UINavigationController
        return detailNavigationController?.topViewController is ArticleDetailViewController ? .secondary : .primary
    }

    // An article open in a narrow window fades out the list's bar, give it back when the detail
    // moves to its own column again
    func splitViewControllerDidExpand(_ svc: UISplitViewController) {
        let listNavigationBar = (svc.viewController(for: .primary) as? UINavigationController)?.navigationBar
        listNavigationBar?.overrideUserInterfaceStyle = .light
        listNavigationBar?.alpha = 1
    }
}
