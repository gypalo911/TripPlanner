//
//  RouteFinderServiceTests.swift
//  TripPlannerTests
//
//  Created by Petro Hupalo on 23/03/2025.
//

import XCTest
@testable import TripPlanner

final class RouteFinderServiceTests: XCTestCase {
    
    private var sut: DefaultRouteFinderService!
    
    override func setUp() {
        super.setUp()
        sut = DefaultRouteFinderService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testFindCheapestRouteDirectConnection() {
        // Given
        let londonToParis = ConnectionModel(
            from: "London",
            to: "Paris",
            price: 100.0,
            coordinates: .init(
                from: .init(lat: 51.5, long: -0.1),
                to: .init(lat: 48.9, long: 2.3)
            )
        )
        
        sut.connections = [londonToParis]
        
        // When
        let route = sut.findCheapestRoute(from: "London", to: "Paris")
        
        // Then
        XCTAssertNotNil(route)
        XCTAssertEqual(route?.cities, ["London", "Paris"])
        XCTAssertEqual(route?.totalPrice, 100.0)
        XCTAssertEqual(route?.connections.count, 1)
    }
    
    func testFindCheapestRouteMultipleConnections() {
        // Given
        let londonToParis = ConnectionModel(
            from: "London",
            to: "Paris",
            price: 100.0,
            coordinates: .init(
                from: .init(lat: 51.5, long: -0.1),
                to: .init(lat: 48.9, long: 2.3)
            )
        )
        
        let parisToBerlin = ConnectionModel(
            from: "Paris",
            to: "Berlin",
            price: 120.0,
            coordinates: .init(
                from: .init(lat: 48.9, long: 2.3),
                to: .init(lat: 52.5, long: 13.4)
            )
        )
        
        let londonToBerlin = ConnectionModel(
            from: "London",
            to: "Berlin",
            price: 250.0,
            coordinates: .init(
                from: .init(lat: 51.5, long: -0.1),
                to: .init(lat: 52.5, long: 13.4)
            )
        )
        
        sut.connections = [londonToParis, parisToBerlin, londonToBerlin]
        
        // When
        let route = sut.findCheapestRoute(from: "London", to: "Berlin")
        
        // Then
        XCTAssertNotNil(route)
        XCTAssertEqual(route?.cities, ["London", "Paris", "Berlin"])
        XCTAssertEqual(route?.totalPrice, 220.0) // 100 + 120
        XCTAssertEqual(route?.connections.count, 2)
    }
    
    func testFindCheapestRouteNoRoute() {
        // Given
        let londonToParis = ConnectionModel(
            from: "London",
            to: "Paris",
            price: 100.0,
            coordinates: .init(
                from: .init(lat: 51.5, long: -0.1),
                to: .init(lat: 48.9, long: 2.3)
            )
        )
        
        sut.connections = [londonToParis]
        
        // When
        let route = sut.findCheapestRoute(from: "London", to: "Berlin")
        
        // Then
        XCTAssertNil(route)
    }
    
    func testFindCheapestRouteSameOriginAndDestination() {
        // Given
        let londonToParis = ConnectionModel(
            from: "London",
            to: "Paris",
            price: 100.0,
            coordinates: .init(
                from: .init(lat: 51.5, long: -0.1),
                to: .init(lat: 48.9, long: 2.3)
            )
        )
        
        sut.connections = [londonToParis]
        
        // When
        let route = sut.findCheapestRoute(from: "London", to: "London")
        
        // Then
        XCTAssertNotNil(route)
        XCTAssertEqual(route?.cities, ["London"])
        XCTAssertEqual(route?.totalPrice, 0.0)
        XCTAssertEqual(route?.connections.count, 0)
    }
}
