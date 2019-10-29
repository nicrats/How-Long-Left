//
//  AppDelegate.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 18/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Cocoa
import Preferences
import CloudKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        

        
        NSApp.activate(ignoringOtherApps: true)
        
        NSUserNotificationCenter.default.delegate = self
        //aFabric.with([Crashlytics.self])
        
        #if DEBUG
        print("I'm running in DEBUG mode")
        
        #else
        print("I'm running in a non-DEBUG mode")

        #endif

    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter,
                                didActivate notification: NSUserNotification) {
        if notification.identifier == "Update" {
            if let url = URL(string: "macappstore://showUpdatesPage"), NSWorkspace.shared.open(url) {
                print("default browser was successfully opened")
            }
            print("Update clicked")
        } else if notification.identifier == "Cal" {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars"),
                
                NSWorkspace.shared.open(url) {
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NSWorkspace.shared.launchApplication("System Preferences")
            }
        }    }

    
    func application(_ application: NSApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void) -> Bool {
        
        DispatchQueue.main.async {
            
            if let id = userActivity.userInfo?["EventID"] as? String {
                
                print("Launching with \(id)")
                
                if let event = HLLEventSource.shared.findEventWithAppIdentifier(id: id) {
                    
                    EventUIWindowsManager.shared.launchWindowFor(event: event)
                    
                }
                
            }
            
            
            
        }
        
        
        return true
        
    }
    
    func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String : Any]) {
        
        
    }
    
}
