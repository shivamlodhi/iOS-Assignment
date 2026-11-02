//
//  ToastHelper.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import UIKit
import Loaf

enum ToastHelper {

    static func showWarning(_ message: String, on viewController: UIViewController) {
        Loaf(message, state: .warning, location: .bottom, sender: viewController).show(.short)
    }
}
