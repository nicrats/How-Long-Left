//
//  CustomNotificationPreferencesViewController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 9/7/19.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa
import Preferences

class CustomNotificationPreferencesViewController: NSViewController, PreferencePane, NSTableViewDataSource, NSTableViewDelegate {
    
    let preferencePaneIdentifier = PreferencePane.Identifier.notifications
    var preferencePaneTitle: String = "Notifications"
    
    let toolbarItemIcon = NSImage(named: "NotificationsIcon")!
        
        override var nibName: NSNib.Name? {
            return "CustomNotificationPreferencesView"
    }

    @IBOutlet weak var minutesRemainingTable: NSTableView!
    @IBOutlet weak var percentageCompleteTable: NSTableView!
    
    var timeRemainingTriggers = [Int]()
    var percentageCompleteTriggers = [Int]()
  
    var minutesAddCell: MinutesRemainingCell?
    
    override func viewDidLoad() {
        
        loadData()
        minutesRemainingTable.dataSource = self
        minutesRemainingTable.delegate = self
        minutesRemainingTable.reloadData()


    }
    
    func loadData() {
        
        self.timeRemainingTriggers = HLLDefaults.notifications.milestones
        self.percentageCompleteTriggers = HLLDefaults.notifications.Percentagemilestones
        
        
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        if tableView == minutesRemainingTable {
            return timeRemainingTriggers.count+1
        }
        
        if tableView == percentageCompleteTable {
            return percentageCompleteTriggers.count
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
         
        print("Col: \(tableColumn.hashValue)")
        
        if tableView == minutesRemainingTable {
        

            
         if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MinutesRemainingCell"), owner: nil) as? MinutesRemainingCell {
             
            if timeRemainingTriggers.indices.contains(row) {
            
            let minutes = timeRemainingTriggers[row]/60
            
                cell.setup(with: "\(minutes)", delegate: self)
            
            } else {
                
            DispatchQueue.main.async {

                cell.setup(with: "", delegate: self)
                cell.textField?.placeholderString = ""
                self.minutesAddCell = cell
                    

            }
                
            }

            print("Returning cell")
            return cell
             
         }
                
                
            }

         return nil
         
     }

    @IBAction func minutesRemainingControlClicked(_ sender: NSSegmentedControl) {
        
        if sender.selectedSegment == 0 {
            
            self.minutesAddCell?.textField?.selectText(nil)
            
            
        }
        
        if sender.selectedSegment == 1 {
            
            if timeRemainingTriggers.indices.contains(minutesRemainingTable.editedRow) {
            
            let selected = timeRemainingTriggers[minutesRemainingTable.editedRow]
           
            print("Selected was \(selected)")
            HLLDefaults.notifications.milestones.removeAll(where: {
                
                value in
                
                print("Checking: \(selected) against \(value)")
           
                if selected == value {
                    return true
                } else {
                    return false
                }
                
                
            })
            
            loadData()
            minutesRemainingTable.reloadData()
            
            }
            
            
        }
        
    }
    
    
    
    
}

extension CustomNotificationPreferencesViewController: NotificationTriggerTableHandler {
    
    func setMinutesRemainingTrigger(from: Int?, to: Int) {
        
        if let previous = from {
            HLLDefaults.notifications.milestones.removeAll(where: {$0 == previous})
        }
        
        HLLDefaults.notifications.milestones.append(to)
        
    }
    
    func setPercentageCompleteTrigger(from: Int?, to: Int) {
    }
    
}


class PercentCompleteCell: NSTableCellView {
    
    
    
    
}


class TableViewEditing: NSTableView {

    override func validateProposedFirstResponder(_ responder: NSResponder, for event: NSEvent?) -> Bool {
        return true
    }
    
}



protocol NotificationTriggerTableHandler {
    
    func setMinutesRemainingTrigger(from: Int?, to: Int)
    func setPercentageCompleteTrigger(from: Int?, to: Int)
    
}
