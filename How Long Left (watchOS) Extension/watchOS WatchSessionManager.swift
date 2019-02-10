//
//  watchOS WatchSessionManager.swift
//  How Long Left (watchOS) Extension
//
//  Created by Ryan Kontos on 25/1/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import EventKit
import ClockKit
import WatchConnectivity
import UserNotifications

class WatchSessionManager: NSObject, WCSessionDelegate {
    
    let defaults = UserDefaults.standard
    let complication = CLKComplicationServer.sharedInstance()
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
   
    
    
    static let sharedManager = WatchSessionManager()
    private override init() {
        super.init()
    }
    private var dataSourceChangedDelegates = [DataSourceChangedDelegate]()
    
    private let session: WCSession = WCSession.default
    
    func startSession() {
        session.delegate = self
        session.activate()
    }
    
    func addDataSourceChangedDelegate<T>(delegate: T) where T: DataSourceChangedDelegate, T: Equatable {
        dataSourceChangedDelegates.append(delegate)
    }
    
    
    
    func removeDataSourceChangedDelegate<T>(delegate: T) where T: DataSourceChangedDelegate, T: Equatable {
        for (index, dataSourceDelegate) in dataSourceChangedDelegates.enumerated() {
            if let dataSourceDelegate = dataSourceDelegate as? T, dataSourceDelegate == delegate {
                dataSourceChangedDelegates.remove(at: index)
                break
            }
        }
    }
}

extension WatchSessionManager {
    
    // Receiver
    
    
    func sendUpdatedComplicationMessage() {
      //  WatchSessionManager.sharedManager.startSession()
      //  session.sendMessage(["UpdatedComplication" : Date()], replyHandler: nil, errorHandler: nil)
        
    }
    
    func gotData(data: [String : Any]) {
        
        
        DispatchQueue.main.async {
            
            let center = UNUserNotificationCenter.current()
            // Request permission to display alerts and play sounds.
            center.requestAuthorization(options: [.alert, .sound])
            { (granted, error) in
                
                
            }
            
            if let rArray = data["SelectedCalendars"] {
                
                let calArray = rArray as! [String]
                
                
                
                self.defaults.set(calArray, forKey: "setCalendars")
                
                
                
            } else if let rArray = data["MagdaleneManualSettingChanged"]  {
                
                let setting = rArray as! Bool
                
                self.defaults.set(setting, forKey: "magdaleneFeaturesManuallyDisabled")
                
            }
            
            self.dataSourceChangedDelegates.forEach { $0.userInfoChanged() }
            
        }
        
    }
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        gotData(data: message)
        
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        gotData(data: applicationContext)
    }
    
    
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        
        gotData(data: userInfo)
    }
}
protocol DataSourceChangedDelegate {
    func userInfoChanged()
}


