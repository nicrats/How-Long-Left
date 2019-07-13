//
//  NSMenuItemMaker.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 12/7/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class NSMenuHelper {
    
    func makeItem(title: String, submenu: NSMenu? = nil, state: NSControl.StateValue = NSControl.StateValue.off, action: Selector? = nil) -> NSMenuItem {
        
        let item = NSMenuItem()
        item.title = title
        item.submenu = submenu
        item.state = state
        item.action = action
        return item
        
    }
    
    func makeMenu(items: [NSMenuItem]) -> NSMenu {
        
        let menu = NSMenu()
        for item in items { menu.addItem(item) }
        return menu
    }
    
    
}



