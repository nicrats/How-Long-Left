//
//  PurchaseProViewController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 7/8/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class PurchaseProViewController: NSViewController, IAPListener {
    
    @IBOutlet weak var purchaseButton: NSButton!
    
    override func viewDidLoad() {
        if let price = IAPHandler.proPriceString {
            
            purchaseButton.title = "Purchase for \(price)"
            
            
        }
    }
    
    @IBAction func purchaseClicked(_ sender: NSButton) {
        
        IAPHandler.delegate = self
        IAPHandler.shared.purchaseMyProduct(index: 0)
        
    }
    
    func purchaseResult(was result: IAPPurchaseState) {
        
    }
    
    
}
