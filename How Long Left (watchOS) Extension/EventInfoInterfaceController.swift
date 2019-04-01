//
//  EventInfoInterfaceController.swift
//  How Long Left (watchOS) Extension
//
//  Created by Ryan Kontos on 19/2/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import WatchKit
import Foundation


class EventInfoInterfaceController: WKInterfaceController, EventTableRowDelegate {
    
    @IBOutlet var eventTitleLabel: WKInterfaceLabel!
    @IBOutlet var eventTypeLabel: WKInterfaceLabel!
    @IBOutlet var table: WKInterfaceTable!
    
    var nextOccurFinder = EventNextOccurenceFinder()
    var dataSource = EventDataSource()
    var percentageCalc = PercentageCalculator()
    var UIevent: HLLEvent?
    var foundNextOccur: HLLEvent?
    var state: EventCompletionStatus?
    //var timer = RepeatingTimer(time: 1.0)
    var timer: Timer!
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        
        if segueIdentifier == "mapSegue" {
            return UIevent
            
        }
        
        return nil
        
    }
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        
        
        if let safeEvent = context as? (HLLEvent, HLLEvent?) {
            
            UIevent = safeEvent.0
            state = safeEvent.0.completionStatus
            foundNextOccur = safeEvent.1
            
            DispatchQueue.main.async {
                
                if let mapEvent = self.UIevent {
                    
                    if let location = mapEvent.fullLocation {
                        
                        
                        let geocoder = CLGeocoder()
                        geocoder.geocodeAddressString(location) {
                            placemarks, error in
                            if let loc = placemarks?.first?.location {
                                self.UIevent?.CLLocation = loc
                                // self.pushController(withName: "locationMapView", context: mapEvent)
                                
                            }
                            
                            
                        }
                        
                    }
                    
                    
                    
                }

                
            }
            
            
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(self.checkState), userInfo: nil, repeats: true)
        
        updateView(event: UIevent)
        
    }
    
    @objc func checkState() {
        
        
        if let safeState = self.state, let event = self.UIevent {
            
            print("\(safeState)")
            print("\(event.completionStatus)")
            
            if safeState != event.completionStatus {
                DispatchQueue.main.async {
                    self.popToRootController()
                    
                }
                
            }
            
        }
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        
        
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
      //  timer.suspend()
        super.didDeactivate()
    }
    
    func updateView(event inputEvent: HLLEvent?) {
        
        if let event = inputEvent {
            
            if event.completionStatus == .InProgress {
                
                eventTypeLabel.setText("On Now:")
                
            } else {
                
                eventTypeLabel.setText("Upcoming Event:")
                
            }
            
            eventTitleLabel.setText(event.title)
            eventTitleLabel.setTextColor(UIColor(cgColor: dataSource.calendarFromID(event.calendarID)?.cgColor ?? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)))
            
            var rowIDS = [InfoRowIdentifier]()
            
            rowIDS.append(.TimerRow)
            
            if event.completionStatus == .InProgress {
                
                rowIDS.append(.PercentRow)
                
            }
            
            if event.location != nil {
                
                rowIDS.append(.LocationRow)
                
            }
            
            if event.startDate.midnight() != Date().midnight() {
                
                rowIDS.append(.DateRow)
                
            }
            
            rowIDS.append(.TimesRow)
            
            if event.magdalenePeriod != nil {
                
                rowIDS.append(.PeriodRow)
                
            }
            
            rowIDS.append(.DurationRow)
            
            if event.completionStatus == .InProgress {
                
                if foundNextOccur != nil {
                    
                    rowIDS.append(.NextOccurRow)
                    
                }
                
            }
            
            var rawValues = [String]()
            for item in rowIDS { rawValues.append(item.rawValue) }
            
            table.setRowTypes(rawValues)
            
            for (index, rowID) in rowIDS.enumerated() {
                
                switch rowID {
                    
                case .TimerRow:
                    
                    let row = table.rowController(at: index) as! CountdownRow
                    
                    
                    if event.completionStatus == .NotStarted {
                        row.countdownTypeLabel.setText("Starts in:")
                        row.countdownLabel.setDate(event.startDate.addingTimeInterval(1))
                        
                    } else {
                        
                        row.countdownTypeLabel.setText("Ends in:")
                        row.countdownLabel.setDate(event.endDate.addingTimeInterval(1))
                        
                    }
                    
                    
                    row.countdownLabel.start()
                    
                case .PercentRow:
                    
                    let row = table.rowController(at: index) as! PercentRow
                    row.event = event
                    row.calcPercent()
                    row.start(event: event)
                    
                case .LocationRow:
                    
                    let row = table.rowController(at: index) as! LocationRow
                    
                    row.setDelegate(to: self)
                    
                    if let loc = event.location {
                        
                        row.locationLabel.setText(loc)
                        
                        
                    }
                    
                case .DateRow:
                    
                    let row = table.rowController(at: index) as! DateRow
                    
                    row.dateInfoLabel.setText("\(event.startDate.formattedDate())")
                    
                    
                case .TimesRow:
                    
                    let row = table.rowController(at: index) as! TimeRow
                    
                    row.timeLabel.setText("\(event.startDate.formattedTime()) - \(event.endDate.formattedTime())")
                    
                case .PeriodRow:
                    
                    let row = table.rowController(at: index) as! PeriodRow
                    
                    if let period = event.magdalenePeriod {
                        
                        row.periodLabel.setText("\(period)")
                        
                    }
                    
                    
                case .DurationRow:
                    
                    let row = table.rowController(at: index) as! DurationRow
                    
                    let durationMin = event.duration/60
                    
                    row.durationLabel.setText("\(Int(durationMin)) minutes")
                    
                    
                case .NextOccurRow:
                    
                    let row = table.rowController(at: index) as! NextOccurRow
                    
                    if let nextOccur = foundNextOccur {
                        
                        
                        
                        let cal: Calendar = Calendar(identifier: .gregorian)
                        let midnightToday: Date = cal.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
                        let nextOccurDay: Date = cal.date(bySettingHour: 0, minute: 0, second: 0, of: nextOccur.startDate)!
                        let NXOsec = nextOccurDay.timeIntervalSince(midnightToday)
                        let NXOdays = NXOsec/60/60/24
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "EEEE"
                        let formattedEnd = dateFormatter.string(from: nextOccur.startDate)
                        
                        var dayText = formattedEnd
                        
                        switch NXOdays {
                        case 0:
                            dayText = "Today"
                        case 1:
                            dayText = "Tomorrow"
                        default:
                            dayText = formattedEnd
                        }
                        
                        var infoText = nextOccur.startDate.formattedTime()
                        
                        if let period = nextOccur.magdalenePeriod {
                            
                            infoText = "Period: \(period)"
                            
                        }
                        
                        if let loc = nextOccur.location {
                            
                            
                            infoText += " - \(loc)"
                            
                        }
                        
                        row.infoLabel.setText(infoText)
                        row.mainLabel.setText(dayText)
                        
                        if Int(NXOdays) != 1 {
                            
                            row.relativeDaysLabel.setText("\(Int(NXOdays)) days from now.")
                            row.relativeDaysLabel.setHidden(false)
                            
                        } else {
                            
                            row.relativeDaysLabel.setHidden(true)
                            
                        }
                        
                        
                    }
                    
                }
                
                
            }
            
            
        }

        
        
    }
    
    func showLocation() {
        
        
    }

}
