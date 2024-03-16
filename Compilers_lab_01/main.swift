//
//  main.swift
//  Compilers_lab_01
//
//  Created by Serguei Diaz on 21.02.2024.
//

import Foundation

let rigthLinearGrammar: [String] = readLineUntilEmpty()
var equation: Equation = .init(grammar: rigthLinearGrammar)

print("Rigth Linear Grammar:")
printArrayOfStrings(rigthLinearGrammar)
print("")

print("Equations System:")
printArrayOfStrings(equation.returnFormattedEquation())
print("")

print("Solved Equations System:")
printArrayOfStrings(equation.solve())
print("")

var stateMachine: StateMachine = .init(regex: equation.solve(regexFormat: true).first ?? "") //equation.solve(regexFormat: true).first ?? ""

print("State Machine Regex Input:")
print(equation.solve(regexFormat: true).first ?? "")
print("")

print("NFA:")
printArrayOfStrings(stateMachine.generateNFA()?.toArrayString() ?? [])
print("")

print("DFA:")
printArrayOfStrings(stateMachine.generateFA()?.toArrayString() ?? [])
print("")

print("Insert Regex:")
let regex = readLine()
print(stateMachine.validateInputWithFA(regex ?? "") ? "Valid" : "No Valid")
print("")

func readLineUntilEmpty() -> [String] {
    var lines: [String] = []
    
    while let line = readLine(), !line.isEmpty {
        lines.append(line)
    }
    
    return lines
}

func printArrayOfStrings(_ array: [String]) {
    array.forEach { element in
        print(element)
    }
}



/*
S->0A|1S|ε
A->0B|1A
B->0S|1B
 
S->aS|bS|B
B->abb
 
S->A|B|C
A->010A|ε
B->0|1
C->10|01
 
S->AS|ε
A->BBB
B->0|1
 
S->AS|ε
A->01|10
 */
