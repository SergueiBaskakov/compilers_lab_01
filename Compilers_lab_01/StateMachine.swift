//
//  StateMachine.swift
//  Compilers_lab_01
//
//  Created by Serguei Diaz on 26.02.2024.
//

import Foundation

struct StateMachine {
    var NFA: Graph<String, String>? = nil
    var FA: Graph<String, String>? = nil
    let regex: String
    
    mutating func generateNFA() -> Graph<String, String>? {
        if NFA == nil {
            NFA = regexToNFA(regex)
        }
        return NFA
    }
    
    mutating func generateFA() -> Graph<String, String>? {
        if NFA == nil {
            NFA = regexToNFA(regex)
        }
        
        if FA == nil {
            FA = NFAToFA(NFA)
        }
        
        return FA
    }
    
    func validateInputWithNFA(_ regex: String) -> Bool {
        guard let node = NFA?.nodes.first else { return false }
        return validateInput(regex, node: node)
    }
    
    func validateInputWithFA(_ regex: String) -> Bool {
        guard let node = FA?.nodes.first else { return false }
        return validateInput(regex, node: node)
    }
    
    private func NFAToFA(_ nfa: Graph<String, String>?) -> Graph<String, String>? {
        guard var graph = nfa?.copy() else { return nil }
        
        var foundEpsilone: Bool = true
        
        while foundEpsilone {
            foundEpsilone = false
            graph.nodes.forEach({ node in
                var newVertices: [Vertex<String, String>] = []
                node.vertices.forEach { vertex in
                    if vertex.value == "ε" {
                        if vertex.destination.id == graph.getLast()?.id || vertex.destination.final {
                            node.final = true
                        }
                        foundEpsilone = true
                        newVertices.append(contentsOf: vertex.destination.vertices)
                    }
                    else {
                        newVertices.append(vertex)
                    }
                }
                node.vertices = newVertices
            })
        }
        
        graph.removeUnlinkedNodes()

        return graph
    }
    
    private func validateInput(_ regex: String, node: Node<String, String>) -> Bool {
        var char: String = ""
        if regex.isEmpty {
            if node.vertices.isEmpty || node.final  {
                return true
            }
        }
        else {
            char = "\(regex.first ?? .init(""))"
        }
        
        return node.vertices.reduce(false) { partialResult, vertex in
            let isEpsilonVertex: Bool = (vertex.value == "ε" ? validateInput(regex, node: vertex.destination) : false)
            let isValidVertex: Bool = (vertex.value == char ? validateInput("\(regex.dropFirst())", node: vertex.destination) : false)
            return partialResult || isValidVertex || isEpsilonVertex
        }
    }
    
