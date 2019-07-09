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
import SystemConfiguration
import Reachability

class AppFunctions {
    
    static let shared = AppFunctions()
    
    static var isReachable = false
    
    
    private let notoScheduler = MilestoneNotificationScheduler()
    
    private let sync = DefaultsSync()
    let schoolAnalyser = SchoolAnalyser()
    let reachability = Reachability()!
    
    init() {
        
   //     HLLDefaults.shared.loadDefaultsFromCloud()
        VoiceShortcutStatusChecker.shared.check()
        let eventDatasource = EventDataSource()
        eventDatasource.getCalendarAccess()
        
        IAPHandler.shared.restorePurchase()
        
        reachability.whenReachable = { reachability in
            
            AppFunctions.isReachable = true
            if IAPHandler.complicationPriceString == nil {
                
                IAPHandler.shared.fetchAvailableProducts()
                
            }
            
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            
            AppFunctions.isReachable = false
            
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { self.run() })
        

    }
    
    func run() {
        
        DispatchQueue.main.async {
        
             IAPHandler.shared.fetchAvailableProducts()
            
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
