//
//  TodayViewController.swift
//  WIdget (iOS)
//
//  Created by Ryan Kontos on 8/10/19.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import UIKit
import NotificationCenter


class TodayViewController: UIViewController, NCWidgetProviding, EventPoolUpdateObserver {
    
    @IBOutlet weak var colourBar: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var noEventsLabel: UILabel!
    
    var timer: Timer!
    var event: HLLEvent?
    
    var hasLoaded = false
    
    let countdownStringGenerator = CountdownStringGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.isHidden = true
        self.colourBar.layer.cornerRadius = 2.0
        self.colourBar.layer.masksToBounds = true
        self.colourBar.isHidden = true
        self.titleLabel.isHidden = true
        self.timerLabel.isHidden = true
        self.noEventsLabel.isHidden = true
        
        HLLEventSource.shared.updateEventPool()
        HLLEventSource.shared.addEventPoolObserver(self)
        eventPoolUpdated()
        hasLoaded = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if hasLoaded == true {
        DispatchQueue.global(qos: .default).async {
            HLLEventSource.shared.updateEventPool()
        }
        }
    }
    
    @objc func updateTimer() {
        
        DispatchQueue.main.async {
        
            if let unwrappedEvent = self.event {
                    
                
                
                self.colourBar.isHidden = false
                self.titleLabel.isHidden = false
                self.timerLabel.isHidden = false
                self.noEventsLabel.isHidden = true
                    
                UIView.animate(withDuration: 0.25, animations: {
                    
                    self.view.isHidden = false
                    
                })
                
                
            self.titleLabel.text = "\(unwrappedEvent.title) \(unwrappedEvent.countdownTypeString) in"
            
            let countdownString = self.countdownStringGenerator.generatePositionalCountdown(event: unwrappedEvent)
                self.timerLabel.text = countdownString
            
            if let calendar = unwrappedEvent.associatedCalendar {
                
                self.colourBar.backgroundColor = UIColor(cgColor: calendar.cgColor)
                
            }
            
            
            } else if HLLEventSource.shared.neverUpdatedEventPool == false {
            
                
                    
                    self.colourBar.isHidden = true
                    self.titleLabel.isHidden = true
                    self.timerLabel.isHidden = true
                    self.noEventsLabel.isHidden = false
                
                UIView.animate(withDuration: 0.25, animations: {
                    
                    self.view.isHidden = false
                    
                })

        }
            
        }
        
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        updateTimer()
        completionHandler(NCUpdateResult.newData)
    }
    
    func eventPoolUpdated() {
    
        self.event = HLLEventSource.shared.getTimeline().filter { event in
            
            if HLLDefaults.appExtensions.showUpcoming {
                return true
            }
            
            if event.completionStatus != .Upcoming {
                return true
            } else {
                return false
            }
            
        }.first
        
        
        updateTimer()
        
        timer = Timer(timeInterval: 0.5, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        
        let url = URL(string: "howlongleft://widgetlaunch")!
        
      
            
        self.extensionContext?.open(url, completionHandler: nil)

    }
    
}
