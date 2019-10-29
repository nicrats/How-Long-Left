//
//  PrimaryEventRowController.swift
//  How Long Left (watchOS) Extension
//
//  Created by Ryan Kontos on 22/9/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import WatchKit

class PrimaryEventRowController: NSObject, EventRow {
    
    @IBOutlet weak var titleLabel: WKInterfaceLabel?
    @IBOutlet weak var countdownLabel: WKInterfaceLabel?
    @IBOutlet weak var countdownTypeLabel: WKInterfaceLabel?
    @IBOutlet weak var infoLabel: WKInterfaceLabel?
    
    var event: HLLEvent!
    var rowCompletionStatus: EventCompletionStatus!
    
    let percentageCalculator = PercentageCalculator()
    
    func setup(event: HLLEvent) {
        
        self.event = event
        self.rowCompletionStatus = event.completionStatus
        
    }
    
    func updateTimer(_ string: String) {
        
            titleLabel?.setText(event.title)
            countdownTypeLabel?.setText("\(event.countdownTypeString) in")
               
            if let colour = event.associatedCalendar?.cgColor {
                countdownLabel?.setTextColor(UIColor(cgColor: colour))
            }
               
            if let infoLabel = infoLabel {
                  
                infoLabel.setHidden(false)
               
            if event.completionStatus == .Upcoming {
                   
                infoLabel.setText(event.compactInfoText)
                   
            } else {
                   
                if let percent = percentageCalculator.calculatePercentageDone(event: event, ignoreDefaults: true) {
                    
                    var infoString = "(\(percent) Done)"
                    
                    if let location = event.location {
                        
                        let shortLocation = location.truncated(limit: 15, position: .tail, leader: "...")
                        
                        infoString = "\(shortLocation) | \(percent)"
                        
                    }
                    
                    infoLabel.setText(infoString)
                    infoLabel.setHidden(false)
                    
                } else {
                    
                    infoLabel.setHidden(true)
                    
                    
                }
                   
                }
            }
        
            if let label = self.countdownLabel {
            
                var size = 38
                
                switch WKInterfaceDevice.currentResolution() {
                case .Watch38mm:
                    size = 36
                case .Watch44mm:
                    size = 40
                case .Watch40mm:
                    break
                case .Watch42mm:
                    break
                case .Unknown:
                    break
                }
                
                let monospacedFont = UIFont.monospacedDigitSystemFont(ofSize: CGFloat(size), weight: UIFont.Weight.semibold)
                let monospacedString = NSAttributedString(string: string, attributes: [NSAttributedString.Key.font: monospacedFont])

                label.setAttributedText(monospacedString)
            
        }
        
    }
    
}
