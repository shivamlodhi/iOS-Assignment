//
//  ArticleTests.swift
//  iOS-AssignmentTests
//
//  Created by Shivam Lodhi on 03/11/26.
//

import XCTest
@testable import iOS_Assignment

final class ArticleTests: XCTestCase {

    private func makeArticle(title: String? = nil, description: String? = nil, url: String? = nil) -> Article {
        Article(source: nil, author: nil, title: title, description: description,
                url: url, urlToImage: nil, publishedAt: nil, content: nil)
    }

    func testSearchMatchesTitleAndDescription() {
        let article = makeArticle(title: "Tesla shareholders", description: "Car production")

        XCTAssertTrue(article.matches("tesla"))
        XCTAssertTrue(article.matches("PRODUCTION"))
        XCTAssertFalse(article.matches("bitcoin"))
    }

    func testOnlyWebLinksAreAllowed() {
        XCTAssertNotNil(makeArticle(url: "https://example.com").articleURL)
        XCTAssertNotNil(makeArticle(url: "http://example.com").articleURL)
        XCTAssertNil(makeArticle(url: "httpfoo://example.com").articleURL)
        XCTAssertNil(makeArticle(url: "mailto:test@example.com").articleURL)
    }
}
