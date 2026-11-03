//
//  ArticleCache.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import Foundation
import Cache
import XCGLogger

protocol ArticleCacheProtocol {
    func save(_ articles: [Article])
    func load() -> [Article]
}

final class ArticleCache: ArticleCacheProtocol {

    private let storage: Storage<String, [Article]>?
    private let key = "articles"

    init(name: String = "ArticlesCache") {
        do {
            storage = try Storage(diskConfig: DiskConfig(name: name),
                                  memoryConfig: MemoryConfig(),
                                  transformer: TransformerFactory.forCodable(ofType: [Article].self))
        } catch {
            log.error("Unable to create article cache: \(error.localizedDescription)")
            storage = nil
        }
    }

    // Writes to disk in the background
    func save(_ articles: [Article]) {
        storage?.async.setObject(articles, forKey: key) { result in
            switch result {
            case .value:
                log.debug("Saved \(articles.count) articles to cache")
            case .error(let error):
                log.error("Unable to save articles: \(error.localizedDescription)")
            }
        }
    }

    func load() -> [Article] {
        guard let articles = try? storage?.object(forKey: key) else { return [] }
        return articles
    }
}
