//
//  OnboardingViewController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 4/12/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import AppKit
import Preferences

class OnboardingViewController: NSViewController {
    
    @IBOutlet weak var visualEffectView: NSVisualEffectView!
    
    override func viewWillAppear() {
        
        
        
    }
    
    @IBAction func continueClicked(_ sender: NSButton) {
        
        self.view.window?.close()
        
    }
    
    @IBAction func preferencesClicked(_ sender: NSButton) {
        
        self.view.window?.close()
        
        var vcs: [Preferenceable] = [
            GeneralPreferenceViewController(),
            StatusItemPreferenceViewController()
        ]
        
        if EventDataSource.accessToCalendar == .Denied {
            
            vcs.append(CalendarPreferenceViewControllerNoAccess())
            
        } else {
            
            vcs.append(CalendarPreferenceViewController())
            
        }
        
        vcs.append(NotificationPreferenceViewController())
        
        if SchoolAnalyser.privSchoolMode == .Magdalene {
            
            vcs.append(MagdalenePreferenceViewController())
            
        }
        
        vcs.append(aboutViewController())
        
        
        
        UIController.preferencesWindowController.window?.close()
        
        UIController.preferencesWindowController = PreferencesWindowController (
            viewControllers: vcs
        )
        
        UIController.preferencesWindowController.window?.title = "How Long Left Preferences"
        UIController.preferencesWindowController.showWindow()
        
    }
}
