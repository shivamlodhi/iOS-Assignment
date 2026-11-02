//
//  AppIcons.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import UIKit

enum AppIcons {
    private static let navigationBarConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)

    // Symbol names, also used by the SwiftUI state view
    static let offlineSymbol = "wifi.slash"
    static let errorSymbol = "exclamationmark.triangle"
    static let articleSymbol = "newspaper"
    static let searchSymbol = "magnifyingglass"
    static let retrySymbol = "arrow.counterclockwise"

    static let grid = UIImage(systemName: "square.grid.2x2.fill", withConfiguration: navigationBarConfig)
    static let list = UIImage(systemName: "list.bullet", withConfiguration: navigationBarConfig)
    static let search = UIImage(systemName: searchSymbol, withConfiguration: navigationBarConfig)
    static let calendar = UIImage(systemName: "calendar")
    static let clock = UIImage(systemName: "clock")
    static let readMore = UIImage(systemName: "arrow.right.circle.fill")
    static let safari = UIImage(systemName: "safari")
    static let back = UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .medium))
    static let favorite = UIImage(resource: .favorite)
    static let favoriteSaved = UIImage(resource: .favoriteSaved)
    static let placeholder = UIImage(systemName: articleSymbol)
}
