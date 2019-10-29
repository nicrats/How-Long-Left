//
//  ProPurchaseHandler.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 7/8/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class ProPurchaseHandler: NSObject, NSWindowDelegate {
    
    static var shared = ProPurchaseHandler()
    
    var storyboard = NSStoryboard()
    var windowController: NSWindowController?
    
    func presentPromptIfNeeded() {
        
        if IAPHandler.proPriceString != nil, HLLDefaults.appData.proUser == false, HLLDefaults.defaults.bool(forKey: "shownPP") == false {
            
            prompt()
            
        }
        
        
        
    }
    
    func prompt() {
    
        DispatchQueue.main.async {
    
    self.storyboard = NSStoryboard(name: "PurchasePro", bundle: nil)
    self.windowController = self.storyboard.instantiateController(withIdentifier: "PurchasePro") as? NSWindowController
    
    self.windowController!.window!.delegate = self
    self.windowController!.showWindow(self)
            
        }
    
    
    
    }
    
}
