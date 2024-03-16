//
//  Graph.swift
//  Compilers_lab_01
//
//  Created by Serguei Diaz on 21.02.2024.
//

import Foundation

struct Graph<V, N> {
    
    var nodes: [Node<V, N>] = []
        
    init(initialNodeValue: N) {
        nodes.append(.init(value: initialNodeValue))
    }
    
    init(nodes: [Node<V, N>]) {
        self.nodes = nodes
    }
    
    func copy() -> Graph<V, N> {
        var nodesId: Dictionary<UUID, Int> = [:]
        nodes.enumerated().forEach { (index, node) in
            nodesId[node.id] = index
        }
        
        let nodesCopy = nodes.map { node in
            Node(value: node.value, vertices: node.vertices)
        }
        
        nodesCopy.forEach { node in
            node.vertices = node.vertices.map({ vertex in
                let destinationId = vertex.destination.id
                guard let newDestinationPos = nodesId[destinationId] else { return vertex }
                let newDestinationNode = nodesCopy[newDestinationPos]
                
                return Vertex(value: vertex.value, destination: newDestinationNode)
            })
        }
        
        return Graph(nodes: nodesCopy)
    }
    
    mutating func removeUnlinkedNodes() {
        guard let first = getFirst() else { return }
        markLinkedNodes(first)
        nodes = nodes.filter { node in
            node.mark
        }
        nodes.forEach { node in
            node.mark = false
        }
    }
    
    private func markLinkedNodes(_ node: Node<V, N>) {
        if node.mark {
            return
        }
        
        node.mark = true
        
        node.vertices.forEach { vertex in
            markLinkedNodes(vertex.destination)
        }
    }
    
    mutating func addNode(vertexValue: V, nodeValue: N? = nil) {
        let newNode = Node<V, N>(value: nodeValue)
        getLast()?.addVertex(value: vertexValue, destination: newNode)
        nodes.append(newNode)
    }
    
    func addLoop(vertexValue: V) {
        guard let node = getFirst() else { return }
        
        getLast()?.addVertex(value: vertexValue, destination: node)
    }
    
    func addLoopAtLast(vertexValue: V) {
        guard let node = getLast() else { return }
        
        getLast()?.addVertex(value: vertexValue, destination: node)
    }
    
    func addSkip(vertexValue: V) {
        guard let node = getLast() else { return }
        
        getFirst()?.addVertex(value: vertexValue, destination: node)
    }
    
    mutating func joinGraphAtEnd(vertexValue: V, graph: Graph<V, N>) {
        guard let node = graph.getFirst() else { return }
        
        getLast()?.addVertex(value: vertexValue, destination: node)
        
        nodes.append(contentsOf: graph.nodes)
    }
    
    mutating func joinGraphsInParallel(vertexValue: V, graphs: [Graph<V, N>], lastNodeValue: N) {
        
        guard let firstNode: Node<V, N> = getLast() else { return }
        let lastNode: Node<V, N> = .init(value: lastNodeValue)
        
        graphs.forEach { graph in
            guard let first = graph.getFirst() else { return }
            guard let last = graph.getLast() else { return }
            
            firstNode.addVertex(value: vertexValue, destination: first)
            last.addVertex(value: vertexValue, destination: lastNode)
            nodes.append(contentsOf: graph.nodes)
        }
        nodes.append(lastNode)
        
    }
    
    func toArrayString() -> [String] {
        nodes.map { node in
            guard let nodeValue = node.value else { return "" }
            let verticesString: [String] = node.vertices.map { vertex in
                guard let vertexValue = vertex.value, let destinationValue = vertex.destination.value else { return "" }
                return "-\(vertexValue)->\(destinationValue)"
            }
            return "\(nodeValue): \(verticesString.joined(separator: ", "))"
        }
    }
    
    func getFirst() -> Node<V, N>? {
        return nodes.first
    }
    
    func getLast() -> Node<V, N>? {
        return nodes.last
    }
    
}

class Node<V, N> {
    let id = UUID()
    let value: N?
    var mark: Bool = false
    var vertices: [Vertex<V, N>]
    var final: Bool = false
    
    init(value: N? = nil, vertices: [Vertex<V, N>] = []) {
        self.value = value
        self.vertices = vertices
    }
    
    func addVertex(value: V, destination: Node<V, N>) {
        vertices.append(.init(value: value, destination: destination))
    }
}

struct Vertex<V, N> {
    let value: V?
    let destination: Node<V, N>
}
