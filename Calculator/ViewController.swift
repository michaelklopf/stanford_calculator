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
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    
    var userTypesAFloat = false
    
    let brain = CalculatorBrain()
    
    var displayValue: Double? {
        get {
            if display.text! == "π" {
                return M_PI
            }
            
            if let displayText = display.text {
                if let numberValue = NSNumberFormatter().numberFromString(displayText) {
                    return numberValue.doubleValue
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
        set {
            if let displayValue = newValue {
                display.text = "\(displayValue)"
            } else {
                display.text = ""
            }
            history.text = brain.description
            userIsInTheMiddleOfTypingANumber = false
            userTypesAFloat = false
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
    
    @IBAction func appendDot(sender: UIButton) {
        let dot = sender.currentTitle!
        if !userTypesAFloat {
            display.text = display.text! + dot
            userTypesAFloat = true
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        userTypesAFloat = false
        if let result = brain.pushOperand(displayValue!) {
            displayValue = result
        } else {
            displayValue = 0
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
                let historyResult = String(format: "%.2f", result)
                history.text = history.text! + "= " + historyResult
            } else {
                displayValue = 0
            }
        }
    }
    
    @IBAction func clear(sender: UIButton) {
        brain.reset()
        displayValue = 0
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

