//
//  AppFonts.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import UIKit

// All fonts scale with Dynamic Type
enum AppFonts {
    static var screenTitle: UIFont {
        scaled(.systemFont(ofSize: 30, weight: .bold, width: .condensed), style: .largeTitle)
    }

    static var cardTitle: UIFont {
        scaled(.systemFont(ofSize: 15, weight: .semibold), style: .headline)
    }

    static var date: UIFont {
        scaled(.systemFont(ofSize: 12, weight: .regular), style: .footnote)
    }

    static var time: UIFont {
        scaled(.systemFont(ofSize: 14, weight: .regular), style: .subheadline)
    }

    static var button: UIFont {
        scaled(.systemFont(ofSize: 14, weight: .semibold), style: .subheadline)
    }

    static var navigationTitle: UIFont {
        scaled(.systemFont(ofSize: 18, weight: .semibold), style: .headline)
    }

    static var detailTitle: UIFont {
        scaled(.systemFont(ofSize: 22, weight: .bold), style: .title2)
    }

    static var body: UIFont {
        scaled(.systemFont(ofSize: 16, weight: .regular), style: .body)
    }

    private static func scaled(_ font: UIFont, style: UIFont.TextStyle) -> UIFont {
        UIFontMetrics(forTextStyle: style).scaledFont(for: font)
    }
}
