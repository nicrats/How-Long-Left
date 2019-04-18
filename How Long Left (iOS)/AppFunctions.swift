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
        
   //     HLLDefaults.shared.loadDefaultsFromCloud()
        VoiceShortcutStatusChecker.shared.check()
        let eventDatasource = EventDataSource()
        eventDatasource.getCalendarAccess()
        
        NotificationCenter.default.addObserver(self, selector: #selector(defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cloudDefaultsChanged),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: nil)
        
        run()
    }
    
    func run() {
        
        
        VoiceShortcutStatusChecker.shared.check()
        donateInteraction()
        
       
        SchoolAnalyser.shared.analyseCalendar()
        
        WatchSessionManager.sharedManager.startSession()
        
        self.sync.syncDefaultsToWatch()
        
        
        self.notoScheduler.getAccess()
        self.notoScheduler.scheduleNotificationsForUpcomingEvents()
        
        
        
        
    }
    
    @objc private func cloudDefaultsChanged() {
        
    //    HLLDefaults.shared.loadDefaultsFromCloud()
        
    }
    
    @objc private func defaultsChanged() {
        
      //  HLLDefaults.shared.exportDefaultsToCloud()
        
        
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
