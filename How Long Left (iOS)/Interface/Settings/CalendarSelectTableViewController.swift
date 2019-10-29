//
//  SettingsCalendarSelectTableViewController.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 24/1/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import UIKit
import EventKit


class CalendarSelectTableViewController: UITableViewController, DefaultsTransferObserver {

    var allCalendars = [EKCalendar]()
    var enabledCalendars = [EKCalendar]()
    
    var selectAllState = true

    override func viewWillAppear(_ animated: Bool) {
        //self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       // self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        
        HLLDefaultsTransfer.shared.addTransferObserver(self)
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupData()
        
        self.clearsSelectionOnViewWillAppear = false
    }
    
   
  
    func setupData() {
        
        let enabledIdentifiers = HLLDefaults.calendar.enabledCalendars
        allCalendars = HLLEventSource.shared.getCalendars()
        enabledCalendars = allCalendars.filter { enabledIdentifiers.contains($0.calendarIdentifier) }
        
        if enabledCalendars.count == allCalendars.count {
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Deselect all", style: .plain, target: self, action: #selector (selectAllButtonTapped))
            selectAllState = false
            
        } else {
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select all", style: .plain, target: self, action: #selector (selectAllButtonTapped))
            selectAllState = true
            
        }
        
        tableView.reloadData()
        
        
        print("PoolC7")
        
    }
    
    @objc func selectAllButtonTapped() {
        
        DispatchQueue.main.async {
        
            if #available(iOS 10.0, *) {
                let lightImpactFeedbackGenerator = UISelectionFeedbackGenerator()
                lightImpactFeedbackGenerator.prepare()
                lightImpactFeedbackGenerator.selectionChanged()
            }
        
            if self.selectAllState == true {
            
                HLLDefaults.calendar.enabledCalendars = HLLEventSource.shared.getCalendarIDS()
                HLLDefaults.calendar.disabledCalendars.removeAll()
                
            } else {
                    
                HLLDefaults.calendar.enabledCalendars.removeAll()
                HLLDefaults.calendar.disabledCalendars = HLLEventSource.shared.getCalendarIDS()
            }
            
            self.setupData()
            HLLDefaultsTransfer.shared.userModifiedPrferences()
            
        }
        
    }
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCalendars.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Select Calendars to use"
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let calendarItem = allCalendars[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarItemCell", for: indexPath) as! SettingsCalendarItemCell
        cell.setCalendarItem(Calendar: calendarItem)
        
        if enabledCalendars.contains(calendarItem) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if #available(iOS 10.0, *) {
            let lightImpactFeedbackGenerator = UISelectionFeedbackGenerator()
            lightImpactFeedbackGenerator.prepare()
            lightImpactFeedbackGenerator.selectionChanged()
            
        }
        
        
        let selectedCalendar = self.allCalendars[indexPath.row].calendarIdentifier
        
        if !HLLDefaults.calendar.enabledCalendars.contains(selectedCalendar) {
            
            if !HLLDefaults.calendar.enabledCalendars.contains(selectedCalendar) {
                HLLDefaults.calendar.enabledCalendars.append(selectedCalendar)
            }
            
            if let index = HLLDefaults.calendar.disabledCalendars.firstIndex(of: selectedCalendar) {
                HLLDefaults.calendar.disabledCalendars.remove(at: index)
            }
            
            
        } else {
            
            print("Attempting to remove: \(HLLDefaults.calendar.disabledCalendars.count)")
            
            if let index = HLLDefaults.calendar.enabledCalendars.firstIndex(of: selectedCalendar) {
                HLLDefaults.calendar.enabledCalendars.remove(at: index)
            }
            
            if !HLLDefaults.calendar.disabledCalendars.contains(selectedCalendar) {
                HLLDefaults.calendar.disabledCalendars.append(selectedCalendar)
            }
           
        }
        
        setupData()
        HLLDefaultsTransfer.shared.userModifiedPrferences()
        
    }
    
    func defaultsUpdatedRemotely() {
        DispatchQueue.main.async {
            self.setupData()
        }
    }
 
}
