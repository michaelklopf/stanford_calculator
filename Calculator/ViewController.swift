//
//  ViewController.swift
//  Calculator
//
//  Created by Michael on 01.07.15.
//  Copyright © 2015 Michael Klopf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    
    var operandStack = Array<Double>()
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        operandStack.append(displayValue)
        print("operandStack is \(operandStack)")
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        switch operation {
        case "x":
            performOperation { $0 * $1 }
        case "÷":
            performOperation { $1 / $0 }
        case "+":
            performOperation { $0 + $1 }
        case "-":
            performOperation { $1 - $0 }
        case "√":
            performOperation { sqrt($0)}
        default: break
        }
    }
    
    func performOperation(operation: (Double, Double) -> Double) { // ... is a function type
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    private func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

