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
    var cal = EventDataSource()
    var current: HLLEvent?
    
    @IBOutlet weak var label: NSTextField!
    
    var newNibName: String?
    
    override var nibName: NSNib.Name? {
        
        if let new = newNibName {
            
            return NSNib.Name(new)
            
        } else {
            
             return NSNib.Name("TodayViewController")
            
        }
        
       
    }
    
    
    override func viewDidLoad() {
        
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
    
    func changeView() {
        
        
        DispatchQueue.main.async {
            
            if self.newNibName != "NoEventOn" {
                
                
                self.newNibName = "NoEventOn"
                self.loadView()
                
                
            }
        
    }
        
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
       
        mainRun()
        completionHandler(NCUpdateResult.newData)
        
        
    }
    
    @objc func mainRun() {
        
        self.current = self.cal.getCurrentEvent()
        
       changeView()
            
            
        }
    


}
