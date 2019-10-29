//
//  EventVisibiltyActionHandler.swift
//  How Long Left
//
//  Created by Ryan Kontos on 19/10/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class EventVisibiltyActionHandler {
    
    static var shared = EventVisibiltyActionHandler()
    
    func disableVisbiltyFor(_ visibiltyString: VisibilityString) {
        
        switch visibiltyString {
            
        case .exams:
            HLLDefaults.magdalene.showPrelims = false
        case .term:
            HLLDefaults.magdalene.doTerm = false
        case .holidays:
            HLLDefaults.magdalene.doTerm = false
        case .breaks:
            HLLDefaults.magdalene.showBreaks = false
        }
        
        HLLEventSource.shared.updateEventPool()
        
    }
    
    
}
