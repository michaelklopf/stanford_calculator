//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Michael on 02.07.15.
//  Copyright © 2015 Michael Klopf. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Variable(String)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return String(format: "%.2f", operand) //return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .Variable(let symbol):
                    return symbol
                }
            }
        }
    }
    
    var description: String {
        get {
            if let description = describe(opStack).description {
                return description
            } else {
                return ""
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String: Op]()//Dictionary<String, Op>()
    
    private var variableValues = [String: Double]()

    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("x", *))
        learnOp(Op.BinaryOperation("÷", { $1 / $0 }))
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("-", { $1 - $0 }))
        
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("√", sqrt))
    }
    
    private func describe(ops: [Op]) -> (description: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                let operandDesc = operand.description ?? "?"
                return (operandDesc, remainingOps)

            case .UnaryOperation(let symbol, _):
                let operandDescription = describe(remainingOps)
                if let opDesc = operandDescription.description {
                    return (symbol + "(" + opDesc + ")", remainingOps)
                }

            case .BinaryOperation(let symbol, _):
                let operandDescription1 = describe(remainingOps)
                let operand1 = operandDescription1.description ?? "?"
                
                let operandDescription2 = describe(operandDescription1.remainingOps)
                let operand2 = operandDescription2.description ?? "?"
                
                return ("(" + operand2 + symbol + operand1 + ")", operandDescription2.remainingOps)

            case .Variable(let symbol):
                return (symbol, remainingOps)
            }
        }
        return (nil, ops)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]){
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .Variable(let symbol):
                if let variableValue = variableValues[symbol] {
                    return (variableValue, remainingOps)
                } else {
                    return (nil, remainingOps)
                }
            }
        }
        return (nil, ops)
    }
    
    func getHistory() -> String {
        if opStack.isEmpty {
            return "0"
        } else {
            var historyText = ""
            for op in opStack {
                historyText = historyText + op.description + ", "
            }
            //let range = advance(historyText.endIndex, -2)..<historyText.endIndex
            return historyText//.removeRange(range)
        }
    }
    
    func reset() {
        opStack = [Op]()
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
}