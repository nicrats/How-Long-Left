//
//  UpcomingEventRowController.swift
//  How Long Left (watchOS) Extension
//
//  Created by Ryan Kontos on 22/9/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import WatchKit

class UpcomingEventRowController: NSObject, EventRow {
    
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var infoLabel: WKInterfaceLabel!
    
    var event: HLLEvent!
    var rowCompletionStatus: EventCompletionStatus!
    
    func setup(event: HLLEvent) {
        
        self.event = event
        self.rowCompletionStatus = event.completionStatus
        
        titleLabel.setText(event.title)
        infoLabel.setText(event.compactInfoText)
        
        titleLabel.setTextColor(event.uiColor)
     
    }
    
    func updateTimer(_ string: String) {
    }
    
}
