//
//  ActionableNSMenuItem.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 23/1/20.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Cocoa

class ActionableNSMenuItem: NSMenuItem {
    
    var closure: (() -> Void)? {
        
        didSet {
            
            self.target = MenuItemClosureHandler.shared
            self.action = #selector(MenuItemClosureHandler.shared.runClosureFor(sender:))
            
        }
        
    }
    
    
    
}
