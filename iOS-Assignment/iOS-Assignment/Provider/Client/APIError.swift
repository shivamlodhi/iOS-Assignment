//
//  APIError.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import Foundation
import Alamofire

enum APIError: Error {
    case noInternet
    case serverError
    case invalidData

    init(_ error: AFError) {
        if error.isResponseSerializationError {
            self = .invalidData
        } else if let urlError = error.underlyingError as? URLError,
                  [.notConnectedToInternet, .networkConnectionLost, .dataNotAllowed].contains(urlError.code) {
            self = .noInternet
        } else {
            // Server errors, timeouts and anything else
            self = .serverError
        }
    }
}
