//
//  ArticleCache.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import Foundation
import Cache
import XCGLogger

final class ArticleCache {

    private let storage: Storage<String, [Article]>?
    private let key = "articles"

    init() {
        do {
            storage = try Storage(diskConfig: DiskConfig(name: "ArticlesCache"),
                                  memoryConfig: MemoryConfig(),
                                  transformer: TransformerFactory.forCodable(ofType: [Article].self))
        } catch {
            log.error("Unable to create article cache: \(error.localizedDescription)")
            storage = nil
        }
    }

    func save(_ articles: [Article]) {
        do {
            try storage?.setObject(articles, forKey: key)
            log.debug("Saved \(articles.count) articles to cache")
        } catch {
            log.error("Unable to save articles: \(error.localizedDescription)")
        }
    }

    func load() -> [Article] {
        guard let articles = try? storage?.object(forKey: key) else { return [] }
        return articles
    }
}
