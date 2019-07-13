//
//  EventMenuItem.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 12/7/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class EventMenuItem {
    
    internal init(item: NSMenuItem, event: HLLEvent?, type: EventMenuItemType) {
        self.item = item
        self.event = event
        self.type = type
    }
    
    var item: NSMenuItem
    var event: HLLEvent?
    var type: EventMenuItemType
    
    
    
}

enum EventMenuItemType {
    
    case current
    case upcoming
    case noCurrent
    
}
