//
//  BackgroundFunctions.swift
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

class BackgroundFunctions {
    
    static let shared = BackgroundFunctions()
    static var isReachable = false
    private let notoScheduler = MilestoneNotificationScheduler()

    let reachability = Reachability()!
    
    init() {
        
        DispatchQueue.global(qos: .default).async {
        
            NotificationCenter.default.addObserver(self, selector: #selector(self.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
    
        
        
        
        VoiceShortcutStatusChecker.shared.check()

        
        
       // IAPHandler.shared.restorePurchase()
        
            self.reachability.whenReachable = { reachability in
            
            BackgroundFunctions.isReachable = true
            if IAPHandler.complicationPriceString == nil {
                
                IAPHandler.shared.fetchAvailableProducts()
                
            }
            
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
            self.reachability.whenUnreachable = { _ in
            print("Not reachable")
            
            BackgroundFunctions.isReachable = false
            
        }
        
       /* do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        } */
        
        self.run()
    }

    }
    
    func run() {
        
        DispatchQueue.main.async {
        
            IAPHandler.shared.fetchAvailableProducts()
            
        VoiceShortcutStatusChecker.shared.check()
        self.donateInteraction()

            
        print("Start2")
        
        
        self.notoScheduler.getAccess()
        self.notoScheduler.scheduleNotificationsForUpcomingEvents()
        
        
        }
        
    }
    
    @objc func defaultsChanged() {
        
      
        
        //DefaultsSync.shared.syncDefaultsToWatch()
        
        
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

