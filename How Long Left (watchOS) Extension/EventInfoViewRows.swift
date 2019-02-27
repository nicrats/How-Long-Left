//
//  EventInfoViewRows.swift
//  How Long Left (watchOS) Extension
//
//  Created by Ryan Kontos on 19/2/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import WatchKit

class CountdownRow: NSObject {
    
    @IBOutlet var countdownTypeLabel: WKInterfaceLabel!
    @IBOutlet var countdownLabel: WKInterfaceTimer!
    
}

class PercentRow: NSObject {
    
    var event: HLLEvent?
    var timer: Timer?
    var percentageCalc = PercentageCalculator()
    
    func start(event inputEvent: HLLEvent) {
        
        event = inputEvent
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(self.calcPercent), userInfo: nil, repeats: true)
        
    }
    
    @objc func calcPercent(){
        
        if let e = event {
       percentLabel.setText(percentageCalc.calculatePercentageDone(event: e))
        }
        
    }
    
    
    
    @IBOutlet var percentLabel: WKInterfaceLabel!
    
}

class LocationRow: NSObject {

    @IBOutlet var locationLabel: WKInterfaceLabel!
    
}

class DateRow: NSObject {
    
    @IBOutlet var dateInfoLabel: WKInterfaceLabel!
    
}

class TimeRow: NSObject {
    
    @IBOutlet var timeLabel: WKInterfaceLabel!
    
    
}

class DurationRow: NSObject {
    
    @IBOutlet var durationLabel: WKInterfaceLabel!
    
}

class PeriodRow: NSObject {
    
    @IBOutlet var periodLabel: WKInterfaceLabel!
    
    
}

class NextOccurRow: NSObject {

    
    @IBOutlet var mainLabel: WKInterfaceLabel!
    @IBOutlet var relativeDaysLabel: WKInterfaceLabel!
    @IBOutlet var infoLabel: WKInterfaceLabel!
    
    
}

enum InfoRowIdentifier: String {
    
    case TimerRow = "TimerRow"
    case PercentRow = "PercentRow"
    case LocationRow = "LocationRow"
    case DateRow = "DateRow"
    case TimesRow = "TimesRow"
    case PeriodRow = "PeriodRow"
    case DurationRow = "DurationRow"
    case NextOccurRow = "NextOccurRow"
    
}

