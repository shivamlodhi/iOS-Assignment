//
//  AppRouter.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import UIKit
import SwiftUI

final class AppRouter {

    private static let storyboardName = "Main"

    private let favoritesManager: FavoritesManager
    private let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
    private let articleTransition = ArticleTransition()

    init(favoritesManager: FavoritesManager) {
        self.favoritesManager = favoritesManager
    }

    func showDetail(for article: Article, from viewController: UIViewController, sourceView: UIView? = nil) {
        let detailViewController = storyboard.instantiateViewController(identifier: ArticleDetailViewController.identifier) { coder in
            ArticleDetailViewController(coder: coder, article: article, favoritesManager: self.favoritesManager)
        }
        // iPhone pushes on the list, iPad replaces the detail column
        if viewController.splitViewController?.isCollapsed ?? true {
            guard let navigationController = viewController.navigationController else { return }
            // On iOS 26 the system zoom snaps the bar between the two styles, so use our own card animation
            if #available(iOS 26.0, *) {
                articleTransition.push(detailViewController, on: navigationController, from: sourceView)
                return
            }
            // Detail zooms out of the tapped card
            if let sourceView {
                detailViewController.preferredTransition = .zoom { [weak sourceView] _ in sourceView }
            }
            navigationController.pushViewController(detailViewController, animated: true)
        } else {
            viewController.showDetailViewController(UINavigationController(rootViewController: detailViewController),
                                                    sender: viewController)
        }
    }

    func makeEmptyDetailViewController() -> UIViewController {
        UIHostingController(rootView: StateView(icon: AppIcons.articleSymbol, title: AppStrings.selectArticleTitle,
                                                message: AppStrings.selectArticleMessage))
    }
}
