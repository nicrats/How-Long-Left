//
//  TodayViewController.swift
//  Mac Widget
//
//  Created by Ryan Kontos on 27/2/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Cocoa
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding {
    
    var eventFontSize: CGFloat = 20
    var noEventFontSize: CGFloat = 14
    let schoolAnalyser = SchoolAnalyser()
    
    var noEventOn = true
    
    var timer = Timer()
    let timerStringGenerator = CountdownStringGenerator()
    let cal = EventDataSource()
    var current: HLLEvent?
    
    @IBOutlet weak var endsInLabel: NSTextField!
    @IBOutlet weak var countdownLabel: NSTextField!
    
    
    
    override var nibName: NSNib.Name? {
        return NSNib.Name("TodayViewController")
    }
    
    
    override func viewDidLoad() {
        
        endsInLabel.alphaValue = 0.75
        countdownLabel.alphaValue = 0.75
        
        updateEventStore()
        timer = Timer(fireAt: Date(), interval: 0.5, target: self, selector: #selector(mainRun), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateEventStore),
            name: .EKEventStoreChanged,
            object: nil)
        
        
        
    }
    
    @objc func updateEventStore() {
        
        schoolAnalyser.analyseCalendar()
        
        
        
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
       
        mainRun()
        
        completionHandler(NCUpdateResult.newData)
        
        
        
    }
    
    @objc func mainRun() {
        
        self.current = self.cal.getCurrentEvent()
        
        if let currentEvent = self.current {
            
            self.countdownLabel.isHidden = false
            self.endsInLabel.font? = NSFont.systemFont(ofSize: self.eventFontSize, weight: NSFont.Weight.regular)
            self.countdownLabel.font = NSFont.monospacedDigitSystemFont(ofSize: CGFloat(50), weight: NSFont.Weight.light)
            self.countdownLabel.stringValue = self.timerStringGenerator.generateStatusItemString(event: currentEvent, justTimer: true)!
            self.endsInLabel.stringValue = "\(currentEvent.title) \(currentEvent.endsInString) in"
            
            if currentEvent.endDate.timeIntervalSinceNow < 1 {
                
                self.current = self.cal.getCurrentEvent()
                
            }
            
        } else {
            
            self.countdownLabel.isHidden = true
            //   self.endsInLabel.isHidden = true
            self.endsInLabel.stringValue = "No Events Are On"
            self.endsInLabel.font? = NSFont.systemFont(ofSize: self.noEventFontSize, weight: NSFont.Weight.regular)
            
            
        }
        
        
        
        
    }


}
