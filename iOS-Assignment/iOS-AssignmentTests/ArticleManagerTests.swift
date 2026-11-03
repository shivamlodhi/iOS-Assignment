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

// Lets the test pick online or offline
final class MockReachability: ReachabilityProtocol {
    var isConnected = true
    var onChange: (() -> Void)?
}

final class ArticleManagerTests: XCTestCase {

    private var provider: MockArticleProvider!
    private var reachability: MockReachability!
    private var cache: ArticleCache!
    private var manager: ArticleManager!

    override func setUp() {
        provider = MockArticleProvider()
        reachability = MockReachability()
        cache = ArticleCache(name: "TestArticlesCache-\(UUID().uuidString)")
        manager = ArticleManager(provider: provider, cache: cache, reachability: reachability)
    }

    private func makeArticle(title: String?) -> Article {
        Article(source: nil, author: nil, title: title, description: nil,
                url: nil, urlToImage: nil, publishedAt: nil, content: nil)
    }

    // The cache saves in the background, so wait until it has the expected count
    private func waitForCache(count: Int) {
        let saved = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in self.cache.load().count == count }, object: nil)
        wait(for: [saved], timeout: 2)
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
        waitForCache(count: 1)
    }

    func testCachedArticlesAreShownWhenRequestFails() {
        cache.save([makeArticle(title: "Saved")])
        waitForCache(count: 1)
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

    func testCachedArticlesAreShownWhenOffline() {
        cache.save([makeArticle(title: "Saved")])
        waitForCache(count: 1)
        reachability.isConnected = false
        let expectation = expectation(description: "fetch")

        manager.fetchArticles { result in
            if case .cached(_, let error) = result {
                XCTAssertEqual(error, .noInternet)
            } else {
                XCTFail("Expected cached articles")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testEmptyResponseKeepsSavedArticles() {
        cache.save([makeArticle(title: "Saved")])
        waitForCache(count: 1)
        provider.result = .success([])
        let expectation = expectation(description: "fetch")

        manager.fetchArticles { _ in expectation.fulfill() }

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(cache.load().count, 1)
    }

    func testOnlyRealConnectivityChangesAreReported() {
        var reported: [Bool] = []
        manager.onConnectivityChange = { reported.append($0) }

        // Same state as before, like the first callback when reachability starts
        reachability.onChange?()
        reachability.isConnected = false
        reachability.onChange?()
        reachability.isConnected = true
        reachability.onChange?()

        XCTAssertEqual(reported, [false, true])
    }
}
