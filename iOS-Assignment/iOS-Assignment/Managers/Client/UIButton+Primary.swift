//
//  UIButton+Primary.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 03/11/26.
//

import UIKit

extension UIButton.Configuration {

    // Blue button with the icon after the title, used for Read More and Read Full Article
    static func primary(title: String, image: UIImage?, imagePadding: CGFloat) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = image
        config.imagePlacement = .trailing
        config.imagePadding = imagePadding
        config.baseBackgroundColor = AppColors.primaryBlue
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = AppFonts.button
            return attributes
        }
        return config
    }
}
