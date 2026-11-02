//
//  AppRouter.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import UIKit
import SwiftUI
import Swinject

final class AppRouter {

    private let resolver: Resolver
    private let storyboard = UIStoryboard(name: "Main", bundle: nil)

    init(resolver: Resolver) {
        self.resolver = resolver
    }

    func showDetail(for article: Article, from viewController: UIViewController, sourceView: UIView? = nil) {
        let detailViewController = storyboard.instantiateViewController(withIdentifier: "ArticleDetailViewController") as! ArticleDetailViewController
        detailViewController.article = article
        detailViewController.favoritesManager = resolver.resolve(FavoritesManager.self)
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
        UIHostingController(rootView: StateView(icon: "newspaper", title: "Select an article",
                                                message: "Choose an article from the list to read it here."))
    }
}
