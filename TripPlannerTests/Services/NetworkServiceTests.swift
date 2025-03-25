//
//  NetworkServiceTests.swift
//  TripPlannerTests
//
//  Created by Petro Hupalo on 19/03/2025.
//

import XCTest
@testable import TripPlanner

final class NetworkServiceTests: XCTestCase {
    
    private var sut: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        sut = MockNetworkService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testFetchConnections() async throws {
        // Given
        let expectedConnections = [
            ConnectionModel(
                from: "London",
                to: "Tokyo",
                price: 220.0,
                coordinates: .init(
                    from: .init(lat: 51.5285582, long: -0.241681),
                    to: .init(lat: 35.652832, long: 139.839478)
                )
            ),
            ConnectionModel(
                from: "Tokyo",
                to: "London",
                price: 200.0,
                coordinates: .init(
                    from: .init(lat: 35.652832, long: 139.839478),
                    to: .init(lat: 51.5285582, long: -0.241681)
                )
            )
        ]
        
        sut.connectionsToReturn = expectedConnections
        
        // When
        let fetchedConnections = try await sut.fetchConnections()
        
        // Then
        XCTAssertNotNil(fetchedConnections)
        XCTAssertEqual(fetchedConnections.count, 2)
        XCTAssertEqual(fetchedConnections[0].from, "London")
        XCTAssertEqual(fetchedConnections[0].to, "Tokyo")
        XCTAssertEqual(fetchedConnections[0].price, 220)
        XCTAssertEqual(fetchedConnections[1].from, "Tokyo")
        XCTAssertEqual(fetchedConnections[1].to, "London")
        XCTAssertEqual(fetchedConnections[1].price, 200)
    }
    
    func testFetchConnectionsThrowsErrorOnBadResponse() async {
        // Given
        sut.errorToThrow = NetworkError.serverError(statusCode: 404)
        
        // When/Then
        do {
            _ = try await sut.fetchConnections()
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertEqual(error as? NetworkError, NetworkError.serverError(statusCode: 404))
        }
    }
    
    func testFetchConnectionsThrowsErrorOnInvalidJSON() async {
        // Given
        sut.errorToThrow = NetworkError.decodingError("Invalid JSON")
        
        // When/Then
        do {
            _ = try await sut.fetchConnections()
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssert(error is NetworkError, "Error should be NetworkError but was \(type(of: error))")
            
            guard let networkError = error as? NetworkError else {
                XCTFail("Could not cast \(error) to NetworkError")
                return
            }
            
            switch networkError {
            case .decodingError(let message):
                XCTAssertEqual(message, "Invalid JSON", "Error message should match expected value")
            default:
                XCTFail("Expected NetworkError.decodingError but got \(networkError)")
            }
        }
    }
}
