//
//  SwitchCell.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 19/10/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import UIKit

class SwitchCell: UITableViewCell {
    
    @IBOutlet weak private var cellLabel: UILabel!
    @IBOutlet weak private var valueSwitch: UISwitch!
    
    var cellIdentifier = ""
    var delegate: SwitchCellDelegate?
    
    var label: String? {
        
        get {
           
            return cellLabel.text
            
        }
        
        set (to) {
            
           cellLabel.text = to
            
        }
        
    }
    
    var setAction: ((Bool) -> Void)?
    var getAction: (() -> Bool)? {
        
        didSet {
            
            if let result = self.getAction?() {
                valueSwitch.setOn(result, animated: false)
            }
            
        }
        
    }
    
    var currentState: Bool {
        
        get {
            
            return valueSwitch.isOn
            
        }
        
    }
    
    @IBAction private func switchToggled(_ sender: UISwitch) {
        setAction?(sender.isOn)
        delegate?.switchCellWasToggled(self)
    }
    
}

protocol SwitchCellDelegate {
    
    func switchCellWasToggled(_ sender: SwitchCell)
    
}
