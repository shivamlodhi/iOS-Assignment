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
        } else if error.responseCode != nil {
            self = .serverError
        } else {
            self = .noInternet
        }
    }

    var message: String {
        switch self {
        case .noInternet:
            return "Please connect to the internet and try again."
        case .serverError:
            return "Server is not responding right now. Please try again later."
        case .invalidData:
            return "We couldn't read the articles. Please try again later."
        }
    }
}
