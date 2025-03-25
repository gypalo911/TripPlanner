//
//  NetworkError.swift
//  TripPlanner
//
//  Created by Petro Hupalo on 20/03/2025.
//

import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL
    case noData
    case serverError(statusCode: Int)
    case decodingError(String)
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.noData, .noData):
            return true
        case let (.serverError(lhsCode), .serverError(rhsCode)):
            return lhsCode == rhsCode
        case let (.decodingError(lhsMsg), .decodingError(rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }
}
