//
//  StatusItemUpdateHandler.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 7/11/19.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation

class StatusItemUpdateHandler: EventPoolUpdateObserver {
    
    var delegate: StatusItemController!
    var timer: Timer!
    let countdownStringGenerator = CountdownStringGenerator()
    
    init(delegate: StatusItemController) {
        self.delegate = delegate
        HLLEventSource.shared.addEventPoolObserver(self)
        
    }
    
    func eventPoolUpdated() {
        timer = Timer(timeInterval: 0.5, target: self, selector: #selector(updateStatusItem), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    @objc func updateStatusItem() {
        
        DispatchQueue.global(qos: .userInteractive).async {
        
        if SelectedEventManager.shared.launchID != nil {
            return
        }
            
        let event = HLLEventSource.shared.getPrimaryEvent(excludeAllDay: !HLLDefaults.general.showAllDayInStatusItem)
            
        let string = self.countdownStringGenerator.generateStatusItemString(event: event, mode: HLLDefaults.statusItem.mode)
        
        var selected = false
        if event != nil, event == SelectedEventManager.shared.selectedEvent {
            selected = true
        }
        
            self.delegate.updateStatusItem(with: string, selected: selected)
            
        }
        
    }
    
}
