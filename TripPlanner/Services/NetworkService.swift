//
//  NetworkService.swift
//  TripPlanner
//
//  Created by Petro Hupalo on 20/03/2025.
//

import Foundation
import UIKit

protocol NetworkService {
    func fetchConnections() async throws -> [ConnectionModel]
}

struct DefaultNetworkService: NetworkService {

    // MARK: - Properties
    
    private let connectionsURL: URL
    
    // MARK: - Lifecycle

    init(connectionsURL: URL = URL(string: "https://raw.githubusercontent.com/TuiMobilityHub/ios-code-challenge/master/connections.json")!) {
        self.connectionsURL = connectionsURL
    }
    
    // MARK: - Public
    
    func fetchConnections() async throws -> [ConnectionModel] {
        do {
            let (data, response) = try await URLSession.shared.data(from: connectionsURL)
            let result: Connections = try handleResponse(data: data, response: response)
            return result.connections
        } catch {
            throw error
        }
    }
    
    // MARK: - Private

    private func handleResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let result = try JSONDecoder().decode(T.self, from: data)
            return result
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }
}
