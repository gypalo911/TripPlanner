//
//  RouteFinderService.swift
//  TripPlanner
//
//  Created by Petro Hupalo on 20/03/2025.
//

import Foundation

protocol RouteFinderService {
    var connections: [ConnectionModel] { get set }
    func findCheapestRoute(from origin: String, to destination: String) -> ResultRouteModel?
}

class DefaultRouteFinderService: RouteFinderService {
    
    // MARK: - Properties
    
    private var graph: [String: Node] = [:]
    
    var connections: [ConnectionModel] = [] {
        didSet {
            buildGraph()
        }
    }
    
    // MARK: - Lifecycle
    
    init() {}
    
    // MARK: - Public
    
    func findCheapestRoute(from origin: String, to destination: String) -> ResultRouteModel? {
        guard let sourceNode = graph[origin], let destinationNode = graph[destination] else {
            return nil
        }

        graph.forEach({ $0.value.visited = false })

        guard let path = findPathWithDijkstrasAlgorithm(from: sourceNode, to: destinationNode) else {
            return nil
        }

        return ResultRouteModel(
            cities: path.cities,
            totalPrice: path.totalCost,
            connections: path.connections
        )
    }
    
    // MARK: - Private
    
    private func buildGraph() {
        var nodesDict: [String: Node] = [:]
        
        for connection in connections {
            let fromNode: Node
            if let existingNode = nodesDict[connection.from] {
                fromNode = existingNode
            } else {
                fromNode = Node(city: connection.from)
                nodesDict[connection.from] = fromNode
            }
            
            let toNode: Node
            if let existingNode = nodesDict[connection.to] {
                toNode = existingNode
            } else {
                toNode = Node(city: connection.to)
                nodesDict[connection.to] = toNode
            }
            
            let newConnection = Connection(
                to: toNode,
                cost: connection.price,
                originalConnection: connection
            )
            
            fromNode.connections.append(newConnection)
        }
        
        graph = nodesDict
    }
    
    private func findPathWithDijkstrasAlgorithm(from source: Node, to destination: Node) -> Path? {
        var frontier: [Path] = [] {
            didSet {
                frontier.sort { $0.totalCost < $1.totalCost }
            }
        }
        
        frontier.append(Path(to: source))
        
        while !frontier.isEmpty {
            let cheapestPathInFrontier = frontier.removeFirst()
            
            guard !cheapestPathInFrontier.node.visited else {
                continue
            }
            
            if cheapestPathInFrontier.node === destination {
                return cheapestPathInFrontier
            }
            
            cheapestPathInFrontier.node.visited = true
            
            for connection in cheapestPathInFrontier.node.connections where !connection.to.visited {
                frontier.append(
                    Path(
                        to: connection.to,
                        via: connection,
                        previousPath: cheapestPathInFrontier
                    )
                )
            }
        }
        
        return nil
    }
}


extension DefaultRouteFinderService {
    
    class Node {
        let city: String
        var visited = false
        var connections: [Connection] = []
        
        init(city: String) {
            self.city = city
        }
    }
    
    class Connection {
        let to: Node
        let cost: Double
        let originalConnection: ConnectionModel
        
        init(to: Node, cost: Double, originalConnection: ConnectionModel) {
            self.to = to
            self.cost = cost
            self.originalConnection = originalConnection
        }
    }
    
    class Path {
        let totalCost: Double
        let node: Node
        let previousPath: Path?
        let connection: Connection?
        
        init(to node: Node, via connection: Connection? = nil, previousPath: Path? = nil) {
            if let previousPath = previousPath, let connection = connection {
                self.totalCost = connection.cost + previousPath.totalCost
            } else {
                self.totalCost = 0
            }
            self.node = node
            self.previousPath = previousPath
            self.connection = connection
        }
        
        var connections: [ConnectionModel] {
            var result: [ConnectionModel] = []
            var current: Path? = self
            
            while let path = current, let conn = path.connection {
                result.insert(conn.originalConnection, at: 0)
                current = path.previousPath
            }
            
            return result
        }
        
        var cities: [String] {
            var result: [String] = []
            var current: Path? = self
            
            while let path = current {
                result.insert(path.node.city, at: 0)
                current = path.previousPath
            }
            
            return result
        }
    }
}
