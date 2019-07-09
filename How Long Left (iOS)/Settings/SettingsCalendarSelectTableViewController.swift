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
    
    let calendar = EventDataSource()
    let defaults = HLLDefaults.defaults
    var setCalendars = [String]()
    var calendars = [EKCalendar]()
    var selectAllState = true
    let schoolAnalyser = SchoolAnalyser()

    override func viewWillAppear(_ animated: Bool) {
        //self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       // self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        calendars = calendar.getCalendars()
        navigationController?.navigationBar.barStyle = AppTheme.current.barStyle
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: AppTheme.current.textColor]
        navigationController?.navigationBar.isTranslucent = AppTheme.current.translucentBars
        tableView.backgroundColor = AppTheme.current.groupedTableViewBackgroundColor
        tabBarController?.tabBar.isTranslucent = AppTheme.current.translucentBars
        tabBarController?.tabBar.barStyle = AppTheme.current.barStyle
        tableView.separatorColor = AppTheme.current.tableCellSeperatorColor
        
        tableView.reloadData()
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
            let lightImpactFeedbackGenerator = UISelectionFeedbackGenerator()
            lightImpactFeedbackGenerator.prepare()
            lightImpactFeedbackGenerator.selectionChanged()
            
        }
        
        setCalendars.removeAll()
        
        if selectAllState == true {
            
            for calendar in calendars {
                
                setCalendars.append(calendar.calendarIdentifier)
                
            }
            
        }
        
        var disabledArray = [String]()
        
        for cal in calendars {
            
            
            
            if setCalendars.contains(cal.calendarIdentifier) == false {
                
                disabledArray.append(cal.calendarIdentifier)
                
            }
            
        }
        
        HLLDefaults.calendar.disabledCalendars = [String]()
        
        
        HLLDefaults.calendar.disabledCalendars = disabledArray
        
        DispatchQueue.main.async {
            
            self.defaultsSync.syncDefaultsToWatch()
            
            
        }
        
        defaults.set(setCalendars, forKey: "setCalendars")
        tableView.reloadData()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        DispatchQueue.main.async {
            self.schoolAnalyser.analyseCalendar()
        }
        
            
        
        if setCalendars.count == calendars.count {
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Deselect all", style: .plain, target: self, action: #selector (selectAllButtonTapped))
            selectAllState = false
            
            
        } else {
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select all", style: .plain, target: self, action: #selector (selectAllButtonTapped))
            selectAllState = true
            
            
        }
        
        
        DispatchQueue.main.async {
        
        self.defaultsSync.syncDefaultsToWatch()
            
        }
        
      //  WatchSessionManager.sharedManager.startSession()
       
        
        return 1
    }
    
    let defaultsSync = DefaultsSync()

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return calendars.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Select Calendars to use"
        
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
        
        
        
        
        //print("\(calendars[indexPath.row].title) selected")
        
        if #available(iOS 10.0, *) {
            let lightImpactFeedbackGenerator = UISelectionFeedbackGenerator()
            lightImpactFeedbackGenerator.prepare()
            lightImpactFeedbackGenerator.selectionChanged()
            
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
        
        var disabledArray = [String]()
        
        for cal in calendars {
            
            
            
            if setCalendars.contains(cal.calendarIdentifier) == false {
                
                disabledArray.append(cal.calendarIdentifier)
                
            }
            
        }
        
        HLLDefaults.calendar.disabledCalendars = disabledArray
        
        DispatchQueue.main.async {
            
            self.defaultsSync.syncDefaultsToWatch()
            
            
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
