//
//  AppDelegate.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 15/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import UIKit
import UserNotifications
import CloudKit
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
 
    let taskID = "com.ryankontos.How-Long-Left.refresh"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
       /* let date = Date()
        
        while HLLEventSource.shared.access == .Unknown && date.timeIntervalSinceNow < 1 {}
       
        if HLLEventSource.shared.access == .Granted {
        while HLLEventSource.shared.neverUpdatedEventPool && date.timeIntervalSinceNow < 1  {}
        }*/
        
        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            
            self.handleShortcut(shortcutItem)
            
        }

        
        application.registerForRemoteNotifications()
        // Override point for customization after application launch.
        WatchSessionManager.sharedManager.startSession()
        
        if #available(iOS 13.0, *) {
            
            BGTaskScheduler.shared.register(forTaskWithIdentifier: taskID, using: nil) { task in
                self.handleAppRefreshTask(task: task as! BGAppRefreshTask)
            }
            
        } else {
            
            application.setMinimumBackgroundFetchInterval(200)
            
        }
        
        
        if #available(iOS 13.0, *) {
            scheduleAppRefresh()
        }
        
        
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        completionHandler(.newData)
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for remote")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("NOT registered for remote, wtf")
    }
    
   func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    runBackgroundTasks()
   
    }
    
    func runBackgroundTasks() {
        
        
           notoGen.scheduleNotificationsForUpcomingEvents()
           UNUserNotificationCenter.current().removeAllDeliveredNotifications()
           HLLDefaultsTransfer.shared.triggerDefaultsTransfer()
           print("Trig5")
           
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
        runBackgroundTasks()
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        if #available(iOS 13.0, *) {
            scheduleAppRefresh()
        }
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
     //   HLLDefaults.shared.loadDefaultsFromCloud()
        
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        HLLDefaultsTransfer.shared.triggerDefaultsTransfer()
        print("Trig6")
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        print("Got activity")
        return false
        
    }
    
    private func handleShortcut(_ item: UIApplicationShortcutItem) {
        
       if let shortcutItem = ApplicationShortcut(rawValue: item.type) {
            
            switch shortcutItem {
            
            case .LaunchCurrentEvents:
                RootViewController.launchPage = .Current
            case .LaunchUpcomingEvents:
                RootViewController.launchPage = .Upcoming
            case .LaunchSettngs:
               RootViewController.launchPage = .Settings
            
        }
            
        }
            
        
    }
    
    
    var window: UIWindow?

    let notoGen = MilestoneNotificationScheduler()

}

enum ApplicationShortcut: String {
    
    case LaunchCurrentEvents = "com.ryankontos.howlongleft.currentEventsQuickAction"
    case LaunchUpcomingEvents = "com.ryankontos.howlongleft.upcomingEventsQuickAction"
    case LaunchSettngs = "com.ryankontos.howlongleft.SettingsQuickAction"
    
}


@available(iOS 13.0, *)
extension AppDelegate {
    
    func scheduleAppRefresh() {
        
        BGTaskScheduler.shared.cancelAllTaskRequests()
        
        let request = BGAppRefreshTaskRequest(identifier: taskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 120)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    func handleAppRefreshTask(task: BGAppRefreshTask) {

        task.expirationHandler = {
            
        }
        
        runBackgroundTasks()
        scheduleAppRefresh()
        task.setTaskCompleted(success: true)
    }

    
}
