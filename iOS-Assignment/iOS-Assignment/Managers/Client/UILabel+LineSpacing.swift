//
//  UILabel+LineSpacing.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 03/11/26.
//

import UIKit

extension UILabel {

    // Sets the text with extra space between lines, keeping the label's font and colour
    func setText(_ text: String?, lineSpacing: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineBreakMode = .byTruncatingTail

        attributedText = NSAttributedString(string: text ?? "", attributes: [
            .font: font as UIFont,
            .foregroundColor: textColor as UIColor,
            .paragraphStyle: paragraphStyle
        ])
    }
}
