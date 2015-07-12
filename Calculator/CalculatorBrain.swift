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
        case Constant(String, Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Variable(String)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return String(format: "%.2f", operand) //return "\(operand)"
                case .Constant(let symbol, _):
                    return symbol
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
    
    var variableValues = [String: Double]()

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
        learnOp(Op.Constant("π", M_PI))
    }
    
    private func describe(ops: [Op]) -> (description: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                let operandDesc = operand.description ?? "?"
                return (operandDesc, remainingOps)
                
            case .Constant(let symbol, _):
                return (symbol, remainingOps)

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
                
                return ("(" + operand2 + ")" + symbol + "(" + operand1 + ")", operandDescription2.remainingOps)

            case .Variable(let symbol):
                return (symbol, remainingOps)
            }
        }
        return (nil, ops)
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList { // guaranteed to be a PropertyList
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                            newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]){
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Constant(_, let constantValue):
                return (constantValue, remainingOps)
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
