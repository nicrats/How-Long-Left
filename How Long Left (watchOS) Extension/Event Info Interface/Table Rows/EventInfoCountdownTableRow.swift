//
//  EventInfoCountdownTableRow.swift
//  How Long Left (watchOS) Extension
//
//  Created by Ryan Kontos on 28/10/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import WatchKit

class EventInfoCountdownTableRow: NSObject, EventRow {
    
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var countdownLabel: WKInterfaceLabel!
    
    var event: HLLEvent!
    var rowCompletionStatus: EventCompletionStatus!
    
    func setup(event: HLLEvent) {
        
        self.event = event
        self.rowCompletionStatus = event.completionStatus
        
        titleLabel.setText("\(event.title) \(event.countdownTypeString) in")
        
        /* if let colour = event.associatedCalendar?.cgColor {
        
            countdownLabel.setTextColor(UIColor(cgColor: colour))
            
        } */
        
    }
    
    func updateTimer(_ string: String) {
       
            if let label = self.countdownLabel {
                
            let monospacedFont = UIFont.monospacedDigitSystemFont(ofSize: 27, weight: UIFont.Weight.semibold)
            let monospacedString = NSAttributedString(string: string, attributes: [NSAttributedString.Key.font: monospacedFont])
            label.setAttributedText(monospacedString)
            
            
            
        }
            
        
        
    }
    
}

