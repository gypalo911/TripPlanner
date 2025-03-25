//
//  ResultRouteModel.swift
//  TripPlanner
//
//  Created by Petro Hupalo on 20/03/2025.
//

import Foundation
import CoreLocation

struct ResultRouteModel {
    let cities: [String]
    let totalPrice: Double
    let connections: [ConnectionModel]
    
    var formattedPrice: String {
        return String(format: "%.2f €", totalPrice)
    }
    
    var formattedPath: String {
        return cities.joined(separator: " → ")
    }
}

extension ResultRouteModel {
    var routeCoordinates: [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        
        if let firstConnection = connections.first {
            coordinates.append(firstConnection.coordinates.from.clLocation)
        }
        
        for connection in connections {
            coordinates.append(connection.coordinates.to.clLocation)
        }
        
        return coordinates
    }
}
