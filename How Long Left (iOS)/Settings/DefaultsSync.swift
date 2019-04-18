//
//  DefaultsSync.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 21/3/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import WatchConnectivity


class DefaultsSync {
    
    static var shared = DefaultsSync()
    
    func syncDefaultsToWatch() {
            
            WatchSessionManager.sharedManager.startSession()
            
            if let session = WatchSessionManager.sharedManager.validSession {
            
            for file in session.outstandingUserInfoTransfers {
                
                
                
                file.cancel()
                
                }
                
                for item in session.outstandingFileTransfers {
                    
                    item.cancel()
                    
                    
                }
                
        }
            
        let transferDict = ["MagdaleneManualSettingChanged":HLLDefaults.magdalene.manuallyDisabled, "SelectedCalendars":HLLDefaults.calendar.enabledCalendars, "ComplicationPurchased":IAPHandler.shared.hasPurchasedComplication()] as [String : Any]
            
            
            WatchSessionManager.sharedManager.sendMessage(info: transferDict)
        
        
    }
    
    
}

// let ids = EventDataSource().getCalendarIDS()

// The above line of code, is so dumb that I am keeping it here commented out just to remind me of my stupidity. I spent so long trying to figure out what the issue with WatchConnectivity was that was causing enabledCalendars not to sync to the Watch properly. Turns out the method I was calling always returns all EventKit calendar IDs, not just the enabled ones. Smh.
