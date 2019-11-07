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
                
                
                    
                    
                    NSApp.activate(ignoringOtherApps: true)
                
                
                    let alert: NSAlert = NSAlert()
                    alert.window.title = "How Long Left \(Version.currentVersion)"
                    alert.messageText = "New in Magdalene Mode:"
                    alert.informativeText = """
                    - This update resolves an issue where Rename didn't add Lunch and Recess events to the calendar. If you ran Rename in version 3.0.3, you'll need to run it again.
                    
                    """
                    
                    alert.alertStyle = NSAlert.Style.informational
                    alert.addButton(withTitle: "OK")
                    alert.window.collectionBehavior = .canJoinAllSpaces
                    alert.window.level = .floating
                    NSApp.activate(ignoringOtherApps: true)
                    alert.runModal()

                
                
                
            }
            
        }
        
        
        
    }
    
    func presentShowStudyAsSportPrompt() {
        
        let year = Date().year()
        let nextYearString = String(year+1)
        let currentYearString = String(year)
        
        if SchoolAnalyser.schoolMode == .Magdalene, HLLDefaults.magdalene.showSportAsStudy == false, HLLDefaults.defaults.bool(forKey: "PromptedToShowSportAsStudy") == false, let deviceName = Host.current().localizedName, deviceName.containsAnyOfThese(Strings: [currentYearString, nextYearString])  {
            
               
                HLLDefaults.defaults.set(true, forKey: "PromptedToShowSportAsStudy")
                
                NSApp.activate(ignoringOtherApps: true)
                let alert: NSAlert = NSAlert()
                alert.window.title = "How Long Left"
                alert.messageText = "Would you like How Long Left to show your Tuesday sport period as \"Study\"?"
                alert.informativeText = "This is useful if you do study during sport."
            
                alert.alertStyle = NSAlert.Style.informational
                
                
                alert.addButton(withTitle: "Yes")
                alert.addButton(withTitle: "No")
                alert.window.collectionBehavior = .canJoinAllSpaces
                alert.window.level = .floating
                
                NSApp.activate(ignoringOtherApps: true)
                let button = alert.runModal()
                
                
                if button == NSApplication.ModalResponse.alertFirstButtonReturn {
                    
                    HLLDefaults.magdalene.showSportAsStudy = true
                    
                        
                        HLLEventSource.shared.updateEventPool()
                        
                    
                   
                    
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
            
            Thanks for using How Long Left. 😁
            
            """
            
            alert.alertStyle = NSAlert.Style.informational
            alert.addButton(withTitle: "OK")
            alert.window.collectionBehavior = .canJoinAllSpaces
            alert.window.level = .floating
            NSApp.activate(ignoringOtherApps: true)
            alert.runModal()
            
        }
    }
    
    func presentSentralPrompt(reinstall: Bool) {
        
        
        DispatchQueue.main.async {
            
            let installInstructions = "You can do this by logging in, navigating to the \"My Timetable\" section, and clicking the blue \"Export as iCal\" button"
            
            var titleText = "Please download your timetable from Sentral"
            var infoText = """
            To use How Long Left with your Magdalene classes, please download your timetable from Sentral. \(installInstructions).
            
            """
            
            if reinstall == true {
                
            titleText = "Please download your timetable from Sentral"
                
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
            alert.window.collectionBehavior = .canJoinAllSpaces
            alert.window.level = .floating
            
            NSApp.activate(ignoringOtherApps: true)
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
