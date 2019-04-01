//
//  AppFunctions.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 1/4/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
#if canImport(Intents)
import Intents
import IntentsUI
#endif

class AppFunctions {
    
    static let shared = AppFunctions()
    
    private let notoScheduler = MilestoneNotificationScheduler()
    
    private let sync = DefaultsSync()
    
    init() {
        
        let eventDatasource = EventDataSource()
        eventDatasource.getCalendarAccess()
        
        run()
    }
    
    func run() {
        
        donateInteraction()
        
       
        SchoolAnalyser.shared.analyseCalendar()
        
        WatchSessionManager.sharedManager.startSession()
        
        self.sync.syncDefaultsToWatch()
        VoiceShortcutStatusChecker.shared.check()
        
        self.notoScheduler.getAccess()
        self.notoScheduler.scheduleNotificationsForUpcomingEvents()
        
        
        
        
    }
    
   private func donateInteraction() {
        if #available(iOS 12.0, *) {
            let intent = HowLongLeftIntent()
            
            intent.suggestedInvocationPhrase = "How long left"
            
            let interaction = INInteraction(intent: intent, response: nil)
            
            interaction.donate { (error) in
                if error != nil {
                    if let error = error as NSError? {
                        print("Failed to donate because \(error)")
                    } else {
                        print("Successfully donated")
                    }
                }
            }
        }
        
    }
    
}
