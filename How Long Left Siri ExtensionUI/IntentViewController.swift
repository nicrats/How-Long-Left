//
//  IntentViewController.swift
//  How Long Left Siri ExtensionUI
//
//  Created by Ryan Kontos on 28/1/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import IntentsUI


class IntentViewController: UIViewController, INUIHostedViewControlling {
    
    var currentEvent: HLLEvent?
    var timer = Timer()
    let timerStringGenerator = EventCountdownTimerStringGenerator()
    let cal = EventDataSource()
    var event: HLLEvent?
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var doneInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SchoolAnalyser.shared.analyseCalendar()
        // Do any additional setup after loading the view.
    }
        
    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        // Do configuration here, including preparing views and calculating a desired size for presentation.
        
    
        if let currentEvent = cal.getCurrentEvent() {
            
                self.event = currentEvent
            
            
            timer = Timer(fire: Date(), interval: 0.1, repeats: true, block: {_ in
                
                if let loopEvent = self.event {
                    
                    if loopEvent.endDate.timeIntervalSinceNow < 0 {
                        
                        self.timerLabel.isHidden = true
                        self.infoLabel.isHidden = true
                        self.doneInfoLabel.isHidden = false
                        self.doneInfoLabel.text = "\(loopEvent.title) is done"
                        
                    } else {
                      
                        self.timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: self.timerLabel.font.pointSize, weight: .thin)
                        self.timerLabel.isHidden = false
                       self.infoLabel.isHidden = false
                        self.doneInfoLabel.isHidden = true
                        self.timerLabel.text = self.timerStringGenerator.generateStringFor(event: loopEvent)
                        self.infoLabel.text = "\(loopEvent.title) \(loopEvent.endsInString) in"
                        
                        
                    }
                    
                    
                    
                    
                    
                }
                
            })
            
            RunLoop.main.add(timer, forMode: .common)
            
            
            
        } else {
            
            self.timerLabel.isHidden = true
            self.infoLabel.isHidden = true
            self.doneInfoLabel.isHidden = false
            self.doneInfoLabel.text = "No events are on"
            
        }
        
        
        completion(true, parameters, self.desiredSize)
    }
    
    
    
    var desiredSize: CGSize {
        return CGSize(width: 282, height: 105)
    }
    
}
