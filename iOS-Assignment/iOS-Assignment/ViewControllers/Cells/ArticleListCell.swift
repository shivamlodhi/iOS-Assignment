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

        var config = UIButton.Configuration.filled()
        config.title = "Read More"
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = AppFonts.button
            return attributes
        }
        config.image = AppIcons.readMore
        config.imagePlacement = .trailing
        config.imagePadding = 16
        config.baseBackgroundColor = AppColors.primaryBlue
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        readMoreButton.configuration = config
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onReadMore = nil
    }

    func configure(with article: Article) {
        titleLabel.text = article.title ?? article.description
        dateLabel.text = DateHelper.displayDate(from: article.publishedAt)
        calendarImageView.isHidden = dateLabel.text == nil
        articleImageView.setImage(with: article.imageURL)
    }

    @IBAction private func readMoreTapped() {
        onReadMore?()
    }
}
