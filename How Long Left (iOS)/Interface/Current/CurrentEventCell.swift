//
//  CurrentEventCell.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 31/10/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import UIKit

class CurrentEventCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    
    @IBOutlet weak var progressBarTop: UIView!
    @IBOutlet weak var progressBarBottom: UIView!
    
    @IBOutlet weak var progressBarHeight: NSLayoutConstraint!
    
    var event: HLLEvent!
    
    let countdownStringGenerator = CountdownStringGenerator()
    
    func setup(with event: HLLEvent) {
        
        self.event = event
        
        updateCell()
        
        
    }
    
    func updateCell() {
        

            
            self.titleLabel.text = "\(self.event.title) \(self.event.countdownTypeString) in"
            self.countdownLabel.text = self.countdownStringGenerator.generatePositionalCountdown(event: self.event)
            
            self.progressBarTop.backgroundColor = self.event.uiColor.catalystAdjusted()
            self.progressBarBottom.backgroundColor = self.event.uiColor.catalystAdjusted().withAlphaComponent(0.25)
            
            let completion = self.event.completionFraction*100
            let totalHeight = self.progressBarBottom.frame.size.height
            self.progressBarHeight.constant = CGFloat(completion)/totalHeight
            
        
        
    }
    

}
