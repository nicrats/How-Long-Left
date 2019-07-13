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

    @IBAction func continueClicked(_ sender: NSButton) {
        self.view.window?.performClose(nil)
        
    }
    
    @IBAction func preferencesClicked(_ sender: NSButton) {
        
        self.view.window?.performClose(nil)
        
       MenuController.shared?.launchPreferences()
        
    }
}
