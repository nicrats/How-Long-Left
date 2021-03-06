//
//  MainUIViewController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 1/7/19.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Cocoa

class EventUICountdownViewController: NSViewController {
    
    var parentController: EventUITabViewController!
    @IBOutlet weak var eventText: NSTextField!
    @IBOutlet weak var timerLabel: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    var activity: NSUserActivity?
    
    @IBOutlet weak var percentLabel: NSTextField!
    var event: HLLEvent?
    
    var timer = Timer()
    let timerStringGenerator = CountdownStringGenerator()
    
    override func viewDidLoad() {
        
        parentController = (self.parent as! EventUITabViewController)
        
        super.viewDidLoad()
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        self.view.window?.makeMain()
        self.view.window?.makeKey()
        self.view.window?.makeKeyAndOrderFront(self)
        
     timerLabel.font = NSFont.monospacedDigitSystemFont(ofSize: timerLabel.font!.pointSize, weight: .regular)
        
        
        // Do view setup here.
    }
    
  
    override func viewWillAppear() {
        
        
        mainRun()
        
        if let safeEvent = parentController.event {
            
            self.view.window?.title = "\(safeEvent.title) Countdown"
            
            print("Ssfe \(safeEvent.title)")
            
            
            timer = Timer(fireAt: Date(), interval: 0.5, target: self, selector: #selector(mainRun), userInfo: nil, repeats: true)
            RunLoop.main.add(timer, forMode: .common)
            
           let activityObject = NSUserActivity(activityType: "com.ryankontos.how-long-left.viewEventActivity")
                 activityObject.title = safeEvent.title
                 
                let id = safeEvent.identifier
            
                    print("Activity id = \(id)")
            
                 activityObject.addUserInfoEntries(from: ["EventID":id])
                 activityObject.isEligibleForHandoff = true
                 activityObject.becomeCurrent()
                 self.activity = activityObject
                 
            
            
        }
        
        
    }
    
    override func viewWillDisappear() {
        self.activity?.invalidate()
    }
    
    @objc func mainRun() {
        
        if let currentEvent = self.parentController.event?.refresh() {
    
            eventText.stringValue = "\(currentEvent.title) \(currentEvent.countdownTypeString) in"
            
            self.timerLabel.stringValue = self.timerStringGenerator.generatePositionalCountdown(event: currentEvent, allowFullUnits: true)
            
            self.timerLabel.textColor = currentEvent.nsColor
            
            progressBar.doubleValue = currentEvent.completionFraction
            
            if currentEvent.completionFraction > 0 {
                
                percentLabel.isHidden = false

                percentLabel.stringValue = currentEvent.completionPercentage
                    
                

            } else {
                
                percentLabel.isHidden = true
                
            }
            
            if currentEvent.completionStatus == .Done {
                
                parentController?.nextPage()
                
            }
            
            
        } else {
            
            parentController?.nextPage()
            
        }
        
        
        
        
    }

    
}
