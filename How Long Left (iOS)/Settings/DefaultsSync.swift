//
//  DefaultsSync.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 21/3/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation


class DefaultsSync {
    
    static var shared = DefaultsSync()
    
    func syncDefaultsToWatch() {
        
        DispatchQueue.main.async {
            
            
            WatchSessionManager.sharedManager.startSession()
            WatchSessionManager.sharedManager.updateContext(userInfo: ["MagdaleneManualSettingChanged" : HLLDefaults.magdalene.manuallyDisabled])
            
            
            let ids = EventDataSource().getCalendarIDS()
            
            WatchSessionManager.sharedManager.updateContext(userInfo: ["SelectedCalendars" : ids])
            
            
            
            
        }
        
        
    }
    
    
}
