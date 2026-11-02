//
//  APIClient.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import Foundation
import Alamofire

final class APIClient {

    private let session: Session

    init() {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 20
        session = Session(configuration: configuration, eventMonitors: [NetworkLogger()])
    }

    func get<T: Decodable>(_ url: String, completion: @escaping (Result<T, APIError>) -> Void) {
        session.request(url)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    completion(.success(value))
                case .failure(let error):
                    completion(.failure(APIError(error)))
                }
            }
    }
}
