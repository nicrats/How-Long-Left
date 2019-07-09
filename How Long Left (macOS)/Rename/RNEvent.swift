//
//  RNEvent.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 22/6/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class RNEvent {
    
    init(old: String, new: String) {
        
        oldName = old
        newName = new
        
    }
    
    var selected = true
    var oldName = ""
    var newName = ""
    
}