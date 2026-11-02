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
              let navigationController = window?.rootViewController as? UINavigationController,
              let listViewController = navigationController.topViewController as? ArticleListViewController else { return }

        listViewController.articleManager = appDelegate.container.resolve(ArticleManager.self)
    }
}
