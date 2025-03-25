//
//  HomeViewModelTests.swift
//  TripPlannerTests
//
//  Created by Petro Hupalo on 23/03/2025.
//

import XCTest
import CoreLocation
@testable import TripPlanner

final class HomeViewModelTests: XCTestCase {
    
    private var sut: Home.ViewModel!
    private var mockNetworkService: MockNetworkService!
    private var mockRouteFinderService: MockRouteFinderService!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockRouteFinderService = MockRouteFinderService()
        sut = Home.ViewModel(
            networkService: mockNetworkService,
            routeFinder: mockRouteFinderService
        )
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        mockRouteFinderService = nil
        super.tearDown()
    }
    
    func testLoadConnectionsSuccess() async {
        // Given
        let connections = [
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
        
        mockNetworkService.connectionsToReturn = connections
        
        // When
        await sut.loadConnections()
        
        // Then
        XCTAssertEqual(sut.state, .initial)
        XCTAssertEqual(sut.filteredOriginCities.sorted(), ["Berlin", "London", "Paris"].sorted())
        XCTAssertEqual(sut.filteredDestinationCities.sorted(), ["Berlin", "London", "Paris"].sorted())
        XCTAssertEqual(mockRouteFinderService.connections, connections)
    }
    
    func testLoadConnectionsError() async {
        // Given
        mockNetworkService.errorToThrow = NetworkError.serverError(statusCode: 404)
        sut = Home.ViewModel(
            networkService: mockNetworkService,
            routeFinder: mockRouteFinderService
        )
        
        // When
        await sut.loadConnections()
        
        // Then
        if case .error(let message) = sut.state {
            XCTAssertEqual(message, "Error during loading")
        } else {
            XCTFail("Expected error state")
        }
    }
    
    func testFilterOriginCities() async {
        // Given
        await preloadConnections()
        
        // When
        sut.filterOriginCities(with: "pa")
        
        // Then
        XCTAssertEqual(sut.filteredOriginCities, ["Paris"])
    }
    
    func testFilterDestinationCities() async {
        // Given
        await preloadConnections()
        
        // When
        sut.filterDestinationCities(with: "on")
        
        // Then
        XCTAssertEqual(sut.filteredDestinationCities, ["London"])
    }
    
    func testFilterCitiesCaseInsensitive() async {
        // Given
        await preloadConnections()
        
        // When
        sut.filterOriginCities(with: "LON")
        
        // Then
        XCTAssertEqual(sut.filteredOriginCities, ["London"])
    }
    
    func testFindRouteEmptyCities() {
        // Given
        sut.originCity = ""
        sut.destinationCity = "Paris"
        
        // When
        sut.findRoute()
        
        // Then
        if case .error(let message) = sut.state {
            XCTAssertEqual(message, "Please select both origin and destination cities")
        } else {
            XCTFail("Expected error state")
        }
    }
    
    func testFindRouteSuccess() {
        // Given
        sut.originCity = "London"
        sut.destinationCity = "Paris"
        
        let londonToParis = ConnectionModel(
            from: "London",
            to: "Paris",
            price: 100.0,
            coordinates: .init(
                from: .init(lat: 51.5, long: -0.1),
                to: .init(lat: 48.9, long: 2.3)
            )
        )
        
        let mockRoute = ResultRouteModel(
            cities: ["London", "Paris"],
            totalPrice: 100.0,
            connections: [londonToParis]
        )
        
        mockRouteFinderService.mockRoute = mockRoute
        
        // When
        sut.findRoute()
        
        // Then
        if case .loaded(let route) = sut.state {
            XCTAssertEqual(route.formattedPrice, "100.00 €")
            XCTAssertEqual(route.formattedPath, "London → Paris")
            XCTAssertEqual(route.routeCoordinates.count, 2)
        } else {
            XCTFail("Expected loaded state")
        }
    }
    
    func testFindRouteNoRouteFound() {
        // Given
        sut.originCity = "London"
        sut.destinationCity = "Tokyo"
        mockRouteFinderService.shouldReturnRoute = false
        
        // When
        sut.findRoute()
        
        // Then
        if case .error(let message) = sut.state {
            XCTAssertEqual(message, "No route found between London and Tokyo")
        } else {
            XCTFail("Expected error state")
        }
    }
    
    func testExtractCitiesFromConnections() async {
        // Given
        let connections = [
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
            ),
            ConnectionModel(
                from: "Paris",
                to: "London",
                price: 90.0,
                coordinates: .init(
                    from: .init(lat: 48.9, long: 2.3),
                    to: .init(lat: 51.5, long: -0.1)
                )
            )
        ]
        
        mockNetworkService.connectionsToReturn = connections
        
        // When
        await sut.loadConnections()
            
        // Then
        XCTAssertEqual(sut.filteredOriginCities.sorted(), ["Berlin", "London", "Paris"])
        XCTAssertEqual(sut.filteredDestinationCities.sorted(), ["Berlin", "London", "Paris"])
    }

    private func preloadConnections() async {
        let connections = [
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
        
        mockNetworkService.connectionsToReturn = connections
        await sut.loadConnections()
    }
    
}
