//
//  HomeViewModel.swift
//  TripPlanner
//
//  Created by Petro Hupalo on 20/03/2025.
//

import Foundation
import Combine
import CoreLocation
import SwiftUI

extension Home {
    enum ViewState {
        case initial
        case loading(title: String, subtitle: String? = nil)
        case loaded(ResultRouteModel)
        case error(String)
    }
    
    /// ViewModel for Home
    class ViewModel: ObservableObject {
        
        // MARK: - Properties
        
        @Published var originCity = ""
        @Published var destinationCity = ""
        @Published var state: ViewState = .loading(
            title: "Loading connections...",
            subtitle: "Please wait while we fetch the latest routes"
        )
        @Published var filteredOriginCities: [String] = []
        @Published var filteredDestinationCities: [String] = []
        @Published var isOriginSearchActive = false
        @Published var isDestinationSearchActive = false
        
        var isSearchButtonEnabled: Bool {
            !(originCity.isEmpty || destinationCity.isEmpty)
        }
        
        private let networkService: NetworkService
        private var routeFinder: RouteFinderService
        
        private var cities: [String] = []
        
        // MARK: - Lifecycle
        
        init(
            networkService: NetworkService,
            routeFinder: RouteFinderService
        ) {
            self.networkService = networkService
            self.routeFinder = routeFinder
        }
        
        // MARK: - Public
        
        func loadConnections() async {
            await MainActor.run {
                state = .loading(
                    title: "Loading connections...",
                    subtitle: "Please wait while we fetch the latest routes"
                )
            }
            
            do {
                // Simulate loading for longer time to show loading state
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                
                let connections = try await networkService.fetchConnections()
                let cities = extractCities(from: connections)
                routeFinder.connections = connections
                
                await MainActor.run {
                    self.cities = cities
                    self.filteredOriginCities = cities
                    self.filteredDestinationCities = cities
                    
                    self.state = .initial
                }
            } catch let error {
                await MainActor.run {
                    state = .error("Error during loading")
                    debugPrint("ERROR during loading: \(error)")
                }
            }
        }
        
        func filterOriginCities(with query: String) {
            if query.isEmpty {
                filteredOriginCities = cities
            } else {
                filteredOriginCities = cities.filter { $0.lowercased().contains(query.lowercased()) }
            }
        }
        
        func filterDestinationCities(with query: String) {
            if query.isEmpty {
                filteredDestinationCities = cities
            } else {
                filteredDestinationCities = cities.filter { $0.lowercased().contains(query.lowercased()) }
            }
        }
        
        func findRoute() {
            state = .loading(
                title: "Searching for route...",
                subtitle: "Travel is the only thing you buy that makes you richer"
            )
            guard !originCity.isEmpty && !destinationCity.isEmpty else {
                state = .error("Please select both origin and destination cities")
                return
            }
            
            if let route = routeFinder.findCheapestRoute(from: originCity, to: destinationCity) {
                state = .loaded(route)
            } else {
                state = .error("No route found between \(originCity) and \(destinationCity)")
            }
        }
        
        // MARK: - Private
        
        private func extractCities(from connections: [ConnectionModel]) -> [String] {
            var cities = Set<String>()
            
            for connection in connections {
                cities.insert(connection.from)
                cities.insert(connection.to)
            }
            
            return Array(cities).sorted()
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
