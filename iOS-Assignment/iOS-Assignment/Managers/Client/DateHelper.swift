//
//  DateHelper.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import Foundation

enum DateHelper {

    private static let isoFormatter = ISO8601DateFormatter()

    // Some dates come as "2025-03-07T11:00:59.000Z"
    private static let fractionalIsoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        // Fixed English month names, the rest of the app text is English too
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd MMM,yyyy"
        return formatter
    }()

    // "2025-03-07T11:00:59Z" -> "07 Mar,2025"
    static func displayDate(from string: String?) -> String? {
        guard let date = date(from: string) else { return nil }
        return displayFormatter.string(from: date)
    }

    // "2025-03-07T11:00:59Z" -> "10h ago"
    static func timeAgo(from string: String?) -> String? {
        guard let date = date(from: string) else { return nil }

        let parts = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: Date())
        if let years = parts.year, years > 0 { return AppStrings.yearsAgo(years) }
        if let months = parts.month, months > 0 { return AppStrings.monthsAgo(months) }
        if let days = parts.day, days > 0 { return AppStrings.daysAgo(days) }
        if let hours = parts.hour, hours > 0 { return AppStrings.hoursAgo(hours) }
        if let minutes = parts.minute, minutes > 0 { return AppStrings.minutesAgo(minutes) }
        return AppStrings.justNow
    }

    private static func date(from string: String?) -> Date? {
        guard let string else { return nil }
        return isoFormatter.date(from: string) ?? fractionalIsoFormatter.date(from: string)
    }
}
