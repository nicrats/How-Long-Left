//
//  MagdaleneUpdateAlert.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 19/12/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import AppKit

let version = Version()

class MagdaleneUpdateAlert {
    
    func CheckToShowMagdaleneChangesPrompt() {
        
        if SchoolAnalyser.schoolMode == .Magdalene {
        
        if let launched = HLLDefaults.appData.launchedVersion {
            
            if version.currentVersion > launched {
                
                presentMagdaleneChangesPrompt()
                
            }
            
        } else {
            
           
            presentMagdaleneChangesPrompt()
            
            
        }
        
            
        }
        
        
    }
    
    
    private func presentMagdaleneChangesPrompt() {
        
        DispatchQueue.main.async {
            
            NSApp.activate(ignoringOtherApps: true)
            let alert: NSAlert = NSAlert()
            alert.window.title = "How Long Left \(version.currentVersion)"
            alert.messageText = "New in Magdalene Mode:"
            alert.informativeText = """
            
            - Added a quick shortcut to Edval in the main menu.
            = You can now set How Long Left to hide non Magdalene calendar events in Magdalene Preferences.
            
            This update also brings support for the next three School Holidays periods.

            """
            
            alert.alertStyle = NSAlert.Style.informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
            
        }
    }
    
    
    
}
