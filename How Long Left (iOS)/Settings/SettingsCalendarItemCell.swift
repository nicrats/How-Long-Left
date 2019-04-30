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
        
        self.selectedBackgroundView = AppTheme.current.selectedCellView
        self.backgroundColor = AppTheme.current.tableCellBackgroundColor
        self.calendarItemTitle.textColor = AppTheme.current.textColor
        
        if let col = Calendar.cgColor {
            
            let uiCOL = UIColor(cgColor: col)
            calColBox.backgroundColor = uiCOL
            
          /*  let lighter = uiCOL.lighter(by: 13)!.cgColor
            let darker = uiCOL.darker(by: 8)!.cgColor
            
            
            
            
            gradient.frame = calColBox.bounds
            gradient.colors = [lighter, col, darker]
            
            calColBox.layer.insertSublayer(gradient, at: 0) */
        
        }
            
        calendarItemTitle.text = Calendar.title
        //calColBox.backgroundColor = UIColor(cgColor: Calendar.cgColor)
        
    }
    
}
