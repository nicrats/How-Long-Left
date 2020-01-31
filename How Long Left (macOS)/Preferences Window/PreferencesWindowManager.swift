//
//  PreferencesWindowManager.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 26/11/19.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation
import AppKit
import Preferences

class PreferencesWindowManager: NSObject, NSWindowDelegate, EventPoolUpdateObserver {

    var relalunchingWindow = false
    
    func eventPoolUpdated() {

        DispatchQueue.main.async {
        
            if let launchMode = self.launchSchoolMode, let window = self.preferencesWindowController?.window, window.isVisible {
            
            if launchMode != SchoolAnalyser.privSchoolMode {
                
                    self.relalunchingWindow = true
                    self.launchPreferences(with: self.currentIdentifier, center: false)
                    
                }
                
            }
            
        }
        
    }
    
    
    static var shared = PreferencesWindowManager()
    
    var preferencesWindowController: PreferencesWindowController?
    
    var currentIdentifier: PreferencePaneIdentifier?
    var launchSchoolMode: SchoolMode!

    @objc func objcLaunchPreferences() {
        
        launchPreferences()
        
    }
    
    func launchPreferences(with ID: PreferencePaneIdentifier? = nil, center: Bool = true) {
        HLLEventSource.shared.addEventPoolObserver(self)
        
        launchSchoolMode = SchoolAnalyser.privSchoolMode
        
        preferencesWindowController?.window?.close()
        
        var viewControllers = [PreferencePane]()
        
        viewControllers.append(GeneralPreferenceViewController())
        viewControllers.append(MenuPreferenceViewController())
        viewControllers.append(StatusItemPreferenceViewController())
        
        if HLLEventSource.shared.access == CalendarAccessState.Denied {
            viewControllers.append(CalendarPreferenceViewControllerNoAccess())
        } else {
            viewControllers.append(CalendarPreferenceViewController())
        }
        
        viewControllers.append(NotificationPreferenceViewController())
            
        if SchoolAnalyser.privSchoolMode == .Magdalene {
            viewControllers.append(MagdalenePreferenceViewController())
        } else if MagdaleneWifiCheck.shared.isOnMagdaleneWifi() {
            viewControllers.append(MagdaleneNotSetupPreferenceViewController())
        }
        
        
        
        viewControllers.append(aboutViewController())
        
        preferencesWindowController = PreferencesWindowController(preferencePanes: viewControllers)
        
        preferencesWindowController?.window?.delegate = self
        //preferencesWindowController?.window?.collectionBehavior = [.fullScreenAllowsTiling]
        
        preferencesWindowController?.window?.title = "How Long Left Preferences"
        
        
        
        preferencesWindowController?.show(preferencePane: ID)
        
        WindowActivationWorkaround.shared.runWorkaroundFor(for: preferencesWindowController?.window)
        
        preferencesWindowController?.window?.makeKeyAndOrderFront(nil)
        
        if center {
        
        preferencesWindowController?.window?.center()
            
        }
        
        
        }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        
        if relalunchingWindow == false {
            preferencesWindowController?.window = nil
            preferencesWindowController = nil
        }
        
        relalunchingWindow = false
        
        return true
        
    }
        
    }
