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
            
            if Version.currentVersion > launched {
                
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
            alert.window.title = "How Long Left \(Version.currentVersion)"
            alert.messageText = "New in Magdalene Mode:"
            alert.informativeText = """
            
            - This update fixes an issue where Magdalene Mode would not be avaliable for Magdalene users.

            """
            
            alert.alertStyle = NSAlert.Style.informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
            
        }
    }
    
    func presentSentralPrompt() {
        
        DispatchQueue.main.async {
            
            NSApp.activate(ignoringOtherApps: true)
            let alert: NSAlert = NSAlert()
            alert.window.title = "How Long Left"
            alert.messageText = "Magdalene Timetable not installed"
            alert.informativeText = """
            To use How Long Left with your Magdalene classes, please download your timetable from Sentral. You can do this by logging in, navigating to the "My Timetable" section, and clicking "Export as iCal".
            
            """
            
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
