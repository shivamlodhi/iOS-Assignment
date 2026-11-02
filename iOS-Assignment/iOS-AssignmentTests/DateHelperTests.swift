//
//  DateHelperTests.swift
//  iOS-AssignmentTests
//
//  Created by Shivam Lodhi on 03/11/26.
//

import XCTest
@testable import iOS_Assignment

final class DateHelperTests: XCTestCase {

    func testDisplayDate() {
        XCTAssertEqual(DateHelper.displayDate(from: "2025-03-07T11:00:59Z"), "07 Mar,2025")
    }

    func testInvalidDateGivesNil() {
        XCTAssertNil(DateHelper.displayDate(from: "wrong date"))
        XCTAssertNil(DateHelper.timeAgo(from: nil))
    }

    func testTimeAgo() {
        let threeHoursAgo = ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3 * 60 * 60))

        XCTAssertEqual(DateHelper.timeAgo(from: threeHoursAgo), "3h ago")
    }
}