    private func regexToNFA(_ regex: String) -> Graph<String, String> {
        var stack: [Graph<String, String>] = []
        
        var currentGraph: Graph<String, String> = .init(initialNodeValue: "S0")
        
        var count: Int = 0
                
        for c in regex {
            
            if c == "|" {
                let newGraph: Graph<String, String> = .init(initialNodeValue: "|")
                stack.append(currentGraph)
                currentGraph = newGraph
            }
            else if c == "*" {
                count = count + 1
                
                var newGraph: Graph<String, String> = .init(initialNodeValue: "S\(count)")
                
                currentGraph.addLoop(vertexValue: "ε")
                
                count = count + 1
                
                newGraph.joinGraphAtEnd(vertexValue: "ε", graph: currentGraph)
                newGraph.addNode(vertexValue: "ε", nodeValue: "S\(count)")
                newGraph.addSkip(vertexValue: "ε")
                
                currentGraph = newGraph
            }
            else if c == "(" {
                count = count + 1
                let newGraph: Graph<String, String> = .init(initialNodeValue: "S\(count)")
                count = count + 1
                let secondNewGraph: Graph<String, String> = .init(initialNodeValue: "S\(count)")
                
                if var unstackedGraph = stack.popLast() {
    
                    if unstackedGraph.nodes.count == 1 && unstackedGraph.nodes.first?.value == "|" {
                        if let leftGraph = stack.popLast() {
                            count = count + 1
                            var startPointGraph: Graph<String, String> = .init(initialNodeValue: "S\(count)")
                            count = count + 1
                            startPointGraph.joinGraphsInParallel(vertexValue: "ε", graphs: [leftGraph, currentGraph], lastNodeValue: "S\(count)")
                            
                            if var lastUnstackGraph = stack.popLast() {
                                lastUnstackGraph.joinGraphAtEnd(vertexValue: "ε", graph: startPointGraph)
                                stack.append(lastUnstackGraph)
                            }
                            else {
                                stack.append(startPointGraph)
                            }
                        }
                    }
                    else {
                        if currentGraph.nodes.count == 1 && currentGraph.nodes.first?.value == "|" {
                            stack.append(unstackedGraph)
                            stack.append(currentGraph)
                        }
                        else {
                            unstackedGraph.joinGraphAtEnd(vertexValue: "ε", graph: currentGraph)
                            stack.append(unstackedGraph)
                        }
                        
                    }
                    
                }
                
                if stack.isEmpty {
                    stack.append(currentGraph)
                    currentGraph = newGraph
                }
                else {
                    stack.append(newGraph)
                    currentGraph = secondNewGraph
                }
                
                //stack.append(newGraph)
                //currentGraph = secondNewGraph

            }
            else if c == ")" {
                if var unstackedGraph = stack.popLast() {
                    
                    if unstackedGraph.nodes.count == 1 && unstackedGraph.nodes.first?.value == "|" {
                        if let leftGraph = stack.popLast() {
                            count = count + 1
                            var startPointGraph: Graph<String, String> = .init(initialNodeValue: "S\(count)")
                            count = count + 1
                            startPointGraph.joinGraphsInParallel(vertexValue: "ε", graphs: [leftGraph, currentGraph], lastNodeValue: "S\(count)")
                            
                            
                            if var lastUnstackGraph = stack.popLast() {
                                lastUnstackGraph.joinGraphAtEnd(vertexValue: "ε", graph: startPointGraph)
                                currentGraph = lastUnstackGraph
                            }
                            else {
                                currentGraph = startPointGraph
                            }
                        }
                    }
                    else {
                        unstackedGraph.joinGraphAtEnd(vertexValue: "ε", graph: currentGraph)
                        currentGraph = unstackedGraph
                    }
                }
                
            }
            else {
                count = count + 1
                var newGraph: Graph<String, String> = .init(initialNodeValue: "S\(count)")
                count = count + 1
                newGraph.addNode(vertexValue: "\(c)", nodeValue: "S\(count)")
                
                if var unstackedGraph = stack.popLast() {
                    if unstackedGraph.nodes.count == 1 && unstackedGraph.nodes.first?.value == "|" {
                        if let leftGraph = stack.popLast() {
                            count = count + 1
                            var startPointGraph: Graph<String, String> = .init(initialNodeValue: "S\(count)")
                            count = count + 1
                            startPointGraph.joinGraphsInParallel(vertexValue: "ε", graphs: [leftGraph, currentGraph], lastNodeValue: "S\(count)")
                            
                            if var lastUnstackGraph = stack.popLast() {
                                lastUnstackGraph.joinGraphAtEnd(vertexValue: "ε", graph: startPointGraph)
                                stack.append(lastUnstackGraph)
                            }
                            else {
                                stack.append(startPointGraph)
                            }
                        }
                    }
                    else {
                        if currentGraph.nodes.count == 1 && currentGraph.nodes.first?.value == "|" {
                            stack.append(unstackedGraph)
                            stack.append(currentGraph)
                        }
                        else {
                            unstackedGraph.joinGraphAtEnd(vertexValue: "ε", graph: currentGraph)
                            stack.append(unstackedGraph)
                        }
                        
                    }
                }
                else {
                    stack.append(currentGraph)
                }
                currentGraph = newGraph
            }
        }
        
        if var unstackedGraph = stack.popLast() {
            if unstackedGraph.nodes.count == 1 && unstackedGraph.nodes.first?.value == "|" {
                if let leftGraph = stack.popLast() {
                    count = count + 1
                    var startPointGraph: Graph<String, String> = .init(initialNodeValue: "S\(count)")
                    count = count + 1
                    startPointGraph.joinGraphsInParallel(vertexValue: "ε", graphs: [leftGraph, currentGraph], lastNodeValue: "S\(count)")
                    
                    if var lastUnstackGraph = stack.popLast() {
                        lastUnstackGraph.joinGraphAtEnd(vertexValue: "ε", graph: startPointGraph)
                        return lastUnstackGraph
                    }
                    else {
                        return startPointGraph
                    }
                }
                else {
                    return .init(initialNodeValue: "Error")
                }
            }
            else {
                unstackedGraph.joinGraphAtEnd(vertexValue: "ε", graph: currentGraph)
                return unstackedGraph
            }
            
        }
        else {
            return currentGraph
        }
    }
    
}

//"ε"
//(1*01*01*01*)|(1*01*0(01*01*0)*01*)|(1*)
//(1*)|(1*0(0)*0)|(1*)
