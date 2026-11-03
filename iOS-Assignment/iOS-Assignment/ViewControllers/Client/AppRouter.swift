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

    init(favoritesManager: FavoritesManager) {
        self.favoritesManager = favoritesManager
    }

    func showDetail(for article: Article, from viewController: UIViewController, sourceView: UIView? = nil) {
        let detailViewController = storyboard.instantiateViewController(identifier: ArticleDetailViewController.identifier) { coder in
            ArticleDetailViewController(coder: coder, article: article, favoritesManager: self.favoritesManager)
        }
        // iPhone pushes on the list, iPad replaces the detail column
        if viewController.splitViewController?.isCollapsed ?? true {
            // Detail zooms out of the tapped card
            if let sourceView {
                detailViewController.preferredTransition = .zoom { [weak sourceView] _ in sourceView }
            }
            viewController.navigationController?.pushViewController(detailViewController, animated: true)
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
