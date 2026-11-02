//
//  DateHelper.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import Foundation

enum DateHelper {

    private static let isoFormatter = ISO8601DateFormatter()

    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM,yyyy"
        return formatter
    }()

    // "2025-03-07T11:00:59Z" -> "07 Mar,2025"
    static func displayDate(from string: String?) -> String? {
        guard let string, let date = isoFormatter.date(from: string) else { return nil }
        return displayFormatter.string(from: date)
    }
}
