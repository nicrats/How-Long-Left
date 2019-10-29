//
//  MagdaleneTableViewController.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 19/10/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import UIKit
import Foundation

class MagdaleneTableViewController: UITableViewController, SwitchCellDelegate, DefaultsTransferObserver {
    
    override func viewDidLoad() {
        HLLDefaultsTransfer.shared.addTransferObserver(self)
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        tableView.reloadData()
        
    }

    // MARK: - Table view data source

    func loadTable() {
        
        tableView.reloadData()

        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        if SchoolAnalyser.schoolMode != .Magdalene {
            return 1
        } else {
            
            if let session = WatchSessionManager.sharedManager.validSession, session.isPaired {
                return 3
            } else {
                return 2
            }
            
           
        }

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        } else if section == 1 {
            return 4
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        tableView.register(UINib(nibName: "SwitchCell", bundle: nil), forCellReuseIdentifier: "SwitchCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchCell
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                
                cell.label = "Magdalene Mode"
                cell.cellIdentifier = "Main"
                cell.getAction = { return !HLLDefaults.magdalene.manuallyDisabled }
                cell.setAction = { value in
                    HLLDefaults.magdalene.manuallyDisabled = !value
                
                    DispatchQueue.global(qos: .default).async {
                    HLLEventSource.shared.updateEventPool()
                    }
                }
                
                
            }
            
            
        } else if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                
                cell.label = "Add Lunch & Recess"
                cell.getAction = { return HLLDefaults.magdalene.showBreaks }
                cell.setAction = { value in
                    HLLDefaults.magdalene.showBreaks = value
                    HLLEventSource.shared.updateEventPool()
                }
                
                
            }
            
            if indexPath.row == 1 {
                
                cell.label = "Show Terms"
                cell.getAction = { return HLLDefaults.magdalene.doTerm }
                cell.setAction = { value in
                    HLLDefaults.magdalene.doTerm = value
                    HLLEventSource.shared.updateEventPool()
                }
                
                
            }
            
            if indexPath.row == 2 {
                
                cell.label = "Show School Holidays"
                cell.getAction = { return HLLDefaults.magdalene.doHolidays }
                cell.setAction = { value in
                    HLLDefaults.magdalene.doHolidays = value
                    HLLEventSource.shared.updateEventPool()
                }
                
            }
            
            if indexPath.row == 3 {
                
                cell.label = "Show Sport as \"Study\""
                cell.getAction = { return HLLDefaults.magdalene.showSportAsStudy }
                cell.setAction = { value in
                    HLLDefaults.magdalene.showSportAsStudy = value
                    HLLEventSource.shared.updateEventPool()
                }
                
            }
            
            
        } else {
            
            if indexPath.row == 0 {
                
                cell.label = "Don't List Breaks and Homeroom"
                cell.getAction = { return HLLDefaults.magdalene.hideExtras }
                cell.setAction = { value in
                    HLLDefaults.magdalene.hideExtras = value
                }
                
            }
            
        }
        
        cell.delegate = self
    
       
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        if section == 0 {
            
            return "Enable features useful for Magdalene users, including subject name adjustments, bell-accurate countdown times, Lunch & Recess events, current Term/School Holidays countdown, Rename, and more."
            
        }
        
        return nil
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 2 {
            
            return "Apple Watch Only"
            
        }
        
        return nil
        
    }

    func switchCellWasToggled(_ sender: SwitchCell) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10, execute: {
            
            self.tableView.reloadData()
            
            HLLDefaultsTransfer.shared.userModifiedPrferences()
        })
        
       
        
    }
    
    func defaultsUpdatedRemotely() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}
