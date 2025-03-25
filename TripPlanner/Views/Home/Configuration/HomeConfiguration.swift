//
//  HomeConfiguration.swift
//  TripPlanner
//
//  Created by Petro Hupalo on 23/03/2025.
//

import SwiftUI

extension Home {
    /// Configuration for Home dependencies
    struct Configuration {
        let networkService: NetworkService
        let routeFinder: RouteFinderService
        
        init(
            networkService: NetworkService = DefaultNetworkService(),
            routeFinder: RouteFinderService = DefaultRouteFinderService()
        ) {
            self.networkService = networkService
            self.routeFinder = routeFinder
        }
    }
}
