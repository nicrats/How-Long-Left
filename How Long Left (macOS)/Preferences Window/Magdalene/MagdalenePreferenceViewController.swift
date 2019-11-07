//
//  GeneralPreferenceViewController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 4/12/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa
import Preferences


final class MagdalenePreferenceViewController: NSViewController, Preferenceable {
    let toolbarItemTitle = "Magdalene"
    let toolbarItemIcon = NSImage(named: "MagdaleneIcon")!
    
    override var nibName: NSNib.Name? {
        return "MagdalenePreferencesView"
    }
    
    @IBAction func desClicked(_ sender: Any) {
        
        HLLDefaults.magdalene.manuallyDisabled = !HLLDefaults.magdalene.manuallyDisabled
        
        updateButtonsState()
        
    }
    var magdaleneHolidays = SchoolHolidayEventFetcher()
    
    let schoolAnalyser = SchoolAnalyser()
    
    @IBOutlet weak var magdaleneFeaturesButton: NSButton!
   // @IBOutlet weak var doDoublesButton: NSButton!
    
    @IBOutlet weak var showBreaksButton: NSButton!
    @IBOutlet weak var countDownSchoolHolidaysButton: NSButton!
    @IBOutlet weak var edvalButton: NSButton!
    @IBOutlet weak var magdaleneModeDescription: NSTextField!
    @IBOutlet weak var termButton: NSButton!
    @IBOutlet weak var showSportAsStudyButton: NSButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if HLLDefaults.magdalene.manuallyDisabled == false {
            magdaleneFeaturesButton.state = .on
        } else {
            magdaleneFeaturesButton.state = .off
        }
        
        if HLLDefaults.magdalene.doTerm == true {
            termButton.state = .on
        } else {
            termButton.state = .off
        }
        
        if HLLDefaults.magdalene.showSportAsStudy == true {
            showSportAsStudyButton.state = .on
        } else {
            showSportAsStudyButton.state = .off
        }
        
        if HLLDefaults.magdalene.showBreaks == true {
            showBreaksButton.state = .on
        } else {
            showBreaksButton.state = .off
        }
        
        if HLLDefaults.magdalene.showEdvalButton == true {
            edvalButton.state = .on
        } else {
            edvalButton.state = .off
        }
        
        
        
        if HLLDefaults.magdalene.doHolidays == true {
            countDownSchoolHolidaysButton.state = .on
        } else {
            countDownSchoolHolidaysButton.state = .off
        }
        
        
        updateButtonsState()
       
    }
    
    func updateButtonsState() {
        
        
        
        let state = !HLLDefaults.magdalene.manuallyDisabled
        // doDoublesButton.isEnabled = !state
        
        showBreaksButton.isEnabled = state
        countDownSchoolHolidaysButton.isEnabled = state
        edvalButton.isEnabled = state
        termButton.isEnabled = state
        
        if state == true {
            magdaleneFeaturesButton.state = .on
        } else {
            magdaleneFeaturesButton.state = .off
        }
        
        
        
    }
    
    
    @IBAction func magdaleneFeaturesButtonClicked(_ sender: NSButton) {
        
        
            let on = sender.state == .on
            
            HLLDefaults.magdalene.manuallyDisabled = !on
            
        self.updateButtonsState()
        
        
        NotificationCenter.default.post(name: Notification.Name("updateCalendar"), object: nil)
        
            
    }
    

    
    @IBAction func showBreaksButtonClicked(_ sender: NSButton) {
        
         DispatchQueue.main.async {
        
        var state = false
        if sender.state == .on { state = true }
        HLLDefaults.magdalene.showBreaks = state
        NotificationCenter.default.post(name: Notification.Name("updateCalendar"), object: nil)
        
        }
            
    }
    
    @IBAction func showPrelmsClicked(_ sender: NSButton) {
        
        DispatchQueue.main.async {
            
            var state = false
            if sender.state == .on { state = true }
            HLLDefaults.magdalene.showPrelims = state
            NotificationCenter.default.post(name: Notification.Name("updateCalendar"), object: nil)
            
        }
        
    }
    
    @IBAction func edvalButtonButtonClicked(_ sender: NSButton) {
       
        DispatchQueue.main.async {
            
            var state = false
            if sender.state == .on { state = true }
            HLLDefaults.magdalene.showEdvalButton = state
            
        }
        
        
    }
    
    
    @IBAction func showSchoolHolidaysButtonClicked(_ sender: NSButton) {
        
         DispatchQueue.main.async {
        
        var state = false
        if sender.state == .on { state = true }
        HLLDefaults.magdalene.doHolidays = state
        NotificationCenter.default.post(name: Notification.Name("updateCalendar"), object: nil)
        
        }
            
    }
    
    @IBAction func showSportAsStudyClicked(_ sender: NSButton) {
        
         DispatchQueue.main.async {
        
        var state = false
        if sender.state == .on { state = true }
        HLLDefaults.magdalene.showSportAsStudy = state
            
            DispatchQueue.global().async {
                HLLEventSource.shared.updateEventPool()
            }
        
        }
            
    }
    
   
    @IBAction func showCurrentTerm(_ sender: NSButton) {
        
        DispatchQueue.main.async {
            
            var state = false
            if sender.state == .on { state = true }
            HLLDefaults.magdalene.doTerm = state
            NotificationCenter.default.post(name: Notification.Name("updateCalendar"), object: nil)
            
        }
        
    }
    
   
    

    
    
    
}
