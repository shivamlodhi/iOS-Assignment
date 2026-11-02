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
    case timeout
    case serverError(Int)
    case invalidData
    case unknown

    init(_ error: AFError) {
        if let urlError = error.underlyingError as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                self = .noInternet
            case .timedOut:
                self = .timeout
            default:
                self = .unknown
            }
        } else if let code = error.responseCode {
            self = .serverError(code)
        } else if error.isResponseSerializationError {
            self = .invalidData
        } else {
            self = .unknown
        }
    }

    var message: String {
        switch self {
        case .noInternet:
            return "Please connect to the internet and try again."
        case .timeout:
            return "The request timed out. Please try again."
        case .serverError:
            return "Server is not responding right now. Please try again later."
        case .invalidData:
            return "We couldn't read the articles. Please try again later."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
