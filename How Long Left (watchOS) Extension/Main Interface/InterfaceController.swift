//
//  MainInterfaceController.swift
//  How Long Left (watchOS) Extension
//
//  Created by Ryan Kontos on 21/9/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController, EventPoolUpdateObserver, DefaultsTransferObserver {
    
    @IBOutlet weak var eventsTable: WKInterfaceTable!
    @IBOutlet weak var noTableLabel: WKInterfaceLabel!
    
    var events = [HLLEvent]()
    
    var rowUpdateTimer: Timer?
    var doneInitalLaunch = false
    
    let primaryRowType = "PrimaryEventRow"
    let currentRowType = "CurrentEventRow"
    let upcomingRowType = "UpcomingEventRow"
    
    let hideablePeriods = ["H", "R", "L"]
    
    let countdownStringGenerator = CountdownStringGenerator()
    
    override func awake(withContext context: Any?) {
        
        HLLEventSource.shared.addEventPoolObserver(self)
        HLLDefaultsTransfer.shared.addTransferObserver(self)
        self.updateRows()
        
        self.rowUpdateTimer = Timer(timeInterval: 0.5, target: self, selector: #selector(self.asyncUpdateRows), userInfo: nil, repeats: true)
        RunLoop.main.add(self.rowUpdateTimer!, forMode: .common)
        
            
        
        
    }

    override func willActivate() {
        
        //self.updateRows(async: false)
        if doneInitalLaunch == false {
        
            updateTable()
            doneInitalLaunch = true
            
        } else {
            
            
            DispatchQueue.global(qos: .default).async {
                self.updateRows()
                self.updateTable()
                HLLEventSource.shared.updateEventPool()
            }
            
        }
        
        setupMenuItems()
        
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
    func updateTable() {

        var fetchedEvents = HLLEventSource.shared.getCurrentAndUpcomingTodayOrdered()
        
        if HLLDefaults.magdalene.hideExtras {
            
            for (index, event) in fetchedEvents.enumerated() {
                
                if let period = event.period, hideablePeriods.contains(period), index != 0, event.completionStatus != .Current {
                        
                    fetchedEvents.removeAll { $0 == event }
                    
                }
                
            }
            
        }
        
        if fetchedEvents.isEmpty == false {

            self.setNoTableText(nil)
            
        } else {
            
            if HLLEventSource.shared.access == .Denied {
                self.setNoTableText("No Calendar Access")
            } else {
                self.setNoTableText("No Events Found")
            }
            
            return
            
        }
        
        if fetchedEvents != self.events {
            
            self.events = fetchedEvents
            
            if fetchedEvents.count == 1 {
                self.eventsTable.setVerticalAlignment(.center)
            } else {
                self.eventsTable.setVerticalAlignment(.top)
            }
            
            var rowTypes = [String]()
            
            for (index, event) in fetchedEvents.enumerated() {
                
                if index == 0 {
                    
                    rowTypes.append(self.primaryRowType)
                    
                    if event.completionStatus == .Upcoming {
                        
                        rowTypes.append(self.upcomingRowType)
                        fetchedEvents.insert(event, at: 0)
                        
                    }
                    
                } else if event.completionStatus == .Current {
                        
                    rowTypes.append(self.currentRowType)
                        
                } else {
                        
                    rowTypes.append(self.upcomingRowType)
                        
                }
            }
            
            self.eventsTable.setRowTypes(rowTypes)
            
            for (index, event) in fetchedEvents.enumerated() {
                  
                let row = self.eventsTable.rowController(at: index) as! EventRow
                row.setup(event: event)
        
                let countdownText = self.countdownStringGenerator.generatePositionalCountdown(event: event)
                row.updateTimer(countdownText)
                
                
            }
        }
            
        
            
        
    }
    
    @objc func asyncUpdateRows() {
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.updateRows()
        }
        
    }
    
    @objc func updateRows(async: Bool = true) {
        
        let count = self.eventsTable.numberOfRows
        
            for index in 0..<count {
            
                if let row = self.eventsTable.rowController(at: index) as? EventRow {
                
                    if let event = row.event {
    
                        let countdownText = self.countdownStringGenerator.generatePositionalCountdown(event: event)
                        
                        if async {
                            
                            DispatchQueue.main.async {
                                row.updateTimer(countdownText)
                            }
                            
                        } else {
                            
                            row.updateTimer(countdownText)
                            
                        }
                        
                        if event.completionStatus != row.rowCompletionStatus {
                            
                            DispatchQueue.main.async {
                                self.updateTable()
                            }
                            
                        }
                    }
                }
            }
        
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
            if table == self.eventsTable {
            
            if let row = table.rowController(at: rowIndex) as? EventRow {
                
                let event = row.event
                self.pushController(withName: "EventInfoView", context: event)
            }
           
            
        }
            
    }
    
    func setNoTableText(_ text: String?) {
        
        let state = text == nil
        noTableLabel.setText(text)
        noTableLabel.setHidden(state)
        eventsTable.setHidden(!state)
        
    }
    
    func eventPoolUpdated() {
        print("WDB: Eventpool changed called")
        DispatchQueue.main.async {
            self.updateTable()
        }
    }
    
    func defaultsUpdatedRemotely() {
        DispatchQueue.main.async {
            self.updateTable()
        }
    }
    
    func setupMenuItems() {
        
        self.clearAllMenuItems()
        self.addMenuItem(with: UIImage(), title: "Settings", action: #selector(settingsButtonPressed))
        
        /*if HLLDefaults.general.selectedEventID != nil {
            
            self.addMenuItem(with: UIImage(), title: "Clear Selection", action: #selector(clearSelection))
            
        }*/
        
    }
    
    @objc func clearSelection() {
        
        HLLDefaults.general.selectedEventID = nil
        setupMenuItems()
        ComplicationUpdateHandler.shared.updateComplication(force: true)
        HLLDefaultsTransfer.shared.userModifiedPrferences()
        
    }
 
    @objc func settingsButtonPressed() {
        
        self.pushController(withName: "SettingsMain", context: nil)
        
    }
    
    @objc func getPreferences() {
        

        
    }
    

}
