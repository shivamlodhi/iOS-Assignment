//
//  AppRouter.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import UIKit
import Swinject

final class AppRouter {

    private let resolver: Resolver
    private let storyboard = UIStoryboard(name: "Main", bundle: nil)

    init(resolver: Resolver) {
        self.resolver = resolver
    }

    func showDetail(for article: Article, from viewController: UIViewController) {
        let detailViewController = storyboard.instantiateViewController(withIdentifier: "ArticleDetailViewController") as! ArticleDetailViewController
        detailViewController.article = article
        detailViewController.favoritesManager = resolver.resolve(FavoritesManager.self)
        viewController.show(detailViewController, sender: viewController)
    }
}
