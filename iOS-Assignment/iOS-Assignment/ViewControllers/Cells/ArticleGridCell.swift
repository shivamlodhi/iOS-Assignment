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
        contentView.layer.cornerRadius = AppMetrics.cornerRadius
        // No blue focus ring on iPad, the design has none
        focusEffect = nil

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
        titleLabel.setText(article.displayTitle ?? AppStrings.untitledArticle, lineSpacing: 6)
        articleImageView.setImage(with: article.imageURL)
    }
}
