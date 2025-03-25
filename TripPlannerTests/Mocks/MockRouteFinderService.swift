//
//  MockRouteFinderService.swift
//  TripPlannerTests
//
//  Created by Petro Hupalo on 23/03/2025.
//

import Foundation
import CoreLocation
@testable import TripPlanner

class MockRouteFinderService: RouteFinderService {
    var connections: [TripPlanner.ConnectionModel] = []
    
    var shouldReturnRoute = true
    var mockRoute: ResultRouteModel?
    
    func findCheapestRoute(from origin: String, to destination: String) -> ResultRouteModel? {
        if !shouldReturnRoute {
            return nil
        }
        
        if let mockRoute = mockRoute {
            return mockRoute
        }
        
        // Default mock response
        let connection = ConnectionModel(
            from: origin,
            to: destination,
            price: 100.0,
            coordinates: .init(
                from: .init(lat: 51.5, long: -0.1),
                to: .init(lat: 48.9, long: 2.3)
            )
        )
        
        return ResultRouteModel(
            cities: [origin, destination],
            totalPrice: 100.0,
            connections: [connection]
        )
    }
}
