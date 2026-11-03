//
//  AppStrings.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 03/11/26.
//

import Foundation

// All text shown to the user
enum AppStrings {
    // List
    static let articlesTitle = "Articles"
    static let changeLayout = "Change layout"
    static let search = "Search"
    static let searchPlaceholder = "Search articles"
    static let readMore = "Read More"
    static let offlineToast = "You’re offline. Showing saved articles."
    static let refreshFailedToast = "Couldn’t refresh. Showing saved articles."

    // Detail
    static let articleTitle = "Article"
    static let readFullArticle = "Read Full Article"
    static let untitledArticle = "Untitled article"
    static let noDetails = "No details available for this article."
    static let back = "Back"
    static let addFavorite = "Add to favorites"
    static let removeFavorite = "Remove from favorites"

    // Time since an article was published, like "10h ago"
    static let justNow = "Just now"
    static func yearsAgo(_ years: Int) -> String { "\(years)y ago" }
    static func monthsAgo(_ months: Int) -> String { "\(months)mo ago" }
    static func daysAgo(_ days: Int) -> String { "\(days)d ago" }
    static func hoursAgo(_ hours: Int) -> String { "\(hours)h ago" }
    static func minutesAgo(_ minutes: Int) -> String { "\(minutes)m ago" }

    // States
    static let retry = "Retry"
    static let offlineTitle = "You’re offline"
    static let errorTitle = "Something went wrong"
    static let emptyTitle = "No articles yet"
    static let emptyMessage = "There are no articles to show right now."
    static let noResultsTitle = "No results"
    static let selectArticleTitle = "Select an article"
    static let selectArticleMessage = "Choose an article from the list to read it here."

    static func noResultsMessage(for searchText: String) -> String {
        "No articles match “\(searchText)”."
    }

    // Errors
    static let noInternetMessage = "Please connect to the internet and try again."
    static let serverErrorMessage = "Server is not responding right now. Please try again later."
    static let invalidDataMessage = "We couldn't read the articles. Please try again later."

    static func message(for error: APIError) -> String {
        switch error {
        case .noInternet:
            return noInternetMessage
        case .serverError:
            return serverErrorMessage
        case .invalidData:
            return invalidDataMessage
        }
    }
}
