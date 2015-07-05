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
    
    var displayValue: Double {
        get {
            if display.text! == "π" {
                return M_PI
            } else {
                return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
            }
        }
        set {
            display.text = "\(newValue)"
            history.text = brain.getHistory()
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
        if let result = brain.pushOperand(displayValue) {
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
                history.text = history.text! + "= " + result.description
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

