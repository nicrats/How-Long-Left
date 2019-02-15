//
//  NextOccurInterfaceController.swift
//  How Long Left (watchOS) Extension
//
//  Created by Ryan Kontos on 8/2/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import UIKit
import WatchKit

class NextOccurInterfaceController: WKInterfaceController {
    
    @IBOutlet var eventTitleLabel: WKInterfaceLabel!
    @IBOutlet var dayLabel: WKInterfaceLabel!
    @IBOutlet var relativeDateLabel: WKInterfaceLabel!
    
    var event: HLLEvent!
    var timer: Timer!
    var infoArray = [String()]
    var infoArrayLoopItem = 0
    
    override func awake(withContext context: Any?) {
        event = (context as! HLLEvent)
        
    eventTitleLabel.setText("Next \(event.title)")
      
            
            if let cal = EventDataSource.shared.calendarFromID(event.calendarID) {
            
            dayLabel.setTextColor(UIColor(cgColor: cal.cgColor))
                
            }
            
        
        
        let cal: Calendar = Calendar(identifier: .gregorian)
        let midnightToday: Date = cal.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let nextOccurDay: Date = cal.date(bySettingHour: 0, minute: 0, second: 0, of: event.startDate)!
        let NXOsec = nextOccurDay.timeIntervalSince(midnightToday)
        let NXOdays = NXOsec/60/60/24
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let formattedEnd = dateFormatter.string(from: event.startDate)
        
        var dayText = formattedEnd
        
        switch NXOdays {
        case 0:
            dayText = "Today"
        case 1:
            dayText = "Tomorrow"
        default:
            dayText = formattedEnd
        }
        
        dayLabel.setText(dayText)
        
        if Int(NXOdays) != 1 {
        infoArray.append("\(Int(NXOdays)) days from now.")
        
        }
        
        var eventInfoString: String
        
        if let period = event.magdalenePeriod {
            
            eventInfoString = "Period \(period)"
            
        } else {
            
            eventInfoString = event.startDate.formattedTime()
            
        }
        
        infoArray.append(eventInfoString)
        
        if let loc = event.location {
            
            infoArray.append(loc)
            
        }
        
        
        timer = Timer(fire: Date(), interval: 1, repeats: true, block: {_ in
            
            self.updateInfoLabel()
            
        })
        
        
        
    }
    
    func updateInfoLabel() {
        
        
        
    }
    

}
