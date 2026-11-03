//
//  Article.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import Foundation

struct Article: Codable, Hashable {
    let source: ArticleSource?
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?

    // Same title on the list and the detail, the description is used when the title is missing
    var displayTitle: String? {
        if let title, !title.isEmpty { return title }
        if let description, !description.isEmpty { return description }
        return nil
    }

    var imageURL: URL? {
        guard let urlToImage, !urlToImage.isEmpty else { return nil }
        return URL(string: urlToImage)
    }

    var articleURL: URL? {
        guard let url, let link = URL(string: url), ["http", "https"].contains(link.scheme?.lowercased()) else { return nil }
        return link
    }

    func matches(_ searchText: String) -> Bool {
        (title ?? "").localizedCaseInsensitiveContains(searchText) ||
        (description ?? "").localizedCaseInsensitiveContains(searchText)
    }
}
