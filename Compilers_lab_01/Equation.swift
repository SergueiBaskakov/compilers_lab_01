//
//  Equation.swift
//  Compilers_lab_01
//
//  Created by Serguei Diaz on 25.02.2024.
//

import Foundation

struct Equation {
    private let equation: [(left: String, right: [String])]
    private var solution: [(left: String, right: [String])] = []
    
    init(grammar: [String]) {
        self.equation = grammar.map { row in
            let arrayRow: [String] = row.components(separatedBy: "->")
            let left: String = arrayRow.first ?? ""
            var right: [String] = arrayRow.last?.components(separatedBy: "|") ?? []
            
            right.sort { a, b in
                a.contains(left)
            }
            
            return (left, right)
        }
    }
    
    func returnFormattedEquation() -> [String] {
        formatEquation(equation)
    }
    
    func returnRegexFormattedSolution() -> [String] {
        solution.map { tuple in
            tuple.right
                .reduce("") { partialResult, value in
                    if partialResult.isEmpty {
                        return value.replacingOccurrences(of: " + ", with: "|")
                    }
                    else {
                        return "(\(partialResult))|(\(value.replacingOccurrences(of: " + ", with: "|")))"
                    }
                }
        }
    }
    
    func formatEquation(_ equation: [(left: String, right: [String])]) -> [String] {
        equation.map { tuple in
            "\(tuple.left) = \(tuple.right.joined(separator: " + "))"
        }
    }
    
    mutating func solve(regexFormat: Bool = false) -> [String] {
        if !solution.isEmpty { return regexFormat ? returnRegexFormattedSolution() : formatEquation(solution) }
        var tempSolution: Dictionary<String, [String]> = .init()
        var variables: [String] = []
        
        //Steps until 5.5
        equation.dropLast().forEach { tuple in
            let newTuple = removeSelfCall(tuple)
            
            variables.append(newTuple.left)
            tempSolution[newTuple.left] = newTuple.right
        }
        guard let last = equation.last else { return [] }
        
        variables.append(last.left)
        tempSolution[last.left] = last.right
        
        //Steps 5.5 and 6
        for key in variables.reversed() {
            guard let tupleValue = tempSolution[key] else { return [] }
            var haveToReplace: Bool = true
            var newRight: [String] = tupleValue
            
            while haveToReplace {
                haveToReplace = false
                var tempRight: [String] = []
                
                for value in newRight {
                    var foundedVariable: String? = nil
                    variables.forEach { variable in
                        if value.contains(variable) && variable != key {
                            haveToReplace = true
                            foundedVariable = variable
                            return
                        }
                    }
                    
                    if let foundVar = foundedVariable, let foundVarValue = tempSolution[foundVar] {
                        if foundVarValue.count > 1 {
                            tempRight.append("\(value.replacingOccurrences(of: foundedVariable ?? "", with: "(\(foundVarValue.joined(separator: " + ")))"))")
                        }
                        else {
                            if (foundVarValue.first?.count ?? 0) > 1 {
                                tempRight.append("\(value.replacingOccurrences(of: foundedVariable ?? "", with: "(\(foundVarValue.joined(separator: " + ")))"))")
                            }
                            else {
                                tempRight.append("\(value.replacingOccurrences(of: foundedVariable ?? "", with: "\(foundVarValue.joined(separator: " + "))"))")
                            }
                        }
                    }
                    else {
                        tempRight.append(value)
                    }
                }
                newRight = tempRight
            }
            tempSolution[key] = removeSelfCall((key, newRight)).right
            solution.append(removeSelfCall((key, newRight)))
        }
        solution.reverse()
        return regexFormat ? returnRegexFormattedSolution() : formatEquation(solution)
    }
    
    private func removeSelfCall(_ tuple: (left: String, right: [String])) -> (left: String, right: [String]) {
        let alpha = tuple.right.filter { value in
            value.contains(tuple.left)
        }.map { value in
            value.replacing(tuple.left, with: "")
        }
        
        if alpha.isEmpty { return tuple }
        
        let beta = tuple.right.filter { value in
            !value.contains(tuple.left)
        }
        
        var newRight: [String] = []
        if beta.isEmpty {
            var aVal: String = alpha.first ?? ""
            if alpha.count > 1 {
                aVal = "(\(alpha.joined(separator: " + ")))"
            }
            else if aVal.count > 1 {
                aVal = "(\(aVal))"
            }
            newRight.append("\(aVal)*")
            
        }
        else {
            beta.forEach { betaValue in
                var aVal: String = alpha.first ?? ""
                if alpha.count > 1 {
                    aVal = "(\(alpha.joined(separator: " + ")))"
                }
                else if aVal.count > 1 {
                    aVal = "(\(aVal))"
                }
                if betaValue == "ε" {
                    newRight.append("\(aVal)*")
                }
                else {
                    newRight.append("\(aVal)*\(betaValue)")
                }
            }
        }
        
        return (tuple.left, newRight)
    }
}
