//
//  iOS WatchSessionManager.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 25/1/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import WatchConnectivity
import EventKit

class WatchSessionManager: NSObject, WCSessionDelegate {
    
    let defaults = HLLDefaults.defaults
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        DispatchQueue.main.async {
            
            if let updatedDate = message["UpdatedComplication"] as? Date {
                
                self.dataSourceChangedDelegates.forEach { $0.userInfoChanged(date: updatedDate) }
                
            }
            
        }
        
        
    }
    
    
    static let sharedManager = WatchSessionManager()
    private override init() {
        super.init()
    }
    
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    
    private var validSession: WCSession? {
        
        // paired - the user has to have their device paired to the watch
        // watchAppInstalled - the user must have your watch app installed
        
        // Note: if the device is paired, but your watch app is not installed
        // consider prompting the user to install it for a better experience
        
        if let session = session, session.isPaired && session.isWatchAppInstalled {
            return session
        }
        return nil
    }
    
    
    func startSession() {
        session?.delegate = self
        session?.activate()
    }
    
    private var dataSourceChangedDelegates = [DataSourceChangedDelegate]()
    
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
    
    // Sender
    
    func updateComplication() {
        
      //  validSession?.transferCurrentComplicationUserInfo(["UpdateComplication" : ""])
        
    }
    
    
    
    
    func transferUserInfo(userInfo: [String : Any]) -> WCSessionUserInfoTransfer? {
        return validSession?.transferUserInfo(userInfo)
    }
    
    
    func updateContext(userInfo: [String : Any]) {
            
            validSession?.sendMessage(userInfo, replyHandler: nil, errorHandler: { Error in
                
                do {
                    
                    try self.validSession?.updateApplicationContext(userInfo)
                    
                } catch {
                    
                    print("Failed")
                    
                }

                
            })
        
        
            }
    
    
}
protocol DataSourceChangedDelegate {
    func userInfoChanged(date: Date)
}
