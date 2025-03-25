//
//  ConnectionParserTests.swift
//  TripPlannerTests
//
//  Created by Petro Hupalo on 19/03/2025.
//

import XCTest
@testable import TripPlanner

final class ConnectionParserTests: XCTestCase {
    func testParseConnectionsFromJSON() throws {
        let jsonString = """
        {
          "connections": [
            {
              "from": "London",
              "to": "Tokyo",
              "coordinates": {
                "from": {
                  "lat": 51.5285582,
                  "long": -0.241681
                },
                "to": {
                  "lat": 35.652832,
                  "long": 139.839478
                }
              },
              "price": 220
            },
            {
              "from": "Tokyo",
              "to": "London",
              "coordinates": {
                "from": {
                  "lat": 35.652832,
                  "long": 139.839478
                },
                "to": {
                  "lat": 51.5285582,
                  "long": -0.241681
                }
              },
              "price": 200
            }
          ]
        }
        """
        
        let expectedEntity = Connections(connections: [
            .init(
                from: "London",
                to: "Tokyo",
                price: 220,
                coordinates: .init(
                    from: .init(
                        lat: 51.5285582,
                        long: -0.241681
                    ),
                    to: .init(
                        lat: 35.652832,
                        long: 139.839478
                    )
                )
            ),
            .init(
                from: "Tokyo",
                to: "London",
                price: 200,
                coordinates: .init(
                    from: .init(
                        lat: 35.652832,
                        long: 139.839478
                    ),
                    to: .init(
                        lat: 51.5285582,
                        long: -0.241681
                    )
                )
            ),
        ])

        // When
        let jsonData = jsonString.data(using: .utf8)!
        let result = try? JSONDecoder().decode(Connections.self, from: jsonData)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.connections.count, 2)
        XCTAssertEqual(result?.connections[0], expectedEntity.connections[0])
        XCTAssertEqual(result?.connections[1], expectedEntity.connections[1])
    }
}
