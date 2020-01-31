//
//  Version.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 11/12/18.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation

class Version {
    
    
    
    static var currentVersion: String {
        
        get {
            
            return (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
            
        }
        
        
    }
    static var buildVersion: String {
        
        
        get {
            
           return (Bundle.main.infoDictionary?["CFBundleVersion"] as? String)!
            
            
        }
        
    }
    
    var appStoreVersion: String?
    
    func updateAvaliable() -> String? {
        
        var returnVal: String?
        
        if let ASVersion = getAppStoreVersion() {
            
            if ASVersion > Version.currentVersion {
                returnVal = ASVersion
            }
            
        }
        
        return returnVal
    }
    
    
    func getAppStoreVersion() -> String? {
        
        var returnVal: String?
        let infoDictionary = Bundle.main.infoDictionary
        let appID = infoDictionary!["CFBundleIdentifier"] as! String
        let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(appID)")
        if let data = try? Data(contentsOf: url!) {
            if let lookup = (try? JSONSerialization.jsonObject(with: data , options: [])) as? [String: Any] {
                if let resultCount = lookup["resultCount"] as? Int, resultCount == 1 {
                    if let results = lookup["results"] as? [[String:Any]] {
                        if let AS = results[0]["version"] as? String {
                            appStoreVersion = AS
                            returnVal = AS
                            
                        }
                    }
                }
            }
        }
        return returnVal
    }
    
}
