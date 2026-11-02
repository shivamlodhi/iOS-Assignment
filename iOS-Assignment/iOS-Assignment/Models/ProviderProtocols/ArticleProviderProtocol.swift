//
//  ArticleProviderProtocol.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import Foundation

protocol ArticleProviderProtocol {
    func fetchArticles(completion: @escaping (Result<[Article], APIError>) -> Void)
}
