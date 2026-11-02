//
//  ArticleImageView.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import UIKit
import Kingfisher

// Article image with a placeholder icon that stays visible when the image is missing or fails
final class ArticleImageView: UIView {

    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var placeholderImageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib()
    }

    private func loadFromNib() {
        Bundle.main.loadNibNamed("ArticleImageView", owner: self)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)

        layer.cornerRadius = 8
        clipsToBounds = true
        contentView.backgroundColor = AppColors.placeholderBackground
        placeholderImageView.image = AppIcons.placeholder
        placeholderImageView.tintColor = AppColors.placeholderIcon
    }

    func setImage(with url: URL?) {
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        guard let url else { return }

        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url, options: [.transition(.fade(0.25))])
    }
}
