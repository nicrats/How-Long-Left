//
//  SettingsCalendarItemCell.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 24/1/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import UIKit
import EventKit

class SettingsCalendarItemCell: UITableViewCell {
    
    let gradient = CAGradientLayer()
    
    @IBOutlet weak var calColBox: UIView!
    @IBOutlet weak var calendarItemTitle: UILabel!

    func setCalendarItem(Calendar: EKCalendar) {
        
        
        if let col = Calendar.cgColor {
            
            #if targetEnvironment(macCatalyst)
            let uiCOL = UIColor(cgColor: col).catalystAdjusted()
            #else
            let uiCOL = UIColor(cgColor: col)
            #endif
            
            
            
            calColBox.backgroundColor = uiCOL
        
        }
            
        calendarItemTitle.text = Calendar.title
        
    }
    
}
