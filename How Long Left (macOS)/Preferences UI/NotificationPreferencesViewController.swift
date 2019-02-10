//
//  NotificationPreferencesViewController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 9/12/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import AppKit
import Preferences


final class NotificationPreferenceViewController: NSViewController, Preferenceable {
    let toolbarItemTitle = "Notifications"
    let toolbarItemIcon = NSImage(named: NSImage.preferencesGeneralName)!
    
    override var nibName: NSNib.Name? {
        return "NotificationPreferencesView"
}
    
    @IBOutlet weak var hotKeyOptionButton_Off: NSButton!
    @IBOutlet weak var hotKeyOptionButton_OptionW: NSButton!
    @IBOutlet weak var hotKeyOptionButton_CommandT: NSButton!
    
    @IBOutlet weak var milestoneOptionButton_10: NSButton!
    @IBOutlet weak var milestoneOptionButton_5: NSButton!
    @IBOutlet weak var milestoneOptionButton_1: NSButton!
    @IBOutlet weak var milestoneOptionButton_Ends: NSButton!
    
    @IBOutlet weak var percentageMIlestoneOptionButton_25: NSButton!
    @IBOutlet weak var percentageMilestoneOptionButton_50: NSButton!
    @IBOutlet weak var percentageMilestoneOptionButton_75: NSButton!
    
    override func viewWillAppear() {
        
        let milestones =  HLLDefaults.notifications.milestones
        let percentageMilestones = HLLDefaults.notifications.Percentagemilestones
        
        print(milestones)
        
        if milestones.contains(600) {
            
            if milestoneOptionButton_10.state == .off {
                milestoneOptionButton_10.setNextState()
            }
            
        } else {
            
            if milestoneOptionButton_10.state == .on {
                milestoneOptionButton_10.setNextState()
            }
            
        }
        
        if milestones.contains(300) {
            
            if milestoneOptionButton_5.state == .off {
                milestoneOptionButton_5.setNextState()
            }
            
        } else {
            
            if milestoneOptionButton_5.state == .on {
                milestoneOptionButton_5.setNextState()
            }
            
        }
        
        if milestones.contains(60) {
            
            if milestoneOptionButton_1.state == .off {
                milestoneOptionButton_1.setNextState()
            }
            
        } else {
            
            if milestoneOptionButton_1.state == .on {
                milestoneOptionButton_1.setNextState()
            }
            
        }
        
        if milestones.contains(0) {
            
            if milestoneOptionButton_Ends.state == .off {
                milestoneOptionButton_Ends.setNextState()
            }
            
        } else {
            
            if milestoneOptionButton_Ends.state == .on {
                milestoneOptionButton_Ends.setNextState()
            }
            
        }
        
        if percentageMilestones.contains(25) {
            
            if percentageMIlestoneOptionButton_25.state == .off {
                percentageMIlestoneOptionButton_25.setNextState()
            }
            
        } else {
            
            if percentageMIlestoneOptionButton_25.state == .on {
                percentageMIlestoneOptionButton_25.setNextState()
            }
            
        }
        
        if percentageMilestones.contains(50) {
            
            if percentageMilestoneOptionButton_50.state == .off {
                percentageMilestoneOptionButton_50.setNextState()
            }
            
        } else {
            
            if percentageMilestoneOptionButton_50.state == .on {
                percentageMilestoneOptionButton_50.setNextState()
            }
            
        }

        if percentageMilestones.contains(75) {
            
            if percentageMilestoneOptionButton_75.state == .off {
                percentageMilestoneOptionButton_75.setNextState()
            }
            
        } else {
            
            if percentageMilestoneOptionButton_75.state == .on {
                percentageMilestoneOptionButton_75.setNextState()
            }
            
        }

        
        
        
        switch HLLDefaults.notifications.hotkey {
            
        case .Off:
            hotKeyOptionButton_Off.setNextState()
        case .OptionW:
            hotKeyOptionButton_OptionW.setNextState()
        case .CommandT:
            hotKeyOptionButton_CommandT.setNextState()
        }
        
        
    }
    
    @IBAction func hotKeyChanged(_ sender: NSButton) {
        
        DispatchQueue.main.async {
        
        HLLDefaults.notifications.hotkey = HLLHotKeyOption(rawValue: Int(sender.identifier!.rawValue)!)!
            
        }
        
    }
    
    
    @IBAction func milestoneOptionClicked(_ sender: NSButton) {
        
        DispatchQueue.main.async {
        
        var milestoneArray = [Int]()
        var percentageMilestoneArray = [Int]()
        
            if self.milestoneOptionButton_10.state == .on {
            milestoneArray.append(600)
        }
        
            if self.milestoneOptionButton_5.state == .on {
            milestoneArray.append(300)
        }
        
            if self.milestoneOptionButton_1.state == .on {
            milestoneArray.append(60)
        }
        
            if self.milestoneOptionButton_Ends.state == .on {
            milestoneArray.append(0)
        }
            
        if self.percentageMIlestoneOptionButton_25.state == .on {
            percentageMilestoneArray.append(25)
        }
        
        if self.percentageMilestoneOptionButton_50.state == .on {
            percentageMilestoneArray.append(50)
        }
            
        if self.percentageMilestoneOptionButton_75.state == .on {
            percentageMilestoneArray.append(75)
        }

        
        HLLDefaults.notifications.milestones = milestoneArray
        HLLDefaults.notifications.Percentagemilestones = percentageMilestoneArray
        
        
    }
        
        
    
    }
    
}
