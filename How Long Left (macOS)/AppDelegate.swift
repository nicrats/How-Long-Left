//
//  AppDelegate.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 18/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Cocoa
import Preferences
//import Fabric
//import Crashlytics

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    @IBOutlet weak var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        NSApp.activate(ignoringOtherApps: true)
        
        #if DEBUG
        print("I'm running in DEBUG mode")
        
        #else
        print("I'm running in a non-DEBUG mode")

        #endif

    }
    
    func applicationWillResignActive(_ notification: Notification) {
        
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        
        // TODO: Check time, if after time return false.
        
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
        }
    }

}
