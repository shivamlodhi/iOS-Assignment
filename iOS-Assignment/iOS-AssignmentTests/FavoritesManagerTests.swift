//
//  FavoritesManagerTests.swift
//  iOS-AssignmentTests
//
//  Created by Shivam Lodhi on 03/11/26.
//

import XCTest
@testable import iOS_Assignment

final class FavoritesManagerTests: XCTestCase {

    private let suiteName = "FavoritesManagerTests"
    private var manager: FavoritesManager!

    override func setUp() {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        manager = FavoritesManager(defaults: defaults)
    }

    private func makeArticle(url: String?) -> Article {
        Article(source: nil, author: nil, title: "Title", description: nil,
                url: url, urlToImage: nil, publishedAt: nil, content: nil)
    }

    func testToggleSavesAndRemoves() {
        let article = makeArticle(url: "https://example.com/news")
        XCTAssertFalse(manager.isFavorite(article))

        manager.toggleFavorite(article)
        XCTAssertTrue(manager.isFavorite(article))

        manager.toggleFavorite(article)
        XCTAssertFalse(manager.isFavorite(article))
    }

    func testArticleWithoutLinkIsNeverSaved() {
        let article = makeArticle(url: nil)

        manager.toggleFavorite(article)

        XCTAssertFalse(manager.isFavorite(article))
    }
}
