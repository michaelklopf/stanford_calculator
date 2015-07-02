//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Michael on 02.07.15.
//  Copyright © 2015 Michael Klopf. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    enum Op {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
    }
    
    var opStack = [Op]()
    
    var knownOps = [String: Op]()//Dictionary<String, Op>()
    
    init() {
        knownOps["x"] = Op.BinaryOperation("x", { $0 * $1 })
        knownOps["÷"] = Op.BinaryOperation("÷", { $1 / $0 })
        knownOps["+"] = Op.BinaryOperation("+", { $0 + $1 })
        knownOps["-"] = Op.BinaryOperation("-", { $1 - $0 })
        
        knownOps["√"] = Op.UnaryOperation("√", { sqrt($0) })
    }
    
    let brain = CalculatorBrain()
    
    func pushOperand(operand: Double) {
        opStack.append(Op.Operand(operand))
    }
    
    func performOperation(symbol: String) {
        
    }
}