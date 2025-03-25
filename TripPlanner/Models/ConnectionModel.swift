//
//  ConnectionModel.swift
//  TripPlanner
//
//  Created by Petro Hupalo on 19/03/2025.
//

import Foundation
import CoreLocation

// MARK: Connections

struct Connections: Decodable {
    let connections: [ConnectionModel]
}

// MARK: ConnectionModel

struct ConnectionModel: Decodable, Equatable {
    let from: String
    let to: String
    let price: Double
    let coordinates: Coordinates
    
    struct Coordinates: Decodable, Equatable {
        let from: Location
        let to: Location
        
        struct Location: Decodable, Equatable {
            let lat: Double
            let long: Double
            
            var clLocation: CLLocationCoordinate2D {
                CLLocationCoordinate2D(latitude: lat, longitude: long)
            }
        }
    }
}
