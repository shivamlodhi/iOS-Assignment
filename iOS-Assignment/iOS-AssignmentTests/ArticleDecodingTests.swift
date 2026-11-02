//
//  ArticleDecodingTests.swift
//  iOS-AssignmentTests
//
//  Created by Shivam Lodhi on 03/11/26.
//

import XCTest
@testable import iOS_Assignment

final class ArticleDecodingTests: XCTestCase {

    private func decode(_ json: String) throws -> ArticlesResponse {
        try JSONDecoder().decode(ArticlesResponse.self, from: Data(json.utf8))
    }

    func testDecodesArticle() throws {
        let json = """
        { "status": "ok", "articles": [ { "title": "Dogecoin Payments On X", "author": "Sam" } ] }
        """

        let response = try decode(json)

        XCTAssertEqual(response.articles.count, 1)
        XCTAssertEqual(response.articles.first?.title, "Dogecoin Payments On X")
        XCTAssertEqual(response.articles.first?.author, "Sam")
    }

    func testSkipsBrokenArticle() throws {
        let json = """
        { "articles": [ { "title": 123 }, { "title": "Good article" } ] }
        """

        let response = try decode(json)

        XCTAssertEqual(response.articles.count, 1)
        XCTAssertEqual(response.articles.first?.title, "Good article")
    }

    func testMissingArticlesGivesEmptyList() throws {
        let response = try decode("{ \"status\": \"error\" }")

        XCTAssertTrue(response.articles.isEmpty)
    }

    func testEmptyImageURLIsNil() throws {
        let response = try decode("{ \"articles\": [ { \"urlToImage\": \"\" } ] }")

        XCTAssertNil(response.articles.first?.imageURL)
    }

    func testOnlyWebLinksAreAllowed() throws {
        let json = """
        { "articles": [ { "url": "https://example.com" }, { "url": "javascript:alert(1)" } ] }
        """

        let response = try decode(json)

        XCTAssertNotNil(response.articles[0].articleURL)
        XCTAssertNil(response.articles[1].articleURL)
    }
}
