//
//  AppMetrics.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 03/11/26.
//

import UIKit

// Sizes and spacing from the design
enum AppMetrics {
    static let cornerRadius: CGFloat = 8

    // Navigation bar
    static let barButtonSize: CGFloat = 44
    static let favoriteIconSize = CGSize(width: 30, height: 25)
    static let navigationButtonSpacing: CGFloat = 14
    // Moves the bar buttons so they sit 24pt from the screen edge
    static let backButtonInset: CGFloat = 8
    static let favoriteButtonInset: CGFloat = -8

    // Space between the bottom of the navigation bar and the detail title
    static let detailTitleTopSpacing: CGFloat = 16
}
