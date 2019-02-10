//
//  CountdownUIOutputHandler.swift
//  How Long Left (watchOS) Extension
//
//  Created by Ryan Kontos on 15/10/18.
//  Copyright © 2018 Ryan Kontos. All rights reserved.
//

import Foundation

class CountdownUIOutputHandler {
    
    let UIDelegate: 

    init(Delegate: CountdownUIController) {
        UIDelegate = Delegate
    }
    
    let cal = CalendarData()
    
    func requestUpdate() {
        
        UIDelegate.updateCountdownUI(Event: cal.getCurrentEvent())
        
    }
    
}
