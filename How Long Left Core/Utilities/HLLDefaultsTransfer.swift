//
//  HLLDefaultsTransfer.swift
//  How Long Left
//
//  Created by Ryan Kontos on 18/10/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class HLLDefaultsTransfer {
    
    static var shared = HLLDefaultsTransfer()
    
    var transferHandlers = [DefaultsTransferHandler]()
    var transferObservers = [DefaultsTransferObserver]()
    var lastSentDict = [String:Any]()
    
    private let serialQueue = DispatchQueue(label: "GotDefaultsQueue")
    
    var transferableKeys = [
        
        "preferencesLastModifiedByUser",
        "setCalendars",
        "disabledCalendars",
        "magdaleneModeWasEnabled",
        "magdaleneFeaturesManuallyDisabled",
        "hideMExtras"
    
    ]

    func addTransferHandler(_ handler: DefaultsTransferHandler) {
        self.transferHandlers.append(handler)
    }
    
     
    func addTransferObserver(_ observer: DefaultsTransferObserver) {
        self.transferObservers.append(observer)
    }
    
    func userModifiedPrferences() {
    
        HLLDefaults.defaults.set(Date(), forKey: "preferencesLastModifiedByUser")
        triggerDefaultsTransfer()
        
        DispatchQueue.global(qos: .default).async {
        HLLEventSource.shared.updateEventPool()
        }

    }
     
    let prefsQueue = DispatchQueue(label: "PreferencesLoadQueue")
    
  
    
     func gotNewPreferences(_ newPreferences: [String:Any]) {


        
        DispatchQueue.global().async {
          
            
         print("Downloaded new preferences from paired device")
         
         if let newModificationDate = newPreferences["preferencesLastModifiedByUser"] as? Date {
             
             var currentModificationDate = HLLDefaults.defaults.object(forKey: "preferencesLastModifiedByUser") as? Date
         
             if currentModificationDate == nil {
                 print("Current modification date was nil, setting to old")
                 currentModificationDate = Date.distantPast
             }
             
             if newModificationDate.timeIntervalSince(currentModificationDate!) > 0 {
                 
                 print("New preferences are more recent than the current ones, replacing them")
                 
                 for item in newPreferences {
                     
                       
                     HLLDefaults.defaults.set(item.value, forKey: item.key)
                         
                     
                     
                 }
                
              
                
                 DispatchQueue.main.async {
                     self.transferObservers.forEach { $0.defaultsUpdatedRemotely() }
                 }
                 HLLEventSource.shared.updateEventPool()
                 print("PoolC4")
                    
                
                 
             } else {
                 
                 print("New preferences are older than current, keeping the current ones")
                 
             }
             
         } else {
             
             print("Remote modified date was nil")
             
         }
         
        }
         
     }
    
    func createDictionaryOfUserDefaultsStringValues() -> [String:String] {
        
        var returnDict = [String:String]()
        
        let rep = HLLDefaults.defaults.dictionaryRepresentation()
        
        for item in rep {
            
            if let value = item.value as? String {
                
                returnDict[item.key] = value
                
            }
            
        }
        
        return returnDict
        
    }
     
     func triggerDefaultsTransfer() {
         
        
         DispatchQueue.global(qos: .default).async {
         
        
            
         var transferDictionary = [String:Any]()
         
         let defaultsDictionary = HLLDefaults.defaults.dictionaryRepresentation()
         
         for item in defaultsDictionary {
                 
                 #if os(watchOS)
                                    
                     if item.key == "magdaleneModeWasEnabled" {
                         continue
                     }
                                    
                 #endif
                                    
                 transferDictionary[item.key] = item.value
                 
             
             
             
         }
         
         if !transferDictionary.isEmpty {
             
            if self.lastSentDict.description != transferDictionary.description {
             
                self.lastSentDict = transferDictionary
                self.transferHandlers.forEach {$0.transferDefaultsDictionary(transferDictionary)}
             
            }
         
         }
             
         }
     }

}
