//
//  ExtensionDelegate.swift
//  How Long Left (watchOS) Extension
//
//  Created by Ryan Kontos on 15/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import WatchKit
import UserNotifications

class ExtensionDelegate: NSObject, WKExtensionDelegate, UNUserNotificationCenterDelegate {
    
    let calendarData = EventDataSource()
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.sound)
    }
    
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        
    //    let schoolAnalyser = SchoolAnalyser()
     //   schoolAnalyser.analyseCalendar()
        DispatchQueue.main.async {
        
        WatchSessionManager.sharedManager.startSession()
        WatchSessionManager.sharedManager.askForDefaults()
        
        }
            
    }

    func applicationDidBecomeActive() {
        
        
     //   HLLDefaults.shared.loadDefaultsFromCloud()
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     /*   DispatchQueue.global(qos: .default).async {
      let bh = BackgroundUpdateHandler(); bh.scheduleComplicationUpdate()
        }
        
        
        
        print("Became active") */
        
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    func handleUserActivity(_ userInfo: [AnyHashable : Any]?) {
        
        DispatchQueue.main.async {
            
        if userInfo?[CLKLaunchedTimelineEntryDateKey] as? Date != nil {
            // Handoff from complication
            
            if let entries = CLKComplicationServer.sharedInstance().activeComplications {
                
                 if ComplicationDataStatusHandler.shared.complicationIsUpToDate() == false {
                
                    
                    
                for complicationItem in entries  {
                    
                    print("Reload4")
                    
                    CLKComplicationServer.sharedInstance().reloadTimeline(for: complicationItem)
                    
                }
            }
            
            }
            
        }
        else {
            // Handoff from elsewhere
        }
        
        }
        
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        
        DispatchQueue.main.async {
        
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                
                
                
                if let entries = CLKComplicationServer.sharedInstance().activeComplications {
                    
                    if ComplicationDataStatusHandler.shared.complicationIsUpToDate() == false {
                    
                        
                        
                    for complicationItem in entries  {
                        
                        print("Reload5")
                        
                        CLKComplicationServer.sharedInstance().reloadTimeline(for: complicationItem)
                        
                    }
                        
                    }
                }
                
                
                let bh = BackgroundUpdateHandler(); bh.scheduleComplicationUpdate()
                
                
                
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
                
                
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
            
            }
            
        }
        
    }

}
