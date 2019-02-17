//
//  MilestoneSettingsTableViewController.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 7/2/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import UIKit

class MilestoneSettingsTableViewController: UITableViewController {
    
    let scheduler = MilestoneNotificationScheduler()
    let defaults = HLLDefaults.defaults
    var setMilestones = [Int]()
    static let defaultMilestones = [600, 300, 60, 0]
    var selectAllState = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMilestones = HLLDefaults.notifications.milestones
        
        self.clearsSelectionOnViewWillAppear = false
    }
    
    
    
    @objc func selectAllButtonTapped() {
        
        if #available(iOS 10.0, *) {
            let lightImpactFeedbackGenerator = UISelectionFeedbackGenerator()
            lightImpactFeedbackGenerator.prepare()
            lightImpactFeedbackGenerator.selectionChanged()
            
        }
        
        setMilestones.removeAll()
        
        if selectAllState == true {
            
            for milestone in MilestoneSettingsTableViewController.defaultMilestones {
                
                setMilestones.append(milestone)
                
            }
            
        }
        
        HLLDefaults.notifications.milestones = setMilestones
        tableView.reloadData()
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        if UIApplication.shared.backgroundRefreshStatus != .available {
            
           return "Background app refresh is currently disabled. You will not receive these countdown notifications until you enable it in Settings."
            
        } else if ProcessInfo.processInfo.isLowPowerModeEnabled == true {
            
            return "Countdown notifications may be unreliable or outdated in Low Power Mode."
            
        }
        
        return nil
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Send a notification when an event"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        
        if setMilestones.count == MilestoneSettingsTableViewController.defaultMilestones.count {
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Deselect all", style: .plain, target: self, action: #selector (selectAllButtonTapped))
            selectAllState = false
            
            
        } else {
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select all", style: .plain, target: self, action: #selector (selectAllButtonTapped))
            selectAllState = true
            
        }
        
        scheduler.scheduleNotificationsForUpcomingEvents()
        //  WatchSessionManager.sharedManager.startSession()
        
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return MilestoneSettingsTableViewController.defaultMilestones.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let milestone = MilestoneSettingsTableViewController.defaultMilestones[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MilestoneItemCell", for: indexPath) as! MilestoneSettingsCell
        cell.setupCell(milestoneSeconds: milestone)
        
        if setMilestones.contains(milestone) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      //  print("\(calendars[indexPath.row].title) selected")
        
        if #available(iOS 10.0, *) {
            let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            lightImpactFeedbackGenerator.prepare()
            lightImpactFeedbackGenerator.impactOccurred()
            
        }
        
        
        let selectedMilestone = MilestoneSettingsTableViewController.defaultMilestones[indexPath.row]
        
        if setMilestones.contains(selectedMilestone) {
            
            if let index = setMilestones.firstIndex(of: selectedMilestone) {
                
                setMilestones.remove(at: index)
                
            }
            
            
        } else {
            
            setMilestones.append(selectedMilestone)
            
        }
        
        HLLDefaults.notifications.milestones = setMilestones
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
            
            tableView.reloadData()
            
        })
        
        
        
    }
    
}
