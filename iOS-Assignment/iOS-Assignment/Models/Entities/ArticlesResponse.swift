//
//  ArticlesResponse.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import Foundation

struct ArticlesResponse: Decodable {
    let status: String?
    let articles: [Article]

    enum CodingKeys: String, CodingKey {
        case status, articles
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try? container.decode(String.self, forKey: .status)

        // skip broken articles instead of failing the whole list
        let items = (try? container.decode([SafeArticle].self, forKey: .articles)) ?? []
        articles = items.compactMap { $0.article }
    }
}

private struct SafeArticle: Decodable {
    let article: Article?

    init(from decoder: Decoder) throws {
        article = try? Article(from: decoder)
    }
}
