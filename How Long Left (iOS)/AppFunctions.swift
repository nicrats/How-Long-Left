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
    let schoolAnalyser = SchoolAnalyser()
    
    init() {
        
   //     HLLDefaults.shared.loadDefaultsFromCloud()
        VoiceShortcutStatusChecker.shared.check()
        let eventDatasource = EventDataSource()
        eventDatasource.getCalendarAccess()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { self.run() })

    }
    
    func run() {
        
        DispatchQueue.main.async {
        
        VoiceShortcutStatusChecker.shared.check()
            self.donateInteraction()
        
       
            self.schoolAnalyser.analyseCalendar()
        
        WatchSessionManager.sharedManager.startSession()
        
        self.sync.syncDefaultsToWatch()
        
        
        self.notoScheduler.getAccess()
        self.notoScheduler.scheduleNotificationsForUpcomingEvents()
        
        
        }
        
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
    
    func getPurchaseComplicationViewController() -> UIViewController {
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            return mainStoryboard.instantiateViewController(withIdentifier: "PurchaseVC")
    }
    
}
