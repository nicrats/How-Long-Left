//
//  OnboardingWindowController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 4/12/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import AppKit

class OnboardingWindowController: NSWindowController {
    
    override func windowDidLoad() {
        
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
            self.window?.center()
            self.window?.styleMask.remove(.resizable)
            self.window?.level = .normal
            self.window?.makeKeyAndOrderFront(nil)
        }
    
}

