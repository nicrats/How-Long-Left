//
//  EventVisibilityButtonsManager.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 3/9/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class EventVisibilityButtonsManager {

    static var shared = EventVisibilityButtonsManager()

    @objc func visibilityButtonClicked(sender: NSMenuItem) {
        
        if let item = VisibilityString(rawValue: sender.title) {
            
            EventVisibiltyActionHandler.shared.disableVisbiltyFor(item)
            
        }
        
        
     
        
    }
    
    

}
