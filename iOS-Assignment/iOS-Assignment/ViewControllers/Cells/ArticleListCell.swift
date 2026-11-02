//
//  ArticleListCell.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import UIKit

final class ArticleListCell: UICollectionViewCell {

    static let identifier = "ArticleListCell"

    @IBOutlet private weak var articleImageView: ArticleImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var calendarImageView: UIImageView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var readMoreButton: UIButton!
    @IBOutlet private weak var footerStackView: UIStackView!

    var onReadMore: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = AppColors.cardBackground
        contentView.layer.cornerRadius = 8

        titleLabel.font = AppFonts.cardTitle
        titleLabel.textColor = .white
        titleLabel.adjustsFontForContentSizeCategory = true

        dateLabel.font = AppFonts.date
        dateLabel.textColor = AppColors.dateText
        dateLabel.adjustsFontForContentSizeCategory = true
        calendarImageView.image = AppIcons.calendar
        calendarImageView.tintColor = AppColors.dateText

        readMoreButton.configuration = .primary(title: AppStrings.readMore, image: AppIcons.readMore, imagePadding: 16)

        updateForTextSize()
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (cell: Self, _) in
            cell.updateForTextSize()
        }
    }

    // With accessibility text sizes the date and button don't fit in one row
    private func updateForTextSize() {
        let isLargeText = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        footerStackView.axis = isLargeText ? .vertical : .horizontal
        footerStackView.alignment = isLargeText ? .leading : .center
        titleLabel.numberOfLines = isLargeText ? 0 : 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onReadMore = nil
    }

    func configure(with article: Article) {
        titleLabel.setText(article.title ?? article.description, lineSpacing: 6)
        dateLabel.text = DateHelper.displayDate(from: article.publishedAt)
        calendarImageView.isHidden = dateLabel.text == nil
        articleImageView.setImage(with: article.imageURL)
    }

    @IBAction private func readMoreTapped() {
        onReadMore?()
    }
}
