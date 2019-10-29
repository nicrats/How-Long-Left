//
//  MainUIViewController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 1/7/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Cocoa

class EventUICountdownViewController: NSViewController {
    
    var parentController: EventUITabViewController!
    @IBOutlet weak var eventText: NSTextField!
    @IBOutlet weak var timerLabel: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
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
            
            eventText.stringValue = "\(safeEvent.title) ends in"
            
            timer = Timer(fireAt: Date(), interval: 0.5, target: self, selector: #selector(mainRun), userInfo: nil, repeats: true)
            RunLoop.main.add(timer, forMode: .common)
            
        }
    }
    
    @objc func mainRun() {
        
        let _ = self.parentController.event?.refresh()
        
        if let currentEvent = self.parentController.event {
            
          
            
            self.timerLabel.stringValue = self.timerStringGenerator.getTimerCountdownString(event: currentEvent, justTimer: false, long: true)!
            
            progressBar.doubleValue = currentEvent.completionFraction
            
            print(currentEvent.completionFraction)
            
            percentLabel.stringValue = currentEvent.completionPercentage!
            
            if currentEvent.completionStatus != .InProgress {
                
                parentController?.nextPage()
                
            }
            
            
        } else {
            
            parentController?.nextPage()
            
        }
        
        
        
        
    }

    
}
