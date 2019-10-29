//
//  MagdalenePrompts.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 19/12/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import AppKit

class MagdalenePrompts {
   
    let version = Version()
    let showChangesPrompt = true
    
    func presentMagdaleneChangesPrompt() {
        
        
        if let launched = HLLDefaults.appData.launchedVersion, SchoolAnalyser.schoolMode == .Magdalene, showChangesPrompt == true {
            
            
            print("Current: \(Version.currentVersion)")
            print("Launched: \(launched)")
            
            
            
            if Version.currentVersion > launched {
                
                DispatchQueue.main.async {
                    
                    
                    NSApp.activate(ignoringOtherApps: true)
                    let alert: NSAlert = NSAlert()
                    alert.window.title = "How Long Left \(Version.currentVersion)"
                    alert.messageText = "New in Magdalene Mode:"
                    alert.informativeText = """
                    - This update resolves an issue where Rename didn't add Lunch and Recess events to the calendar. If you ran Rename in version 3.0.3, you'll need to run it again.
                    
                    """
                    
                    alert.alertStyle = NSAlert.Style.informational
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                    
                }
                
                
            }
            
        }
        
        
        
    }
    
    func presentSchoolHolidaysPrompt() {
        
        DispatchQueue.main.async {
            
            NSApp.activate(ignoringOtherApps: true)
            let alert: NSAlert = NSAlert()
            alert.window.title = "How Long Left \(Version.currentVersion)"
            alert.messageText = "School is done for the term!"
            alert.informativeText = """
            How Long Left will count down to the start of next term. You can disable this in Magdalene preferences.
            
            Have a great holiday! Thanks for using How Long Left. 😁
            
            """
            
            alert.alertStyle = NSAlert.Style.informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
            
        }
    }
    
    func presentSentralPrompt(reinstall: Bool) {
        
        
        DispatchQueue.main.async {
            
            let installInstructions = "You can do this by logging in, navigating to the \"My Timetable\" section, and clicking \"Export as iCal\""
            
            var titleText = "Magdalene Timetable not installed"
            var infoText = """
            To use How Long Left with your Magdalene classes, please download your timetable from Sentral. \(installInstructions).
            
            """
            
            if reinstall == true {
                
            titleText = "Please download your timetable."
                
            infoText = """
            Your timetable must be reinstalled from Sentral each term. \(installInstructions).
            
            """
        
            }
            
            NSApp.activate(ignoringOtherApps: true)
            let alert: NSAlert = NSAlert()
            alert.window.title = "How Long Left"
            alert.messageText = titleText
            alert.informativeText = infoText
            
            alert.alertStyle = NSAlert.Style.informational
            
            
            alert.addButton(withTitle: "Open Sentral")
            alert.addButton(withTitle: "Ignore")
            
            let button = alert.runModal()
            
            if button == NSApplication.ModalResponse.alertFirstButtonReturn {
                
                
                if let url = URL(string: "https://sent.mchsdow.catholic.edu.au/portal/timetable/mytimetable") {
                    NSWorkspace.shared.open(url)
                    
                }
                
                print("Opening Sentral")
                
            }
            
            
        }
    }
    
   
    
}
