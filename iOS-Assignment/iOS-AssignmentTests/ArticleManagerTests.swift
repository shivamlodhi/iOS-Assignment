//
//  ArticleManagerTests.swift
//  iOS-AssignmentTests
//
//  Created by Shivam Lodhi on 03/11/26.
//

import XCTest
@testable import iOS_Assignment

// Returns whatever result the test sets, no network call
final class MockArticleProvider: ArticleProviderProtocol {
    var result: Result<[Article], APIError> = .success([])

    func fetchArticles(completion: @escaping (Result<[Article], APIError>) -> Void) {
        completion(result)
    }
}

final class ArticleManagerTests: XCTestCase {

    private var provider: MockArticleProvider!
    private var cache: ArticleCache!
    private var manager: ArticleManager!

    override func setUpWithError() throws {
        // The manager checks the real connection first
        try XCTSkipUnless(ReachabilityService().isConnected, "Needs internet connection")

        provider = MockArticleProvider()
        cache = ArticleCache(name: "TestArticlesCache-\(UUID().uuidString)")
        manager = ArticleManager(provider: provider, cache: cache, reachability: ReachabilityService())
    }

    private func makeArticle(title: String?) -> Article {
        Article(source: nil, author: nil, title: title, description: nil,
                url: nil, urlToImage: nil, publishedAt: nil, content: nil)
    }

    func testFreshArticlesAreReturnedAndSaved() {
        provider.result = .success([makeArticle(title: "First"), makeArticle(title: nil)])
        let expectation = expectation(description: "fetch")

        manager.fetchArticles { result in
            if case .fresh(let articles) = result {
                XCTAssertEqual(articles.count, 1)
            } else {
                XCTFail("Expected fresh articles")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(cache.load().count, 1)
    }

    func testCachedArticlesAreShownWhenRequestFails() {
        cache.save([makeArticle(title: "Saved")])
        provider.result = .failure(.serverError)
        let expectation = expectation(description: "fetch")

        manager.fetchArticles { result in
            if case .cached(let articles, _) = result {
                XCTAssertEqual(articles.first?.title, "Saved")
            } else {
                XCTFail("Expected cached articles")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testErrorWhenRequestFailsAndNoCache() {
        provider.result = .failure(.invalidData)
        let expectation = expectation(description: "fetch")

        manager.fetchArticles { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error, .invalidData)
            } else {
                XCTFail("Expected an error")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
}
