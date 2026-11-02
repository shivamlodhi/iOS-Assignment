//
//  AppDelegate.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import UIKit
import Swinject

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let container = Container()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerDependencies()
        container.resolve(ReachabilityService.self)?.start()
        return true
    }

    private func registerDependencies() {
        container.register(APIClient.self) { _ in
            APIClient()
        }.inObjectScope(.container)

        container.register(ArticleProviderProtocol.self) { resolver in
            ArticleProvider(apiClient: resolver.resolve(APIClient.self)!)
        }

        container.register(ArticleCache.self) { _ in
            ArticleCache()
        }.inObjectScope(.container)

        container.register(ReachabilityService.self) { _ in
            ReachabilityService()
        }.inObjectScope(.container)

        container.register(ArticleManager.self) { resolver in
            ArticleManager(provider: resolver.resolve(ArticleProviderProtocol.self)!,
                           cache: resolver.resolve(ArticleCache.self)!,
                           reachability: resolver.resolve(ReachabilityService.self)!)
        }.inObjectScope(.container)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
