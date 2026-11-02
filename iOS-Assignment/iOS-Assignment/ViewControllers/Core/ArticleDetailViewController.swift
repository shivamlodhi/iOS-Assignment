//
//  ArticleDetailViewController.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import UIKit
import SafariServices

final class ArticleDetailViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var clockImageView: UIImageView!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var imageContainerView: UIView!
    @IBOutlet private weak var articleImageView: ArticleImageView!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var readFullArticleButton: UIButton!
    @IBOutlet private weak var titleTopConstraint: NSLayoutConstraint!

    var article: Article!
    var favoritesManager: FavoritesManager!

    private let favoriteButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        showArticle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Dark header, so the status bar and bar content stay light
        navigationController?.navigationBar.overrideUserInterfaceStyle = .dark
        // iPad shows the detail as the root of its column, so there is nothing to go back to
        let canGoBack = navigationController?.viewControllers.first != self
        navigationItem.leftBarButtonItem = canGoBack ? makeBackButton() : nil
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        // Header runs behind the navigation bar, so push the title below it
        titleTopConstraint.constant = view.safeAreaInsets.top + 16
    }

    private func setupNavigationBar() {
        title = "Article"
        let transparent = UINavigationBarAppearance()
        transparent.configureWithTransparentBackground()
        transparent.titleTextAttributes = [.foregroundColor: UIColor.white, .font: AppFonts.navigationTitle]

        let scrolled = UINavigationBarAppearance()
        scrolled.configureWithOpaqueBackground()
        scrolled.backgroundColor = AppColors.cardBackground
        scrolled.shadowColor = .clear
        scrolled.titleTextAttributes = transparent.titleTextAttributes

        navigationItem.scrollEdgeAppearance = transparent
        navigationItem.standardAppearance = scrolled
        navigationItem.hidesBackButton = true
        favoriteButton.tintColor = .white
        favoriteButton.imageView?.contentMode = .scaleAspectFit
        favoriteButton.contentHorizontalAlignment = .fill
        favoriteButton.contentVerticalAlignment = .fill
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = makeBarItem(with: favoriteButton, size: CGSize(width: 30, height: 25), inset: -8)
        updateFavoriteButton()
    }

    // Round back button from the design
    private func makeBackButton() -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(AppIcons.back, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 22

        // Liquid Glass on iOS 26, plain see-through circle on older versions
        if #available(iOS 26.0, *) {
            let glass = UIGlassEffect()
            glass.tintColor = UIColor(red: 0.26, green: 0.35, blue: 0.38, alpha: 0.8)
            let glassView = UIVisualEffectView(effect: glass)
            glassView.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            glassView.isUserInteractionEnabled = false
            glassView.cornerConfiguration = .capsule()
            button.insertSubview(glassView, at: 0)
        } else {
            button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        }
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return makeBarItem(with: button, size: CGSize(width: 44, height: 44), inset: 8)
    }

    // Wraps the button so it sits 24pt from the screen edge like in the design
    private func makeBarItem(with button: UIButton, size: CGSize, inset: CGFloat) -> UIBarButtonItem {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: size.width + abs(inset), height: 44))
        button.frame = CGRect(x: max(inset, 0), y: (44 - size.height) / 2, width: size.width, height: size.height)
        container.addSubview(button)

        let item = UIBarButtonItem(customView: container)
        if #available(iOS 26.0, *) {
            item.hidesSharedBackground = true
        }
        return item
    }

    private func setupViews() {
        view.backgroundColor = AppColors.detailBackground
        headerView.backgroundColor = AppColors.cardBackground

        titleLabel.font = AppFonts.detailTitle
        titleLabel.textColor = .white
        titleLabel.adjustsFontForContentSizeCategory = true

        timeLabel.font = AppFonts.date
        timeLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        timeLabel.adjustsFontForContentSizeCategory = true
        clockImageView.image = AppIcons.clock
        clockImageView.tintColor = UIColor.white.withAlphaComponent(0.7)

        imageContainerView.layer.shadowColor = UIColor.black.cgColor
        imageContainerView.layer.shadowOpacity = 0.25
        imageContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        imageContainerView.layer.shadowRadius = 8

        bodyLabel.textColor = AppColors.bodyText
        bodyLabel.adjustsFontForContentSizeCategory = true

        var config = UIButton.Configuration.filled()
        config.title = "Read Full Article"
        config.image = UIImage(systemName: "safari")
        config.imagePlacement = .trailing
        config.imagePadding = 10
        config.baseBackgroundColor = AppColors.primaryBlue
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = AppFonts.button
            return attributes
        }
        readFullArticleButton.configuration = config
    }

    private func showArticle() {
        titleLabel.text = article.title ?? "Untitled article"

        timeLabel.text = DateHelper.timeAgo(from: article.publishedAt)
        clockImageView.isHidden = timeLabel.text == nil

        articleImageView.setImage(with: article.imageURL)

        let body = article.content ?? article.description ?? "No details available for this article."
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        bodyLabel.attributedText = NSAttributedString(string: body, attributes: [
            .font: AppFonts.body,
            .paragraphStyle: paragraphStyle
        ])

        // Some articles have a missing or broken link
        readFullArticleButton.isHidden = article.articleURL == nil
    }

    private func updateFavoriteButton() {
        let image = favoritesManager.isFavorite(article) ? AppIcons.favoriteSaved : AppIcons.favorite
        favoriteButton.setImage(image, for: .normal)
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func favoriteTapped() {
        favoritesManager.toggleFavorite(article)
        updateFavoriteButton()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    @IBAction private func readFullArticleTapped() {
        guard let url = article.articleURL else { return }
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredControlTintColor = AppColors.primaryBlue
        present(safariViewController, animated: true)
    }
}
