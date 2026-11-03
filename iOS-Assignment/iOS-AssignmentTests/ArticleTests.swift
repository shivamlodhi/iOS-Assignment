//
//  ArticleTests.swift
//  iOS-AssignmentTests
//
//  Created by Shivam Lodhi on 03/11/26.
//

import XCTest
@testable import iOS_Assignment

final class ArticleTests: XCTestCase {

    private func makeArticle(title: String? = nil, description: String? = nil, url: String? = nil,
                             content: String? = nil) -> Article {
        Article(source: nil, author: nil, title: title, description: description,
                url: url, urlToImage: nil, publishedAt: nil, content: content)
    }

    func testSearchMatchesTitleAndDescription() {
        let article = makeArticle(title: "Tesla shareholders", description: "Car production")

        XCTAssertTrue(article.matches("tesla"))
        XCTAssertTrue(article.matches("PRODUCTION"))
        XCTAssertFalse(article.matches("bitcoin"))
    }

    func testDisplayTitleFallsBackToDescription() {
        XCTAssertEqual(makeArticle(title: "Title", description: "Description").displayTitle, "Title")
        XCTAssertEqual(makeArticle(title: "", description: "Description").displayTitle, "Description")
        XCTAssertEqual(makeArticle(title: nil, description: "Description").displayTitle, "Description")
        XCTAssertNil(makeArticle(title: nil, description: "").displayTitle)
    }

    func testBodyIsCleanedOfRawAPIText() {
        let content = "Highlights\r\n<ul><li>Sales &amp; profit</li><li>Musk&#039;s plan</li></ul>… [+3029 More text"
        let body = makeArticle(content: content).displayBody

        XCTAssertEqual(body, "Highlights\n\n• Sales & profit\n• Musk's plan…\n\nMore text")
    }

    func testBodyFallsBackToDescription() {
        XCTAssertEqual(makeArticle(description: "Short &quot;quote&quot;").displayBody, "Short \"quote\"")
        XCTAssertNil(makeArticle().displayBody)
    }

    func testTitleFromDescriptionIsOneLine() {
        XCTAssertEqual(makeArticle(description: "First line\r\nSecond line").displayTitle, "First line Second line")
    }

    func testOnlyWebLinksAreAllowed() {
        XCTAssertNotNil(makeArticle(url: "https://example.com").articleURL)
        XCTAssertNotNil(makeArticle(url: "http://example.com").articleURL)
        XCTAssertNil(makeArticle(url: "httpfoo://example.com").articleURL)
        XCTAssertNil(makeArticle(url: "mailto:test@example.com").articleURL)
    }
}
