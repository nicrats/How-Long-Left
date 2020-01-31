//
//  GeneralPreferenceViewController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 4/12/18.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa
import Preferences


final class MagdalenePreferenceViewController: NSViewController, PreferencePane {
    
    let preferencePaneIdentifier = PreferencePane.Identifier.magdalene
    var preferencePaneTitle: String = "Magdalene"
    
    let schoolEventDownloadNeededEvaluator = SchoolEventDownloadNeededEvaluator()
    
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
    @IBOutlet weak var compassButton: NSButton!
    @IBOutlet weak var magdaleneModeDescription: NSTextField!
    @IBOutlet weak var termButton: NSButton!
    @IBOutlet weak var showSportAsStudyButton: NSButton!
    @IBOutlet weak var showSubjectNamesButton: NSButton!
    @IBOutlet weak var showRoomChanges: NSButton!
    @IBOutlet weak var oldRoomNamesButton: NSPopUpButtonCell!
    
    override func viewWillAppear() {
        
        PreferencesWindowManager.shared.currentIdentifier = preferencePaneIdentifier
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 466, height: 386)
        
        oldRoomNamesButton.selectItem(at: HLLDefaults.magdalene.oldRoomNames.rawValue)
        
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
        
        if HLLDefaults.magdalene.useSubjectNames == true {
            showSubjectNamesButton.state = .on
        } else {
            showSubjectNamesButton.state = .off
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
        
        if HLLDefaults.magdalene.showCompassButton == true {
            compassButton.state = .on
        } else {
            compassButton.state = .off
        }
        
        
        
        if HLLDefaults.magdalene.doHolidays == true {
            countDownSchoolHolidaysButton.state = .on
        } else {
            countDownSchoolHolidaysButton.state = .off
        }
        
        if HLLDefaults.magdalene.showChanges == true {
            showRoomChanges.state = .on
        } else {
            showRoomChanges.state = .off
        }
        
        
        updateButtonsState()
       
    }
    
    func updateButtonsState() {
        
        
        
        let state = !HLLDefaults.magdalene.manuallyDisabled
        // doDoublesButton.isEnabled = !state
        
        showBreaksButton.isEnabled = state
        countDownSchoolHolidaysButton.isEnabled = state
        compassButton.isEnabled = state
        termButton.isEnabled = state
        showSportAsStudyButton.isEnabled = state
        showRoomChanges.isEnabled = state
        showSubjectNamesButton.isEnabled = state
        oldRoomNamesButton.isEnabled = state
        
        if state == true {
            magdaleneFeaturesButton.state = .on
        } else {
            magdaleneFeaturesButton.state = .off
        }
        
        
        
    }
    
    
    @IBAction func roomNameButtonClicked(_ sender: NSPopUpButtonCell) {
        
        let index = sender.index(of: sender.selectedItem!)
        
        
        HLLDefaults.magdalene.oldRoomNames = OldRoomNamesSetting(rawValue: index)!
        HLLEventSource.shared.asyncUpdateEventPool()
    }
    
    @IBAction func magdaleneFeaturesButtonClicked(_ sender: NSButton) {
        
        
            let on = sender.state == .on
            
            HLLDefaults.magdalene.manuallyDisabled = !on
            
        self.updateButtonsState()
        HLLEventSource.shared.asyncUpdateEventPool()
        
            
    }
    

    
    @IBAction func showBreaksButtonClicked(_ sender: NSButton) {
        
         DispatchQueue.main.async {
        
        var state = false
        if sender.state == .on { state = true }
        HLLDefaults.magdalene.showBreaks = state
        HLLEventSource.shared.asyncUpdateEventPool()
        
        }
            
    }
    
    @IBAction func showPrelmsClicked(_ sender: NSButton) {
        
        DispatchQueue.main.async {
            
            var state = false
            if sender.state == .on { state = true }
            HLLDefaults.magdalene.showPrelims = state
            HLLEventSource.shared.asyncUpdateEventPool()
            
        }
        
    }
    
    @IBAction func compassButtonClicked(_ sender: NSButton) {
       
        DispatchQueue.main.async {
            
            var state = false
            if sender.state == .on { state = true }
            HLLDefaults.magdalene.showCompassButton = state
            
            
        }
        
        
    }
    
    
    @IBAction func showSchoolHolidaysButtonClicked(_ sender: NSButton) {
        
         DispatchQueue.main.async {
        
        var state = false
        if sender.state == .on { state = true }
        HLLDefaults.magdalene.doHolidays = state
        HLLEventSource.shared.asyncUpdateEventPool()
        
        }
            
    }
    
    @IBAction func showSportAsStudyClicked(_ sender: NSButton) {
        
         DispatchQueue.main.async {
        
        var state = false
        if sender.state == .on { state = true }
        HLLDefaults.magdalene.showSportAsStudy = state
        HLLEventSource.shared.asyncUpdateEventPool()
        
        }
            
    }
    
   
    @IBAction func showCurrentTerm(_ sender: NSButton) {
        
        DispatchQueue.main.async {
            
            var state = false
            if sender.state == .on { state = true }
            HLLDefaults.magdalene.doTerm = state
            HLLEventSource.shared.asyncUpdateEventPool()
            
        }
        
    }
    
    @IBAction func showChangesClicked(_ sender: NSButton) {
        
        DispatchQueue.main.async {
            
            var state = false
            if sender.state == .on { state = true }
            HLLDefaults.magdalene.showChanges = state
            HLLEventSource.shared.asyncUpdateEventPool()
            
        }
        
    }
    
    @IBAction func showSubjectNamesClicked(_ sender: NSButton) {
        
        DispatchQueue.main.async {
            
            var state = false
            if sender.state == .on { state = true }
            HLLDefaults.magdalene.useSubjectNames = state
            HLLEventSource.shared.asyncUpdateEventPool()
            
        }
        
    }
    
    
    @IBAction func download2020Clicked(_ sender: Any) {
        
        DispatchQueue.main.async {
            
            MagdaleneModeSetupPresentationManager.shared.presentMagdaleneModeSetup(with: .notNeeded)
                   
            
        }
        
    }
    
    
    
    
}
