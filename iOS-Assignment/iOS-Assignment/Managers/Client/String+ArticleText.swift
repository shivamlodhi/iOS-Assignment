//
//  String+ArticleText.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 03/11/26.
//

import Foundation

extension String {

    // The API text can have HTML tags, HTML entities, Windows line breaks and a "[+1234" cut marker
    var cleanedArticleText: String {
        var text = replacingOccurrences(of: "\r\n", with: "\n")
        text = text.replacingOccurrences(of: "<li>", with: "\n• ")
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "\\s*\\[\\+\\d+( chars\\])?\\s*", with: "\n\n", options: .regularExpression)
        for (entity, character) in Self.htmlEntities {
            text = text.replacingOccurrences(of: entity, with: character)
        }
        text = text.replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // &amp; goes last so "&amp;quot;" doesn't turn into a quote
    private static let htmlEntities = [
        ("&#039;", "'"), ("&#39;", "'"), ("&quot;", "\""), ("&lt;", "<"),
        ("&gt;", ">"), ("&nbsp;", " "), ("&amp;", "&")
    ]
}
