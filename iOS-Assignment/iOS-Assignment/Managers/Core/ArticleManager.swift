//
//  ArticleManager.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import Foundation
import XCGLogger

enum ArticlesResult {
    case fresh([Article])
    case cached([Article], APIError)
    case failure(APIError)
}

final class ArticleManager {

    private let provider: ArticleProviderProtocol
    private let cache: ArticleCacheProtocol
    private let reachability: ReachabilityProtocol
    private var wasConnected: Bool

    // Called with the new state only when the connection really changes
    var onConnectivityChange: ((Bool) -> Void)?

    init(provider: ArticleProviderProtocol, cache: ArticleCacheProtocol, reachability: ReachabilityProtocol) {
        self.provider = provider
        self.cache = cache
        self.reachability = reachability
        wasConnected = reachability.isConnected
        reachability.onChange = { [weak self] in
            self?.connectionChanged()
        }
    }

    func fetchArticles(completion: @escaping (ArticlesResult) -> Void) {
        guard reachability.isConnected else {
            log.warning("Offline, loading articles from cache")
            completion(fallback(for: .noInternet))
            return
        }

        provider.fetchArticles { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let articles):
                let validArticles = articles.filter { !($0.title ?? "").isEmpty || !($0.description ?? "").isEmpty }
                // Keep the saved articles if the server sends an empty list
                if !validArticles.isEmpty {
                    self.cache.save(validArticles)
                }
                completion(.fresh(validArticles))
            case .failure(let error):
                completion(self.fallback(for: error))
            }
        }
    }

    // Reachability also reports when it starts, so only pass on a real change
    private func connectionChanged() {
        let isConnected = reachability.isConnected
        guard isConnected != wasConnected else { return }
        wasConnected = isConnected
        onConnectivityChange?(isConnected)
    }

    private func fallback(for error: APIError) -> ArticlesResult {
        let cachedArticles = cache.load()
        return cachedArticles.isEmpty ? .failure(error) : .cached(cachedArticles, error)
    }
}
