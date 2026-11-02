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
    private let cache: ArticleCache
    private let reachability: ReachabilityProtocol

    init(provider: ArticleProviderProtocol, cache: ArticleCache, reachability: ReachabilityProtocol) {
        self.provider = provider
        self.cache = cache
        self.reachability = reachability
    }

    var isConnected: Bool {
        reachability.isConnected
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

    private func fallback(for error: APIError) -> ArticlesResult {
        let cachedArticles = cache.load()
        return cachedArticles.isEmpty ? .failure(error) : .cached(cachedArticles, error)
    }
}
