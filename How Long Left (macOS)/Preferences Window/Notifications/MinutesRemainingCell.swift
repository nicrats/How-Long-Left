//
//  MinutesRemainingCell.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 3/12/19.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class MinutesRemainingCell: NSTableCellView, NSTextFieldDelegate {
    
    var delegate: NotificationTriggerTableHandler!
    
    override func awakeFromNib() {
        self.textField?.isEditable = true
        self.textField?.delegate = self
    }
    
    func setup(with string: String, delegate: NotificationTriggerTableHandler) {
        self.delegate = delegate
        print("Set up cell")
        
        self.textField?.stringValue = string
    }
    
    func select() {
        
        if let field = self.textField {
            
            field.becomeFirstResponder()
            
        }
        
    }
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        
        if let text = self.textField?.stringValue {
            
            print("Ending editing with \(text)")
            
        }
        
        
        return true
        
    }
    
    
}
