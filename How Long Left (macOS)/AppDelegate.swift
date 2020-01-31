//
//  AppDelegate.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 18/10/18.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Cocoa
import Preferences
import CloudKit
import UserNotifications

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    let statusItemController = StatusItemController()
    let notificationScheduler = MacEventNotificationScheduler()
    let utilityRunLoopManager = UtilityRunLoopManager()
    let uploader = MagdaleneEventDataUploader()
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        DispatchQueue.main.async {
     
        NSUserNotificationCenter.default.delegate = self
        if #available(OSX 10.14, *) {
            UNUserNotificationCenter.current().delegate = self
        }

    
            
        HLLEventSource.shared.asyncUpdateEventPool()
        LaunchFunctions.shared.runLaunchFunctions()
        MagdaleneModeSetupPresentationManager.shared = MagdaleneModeSetupPresentationManager()
        HotKeyHandler.shared = HotKeyHandler()
            
        
            
        }
    
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
    
    
}

@available(OSX 10.14, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
      // show the notification alert (banner), and with sound
      completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let notificationInfo = response.notification.request.content.userInfo
               
           if let type = notificationInfo["Type"] as? String {
               
            if type == "Cal" {
            
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars"),
                
                NSWorkspace.shared.open(url) {
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NSWorkspace.shared.launchApplication("System Preferences")
            }

            }
               
           }
    
           completionHandler()
         }

    
}
