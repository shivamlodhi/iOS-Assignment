//
//  AppIcons.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import UIKit

enum AppIcons {
    private static let navigationBarConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)

    static let grid = UIImage(systemName: "square.grid.2x2.fill", withConfiguration: navigationBarConfig)
    static let list = UIImage(systemName: "list.bullet", withConfiguration: navigationBarConfig)
    static let search = UIImage(systemName: "magnifyingglass", withConfiguration: navigationBarConfig)
    static let calendar = UIImage(systemName: "calendar")
    static let clock = UIImage(systemName: "clock")
    static let readMore = UIImage(systemName: "arrow.right.circle.fill")
    static let back = UIImage(systemName: "arrow.left")
    static let favorite = UIImage(systemName: "heart")
    static let favoriteFilled = UIImage(systemName: "heart.fill")
    static let offline = UIImage(systemName: "wifi.slash")
    static let retry = UIImage(systemName: "arrow.clockwise")
    static let placeholder = UIImage(systemName: "newspaper")
}
