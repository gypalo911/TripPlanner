//
//  MockNetworkService.swift
//  TripPlannerTests
//
//  Created by Petro Hupalo on 20/03/2025.
//

import Foundation
@testable import TripPlanner

struct MockNetworkService: NetworkService {
    var connectionsToReturn: [TripPlanner.ConnectionModel] = []
    var errorToThrow: Error?
    
    func fetchConnections() async throws -> [ConnectionModel] {
        if let error = errorToThrow {
            throw error
        }
        
        if connectionsToReturn.isEmpty {
            // Default mock data
            return [
                ConnectionModel(
                    from: "London",
                    to: "Paris",
                    price: 100.0,
                    coordinates: .init(
                        from: .init(lat: 51.5, long: -0.1),
                        to: .init(lat: 48.9, long: 2.3)
                    )
                ),
                ConnectionModel(
                    from: "Paris",
                    to: "Berlin",
                    price: 120.0,
                    coordinates: .init(
                        from: .init(lat: 48.9, long: 2.3),
                        to: .init(lat: 52.5, long: 13.4)
                    )
                )
            ]
        }
        
        return connectionsToReturn
    }
}
