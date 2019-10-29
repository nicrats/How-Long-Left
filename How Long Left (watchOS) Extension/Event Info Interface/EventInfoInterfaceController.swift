//
//  EventInfoInterfaceController.swift
//  How Long Left (watchOS) Extension
//
//  Created by Ryan Kontos on 28/9/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import WatchKit
import Foundation


class EventInfoInterfaceController: WKInterfaceController {

    var event: HLLEvent!
    var infoSource: HLLEventInfoItemGenerator!
    var timer: Timer?
    
    @IBOutlet weak var countdownTable: WKInterfaceTable!
    @IBOutlet weak var infoTable: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        countdownTable.setHidden(true)
        event = (context as! HLLEvent)
        self.setTitle(event.title)
        timer = Timer(timeInterval: 1, target: self, selector: #selector(updateRows), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        updateTables()
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updateTables() {
        
        infoSource = HLLEventInfoItemGenerator(event)
        updateCountdownTable()
        updateInfoTable()
        
    }
    
    func updateCountdownTable() {
        
       // countdownTable.setNumberOfRows(1, withRowType: "CountdownCell")
        
    }
    
    func updateInfoTable() {
        
        let items = infoSource.getInfoItems(for: [.countdown, .completion, .location, .period, .start, .end, .elapsed, .duration, .calendar, .nextOccurence])
        
        infoTable.setNumberOfRows(items.count, withRowType: "InfoCell")
        
        for (index, item) in items.enumerated() {
            
            let row = infoTable.rowController(at: index) as! EventInfoTableRow
            row.setup(with: item)
            
            print("Setting up \(item.type)")
            
        }
        
    }
    
    @objc func updateRows() {
        
        DispatchQueue.global(qos: .default).async {
        
        let previousEvent = self.event
            
        if let event = self.event.refresh() {
                
            // Matching event still exists
            
            if event != previousEvent {
                
                // ...But has been modified
                
                DispatchQueue.main.async {
                    self.updateTables()
                }
            }
                
        } else {
            
            // Matching event no longer exists
            
            DispatchQueue.main.async {
                self.pop()
            }
            
        }
            
        self.infoSource = HLLEventInfoItemGenerator(self.event)
        
        

                
                let count = self.infoTable.numberOfRows
            
        for index in 0..<count {
            
            if let row = self.infoTable.rowController(at: index) as? EventInfoTableRow {
            
                if let info = self.infoSource.getInfoItem(for: row.infoItem.type) {
                
                if row.infoItem != info {
                    DispatchQueue.main.async {
                    row.setup(with: info)
                    }
                }
                
            } else {
                
                    DispatchQueue.main.async {
                    self.updateTables()
                    }
                
                
            }
                
            }
            
                }
                
        
            
        }
        
        
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        if table == self.infoTable {
            
            let row = table.rowController(at: rowIndex) as! EventInfoTableRow
            
            if row.infoItem.type == .nextOccurence, let nextOccur = event.followingOccurence {
                
               pushController(withName: "EventInfoView", context: nextOccur)
                
            }
            
        }
        
    }

}
