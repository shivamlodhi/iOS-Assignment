//
//  ArticleGridCell.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import UIKit

final class ArticleGridCell: UICollectionViewCell {

    static let identifier = "ArticleGridCell"

    @IBOutlet private weak var articleImageView: ArticleImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = AppColors.cardBackground
        contentView.layer.cornerRadius = 8

        titleLabel.font = AppFonts.cardTitle
        titleLabel.textColor = .white
        titleLabel.adjustsFontForContentSizeCategory = true

        updateForTextSize()
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (cell: Self, _) in
            cell.updateForTextSize()
        }
    }

    private func updateForTextSize() {
        titleLabel.numberOfLines = traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? 0 : 2
    }

    func configure(with article: Article) {
        titleLabel.setText(article.title ?? article.description, lineSpacing: 6)
        articleImageView.setImage(with: article.imageURL)
    }
}
