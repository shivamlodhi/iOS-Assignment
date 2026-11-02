//
//  FavoritesManager.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import Foundation

// Keeps favorite article links in UserDefaults
final class FavoritesManager {

    private let defaults: UserDefaults
    private let key = "favoriteArticleURLs"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func isFavorite(_ article: Article) -> Bool {
        guard let url = article.url else { return false }
        return favoriteURLs.contains(url)
    }

    func toggleFavorite(_ article: Article) {
        guard let url = article.url else { return }
        var urls = favoriteURLs
        if urls.contains(url) {
            urls.remove(url)
        } else {
            urls.insert(url)
        }
        defaults.set(Array(urls), forKey: key)
    }

    private var favoriteURLs: Set<String> {
        Set(defaults.stringArray(forKey: key) ?? [])
    }
}
