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
    
    @IBOutlet weak var calendarItemTitle: UILabel!

    func setCalendarItem(Calendar: EKCalendar) {
        
        calendarItemTitle.text = Calendar.title
        
    }
    
}
