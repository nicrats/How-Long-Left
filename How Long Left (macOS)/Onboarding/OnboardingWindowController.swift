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
        
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        window?.styleMask.remove(.resizable)
        window?.level = .floating
        
    }
    
}
