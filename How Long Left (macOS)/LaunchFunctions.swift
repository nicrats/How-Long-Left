//
//  LaunchFunctions.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 9/12/19.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class LaunchFunctions: EventPoolUpdateObserver, OnboardingCompletionDelegate {
    
    static var shared = LaunchFunctions()
    
    let magdalenePrompts = MagdalenePrompts()
    let magdaleneWifiCheck = MagdaleneWifiCheck()
    
    var performedPostOnboardingActions = false
    var previousLaunchVersion: String?
    
    func runLaunchFunctions() {
        
        if let previous = HLLDefaults.appData.launchedVersion {
            
            previousLaunchVersion = previous
            onboardingComplete()
            
        } else {
            
            OnboardingWindowManager.shared.showOnboardingIfNeeded(delegate: self)
            return
        }
        
    }
    
    func onboardingComplete() {
        
        HLLDefaults.appData.launchedVersion = Version.currentVersion
        HLLEventSource.shared.addEventPoolObserver(self)
        
    }
    
    func eventPoolUpdated() {
        
        if performedPostOnboardingActions == false {
            
            performedPostOnboardingActions = true
            postOnboardingLaunchActions()
         
        }
        
    }
    
    func postOnboardingLaunchActions() {
      
        
        if SchoolAnalyser.schoolMode == .Magdalene {
            
            if let previous = previousLaunchVersion, Version.currentVersion > previous {
               self.magdalenePrompts.presentMagdaleneChangesPrompt()
            }
            
            MagdaleneModeSetupPresentationManager.shared.allowAutomaticPresentation = true
            
            MagdaleneModeSetupPresentationManager.shared.presentMagdaleneModeSetupIfNeeded()
            
            
        }
        
    }
    
}
