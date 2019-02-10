//
//  SettingsCalendarSelectTableViewController.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 24/1/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import UIKit
import EventKit


class SettingsCalendarSelectTableViewController: UITableViewController {
    
    let calendar = EventDataSource.shared
    let defaults = UserDefaults(suiteName: "group.com.ryankontos.How-Long-Left")!
    var setCalendars = [String]()
    var calendars = [EKCalendar]()
    var selectAllState = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendars = calendar.getCalendars()
        calendars.sort { $0.title < $1.title }
        
        if let storedIDS = defaults.stringArray(forKey: "setCalendars") {
            
            for id in storedIDS {
                
                for calendar in calendars {
                    
                    if calendar.calendarIdentifier == id {
                        
                        setCalendars.append(calendar.calendarIdentifier)
                        
                    }
                    
                }
                
                
            }
            
            
        } else {
            
        var idArray = [String]()
            
            for calendar in calendars {
                
                idArray.append(calendar.calendarIdentifier)
                
            }
            
            
            defaults.set(idArray, forKey: "setCalendars")
            
        }
        
        self.clearsSelectionOnViewWillAppear = false
    }
  
    
    
    @objc func selectAllButtonTapped() {
        
        if #available(iOS 10.0, *) {
            let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            lightImpactFeedbackGenerator.prepare()
            lightImpactFeedbackGenerator.impactOccurred()
            
        }
        
        setCalendars.removeAll()
        
        if selectAllState == true {
            
            for calendar in calendars {
                
                setCalendars.append(calendar.calendarIdentifier)
                
            }
            
        }
        
        defaults.set(setCalendars, forKey: "setCalendars")
        tableView.reloadData()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        DispatchQueue.main.async {
          SchoolAnalyser.shared.analyseCalendar()
        }
        
        if setCalendars.count == calendars.count {
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Deselect all", style: .plain, target: self, action: #selector (selectAllButtonTapped))
            selectAllState = false
            
            
        } else {
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select all", style: .plain, target: self, action: #selector (selectAllButtonTapped))
            defaults.set(true, forKey: "userDidTurnOffAllCalendars")
            selectAllState = true
            
        }
        
        DispatchQueue.main.async {
            
            WatchSessionManager.sharedManager.updateContext(userInfo: ["SelectedCalendars" : self.setCalendars])
            
        }
        
        
      //  WatchSessionManager.sharedManager.startSession()
       
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return calendars.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let calendarItem = calendars[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarItemCell", for: indexPath) as! SettingsCalendarItemCell
        cell.setCalendarItem(Calendar: calendarItem)
        
        if setCalendars.contains(calendarItem.calendarIdentifier) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(calendars[indexPath.row].title) selected")
        
        if #available(iOS 10.0, *) {
            let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            lightImpactFeedbackGenerator.prepare()
            lightImpactFeedbackGenerator.impactOccurred()
            
        }
        
        
        let selectedCal = calendars[indexPath.row]
        
        if setCalendars.contains(selectedCal.calendarIdentifier) {
            
            
            if let index = setCalendars.firstIndex(of: selectedCal.calendarIdentifier) {
                
                setCalendars.remove(at: index)
                
            }
            
            
            
        } else {
            
            setCalendars.append(selectedCal.calendarIdentifier)
            
        }
        
        var idArray = [String]()
        
        for calendar in setCalendars {
            
            idArray.append(calendar)
            
        }
        
        
        defaults.set(idArray, forKey: "setCalendars")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
            
           tableView.reloadData()
           
        })
        
        DispatchQueue.main.async {
            
            WatchSessionManager.sharedManager.updateContext(userInfo: ["SelectedCalendars" : self.setCalendars])
            
        }
       
        
    }
    
    func matchIDToEKCalendar(calID: String) -> EKCalendar? {
        
        for calendar in calendars {
            
            if calendar.calendarIdentifier == calID {
                
                return calendar
                
            }
            
        }
        
        return nil
        
    }
 
}
