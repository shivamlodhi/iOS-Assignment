//
//  ArticleProvider.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import Foundation

final class ArticleProvider: ArticleProviderProtocol {

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchArticles(completion: @escaping (Result<[Article], APIError>) -> Void) {
        apiClient.get(APIEndpoint.articles) { (result: Result<ArticlesResponse, APIError>) in
            completion(result.map { $0.articles })
        }
    }
}
