//
//  MilestoneSettingsCell.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 7/2/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import UIKit


class MilestoneSettingsCell: UITableViewCell {
    
    var milestone: Int?
    
    @IBOutlet weak var milestoneItemLabel: UILabel!
    
    
    func setupCell(milestoneSeconds: Int) {
        
        milestone = milestoneSeconds
        
        if milestoneSeconds == 0 {
            
            milestoneItemLabel.text = "Finishes"
            
        } else {
            
            let milestoneMinutes = milestoneSeconds/60
            
            var minText = "minutes"
            if milestoneMinutes == 1 {
                minText = "minute"
            }
            
            milestoneItemLabel.text = "Has \(milestoneMinutes) \(minText) left"
            
            
        }
        
        
        
        
    }
    
}
