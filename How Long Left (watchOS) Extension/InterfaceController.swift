//
//  InterfaceController.swift
//  How Long Left (watchOS) Extension
//
//  Created by Ryan Kontos on 15/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import WatchKit
import Foundation
import EventKit
import UserNotifications

class InterfaceController: WKInterfaceController, HLLCountdownController, DataSourceChangedDelegate, SchoolModeChangedDelegate {
    
    func percentageMilestoneReached(milestone percentage: Int, event: HLLEvent) {
        
    }
    
    func eventStarted(event: HLLEvent) {
        
    }
    
    
    @IBOutlet var locationLabel: WKInterfaceLabel!
    @IBOutlet weak var nameLabel: WKInterfaceLabel!
    @IBOutlet weak var timerLabel: WKInterfaceTimer!
    @IBOutlet weak var endsInLabel: WKInterfaceLabel!
    @IBOutlet weak var NothingOnGroup: WKInterfaceGroup!
    @IBOutlet weak var NothingOnAndNoUpcomingGroup: WKInterfaceGroup!
    @IBOutlet weak var CountdownGroup: WKInterfaceGroup!
    @IBOutlet weak var nothingOnText: WKInterfaceLabel!
    @IBOutlet weak var nothingOnNoUpcomingText: WKInterfaceLabel!
    @IBOutlet weak var upcomingEventsTable: WKInterfaceTable!
    @IBOutlet weak var nextEventTimer: WKInterfaceTimer!
    @IBOutlet var upcomingSection: WKInterfaceGroup!
    
    let Hdefaults = HLLDefaults()
    let complication = CLKComplicationServer.sharedInstance()
    var eventMonitor: EventTimeRemainingMonitor?
    let calendarData = EventDataSource.shared
    var endCheckTimer = Timer()
    let defaults = HLLDefaults.defaults
    var currentTableIdentifiers = ""
    var currentCurrentIdentifier = ""
    var nothingOnInfo = ""
    var timer: Timer!
    var generatedEventRows = [eventRowInstance]()
    var NXOdays = 0.0
    var NXOdaysString: String?
    var nextOccurFinder = EventNextOccurenceFinder()
    var isShowingNextOccurButton = false
    var hasGenedTable = false
    
    var upcoming = [HLLEvent]()
    var current: HLLEvent?
    var nextOccurEvent: HLLEvent?
    

    var arrayOfCurrentUpcomingTableIDS = [String]()
    
    func schoolModeChanged() {
        routine(waitForTable: true, asyncData: true)
        
        DispatchQueue.global(qos: .default).async {
            self.updateComplication()
        }
    }
    
    func setUIHidden(_ hidden: Bool) {
        
        NothingOnGroup.setHidden(hidden)
        NothingOnAndNoUpcomingGroup.setHidden(hidden)
        CountdownGroup.setHidden(hidden)
        upcomingSection.setHidden(hidden)
        
    }
    
    @IBAction func refreshClicked() {
        
        
        routine(waitForTable: false, asyncData: true)
        
        DispatchQueue.global(qos: .default).async {
            SchoolAnalyser.shared.analyseCalendar()
        }
        DispatchQueue.global(qos: .default).async {
            self.updateComplication()
        }
        
        
        
    }
    
    @IBAction func settingsTapped() {
        
        self.presentController(withName: "CalSettings", context: nil)
        
    }
    
    
    func updateComplication() {
        
        DispatchQueue.global(qos: .default).async {
        
            if let activeComplicationsArray = self.complication.activeComplications {
            
            
            for complicationItem in activeComplicationsArray {
                
                self.complication.reloadTimeline(for: complicationItem)
                
            }
            
            
        }
            
        }
        
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        
        if segueIdentifier == "UpcomingEventSegue" {
        
        let event = upcoming[rowIndex]
            
        print("Seguing with \(event.title)")
            
            return event
            
        } else {
            
            return nil
            
        }
        
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        print("Awake")
        
        let center = UNUserNotificationCenter.current()
        // Request permission to display alerts and play sounds.
        center.requestAuthorization(options: [.alert, .sound])
        { (granted, error) in
            
            
        }
        
      //  self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(2), target: self, selector: #selector(self.updateEventDataGlobal), userInfo: nil, repeats: true)
      //  RunLoop.main.add(self.timer, forMode: .common)
      
        eventMonitor = EventTimeRemainingMonitor(delegate: self as HLLCountdownController)
        SchoolAnalyser.shared.addSchoolMOdeChangedDelegate(delegate: self)
        
        

            WatchSessionManager.sharedManager.addDataSourceChangedDelegate(delegate: self)
        
            if let lastUpdate = self.defaults.string(forKey: "lastUpdateScheduled"), let lastUpdateInt = TimeInterval(lastUpdate) {
            if Date(timeIntervalSince1970: lastUpdateInt).timeIntervalSinceNow > 2699 {
                self.updateComplication()
               let bh = BackgroundUpdateHandler(); bh.scheduleComplicationUpdate()
            }
        
            
        } else {
            
            let bh = BackgroundUpdateHandler(); bh.scheduleComplicationUpdate()
            
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.request),
            name: .EKEventStoreChanged,
            object: nil)
        
            
            
            SchoolAnalyser.shared.analyseCalendar()
        // Configure interface objects here.
        
       self.routine(waitForTable: false, asyncData: false)
            
        
        
        
    }
    
    
    
    func routine(waitForTable: Bool, asyncData: Bool) {
        
            current = calendarData.getCurrentEvent()
            self.getUpcomingEvents()

            self.updateCountdownUI(Event: self.current)
            self.generateUpcomingEventTableText(events: self.upcoming)

           
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        print("Will activate")
        self.routine(waitForTable: false, asyncData: true)
            
        
      
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        
      //  upcomingEventsTable.setNumberOfRows(0, withRowType: "EventRowID")
        
        super.didDeactivate()
    }
    
   @objc func request() {
    
    // Called when the eventstore changes.
    
    DispatchQueue.global(qos: .default).async {
    
        SchoolAnalyser.shared.analyseCalendar()
        
        self.routine(waitForTable: true, asyncData: true)
    
    
    
    
            self.updateComplication()
        }
    
        
    }
    
    
    
    func updateDueToEventEnd(event: HLLEvent, endingNow: Bool) {
        
        routine(waitForTable: true, asyncData: true)
        
        DispatchQueue.global(qos: .userInteractive).async {
            SchoolAnalyser.shared.analyseCalendar()
        }
        DispatchQueue.global(qos: .default).async {
            self.updateComplication()
        }
        
        
    }
    
    func milestoneReached(milestone seconds: Int, event: HLLEvent) {
        
    }
    
    func userInfoChanged() {
        
        routine(waitForTable: true, asyncData: true)
        
        DispatchQueue.global(qos: .userInteractive).async {
            SchoolAnalyser.shared.analyseCalendar()
        }
        DispatchQueue.global(qos: .default).async {
            self.updateComplication()
        }
        
        
        
    }
    
    func getUpcomingEvents() {
        
        var upcomingTemp = calendarData.getUpcomingEventsToday()
        
        if upcomingTemp.isEmpty == true {
            
            upcomingTemp = calendarData.getUpcomingEventsFromNextDayWithEvents()
        }
        
        upcoming = upcomingTemp
        
        if let NXO = upcoming.first {
        
        let cal: Calendar = Calendar(identifier: .gregorian)
        let midnightToday: Date = cal.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let eventStartMidnight: Date = cal.date(bySettingHour: 0, minute: 0, second: 0, of: NXO.startDate)!
        let NXOsec = eventStartMidnight.timeIntervalSince(midnightToday)
            
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
        let formattedEnd = dateFormatter.string(from: NXO.startDate)
            
        NXOdays = NXOsec/60/60/24
            
            switch NXOdays {
            case 0:
                NXOdaysString = nil
            case 1:
                NXOdaysString = "tomorrow"
            default:
                NXOdaysString = formattedEnd
            }
            
        }
        
    }
    
    func updateCountdownUI(Event: HLLEvent?) {
        
        DispatchQueue.main.async {
        
        var currentArray = [HLLEvent]()
        
            if let currentE = Event {
            
                
            currentArray.append(currentE)
            
            self.timerLabel.setDate(currentE.endDate.addingTimeInterval(1))
            self.timerLabel.start()
            
                self.nameLabel.setText("\(currentE.title)")
            
                
                if let cal = EventDataSource.shared.calendarFromID(currentE.calendarID) {
                    
                    self.timerLabel.setTextColor(UIColor(cgColor: cal.cgColor))
                    
                } else {
                    
                    self.timerLabel.setTextColor(#colorLiteral(red: 1, green: 0.5769822296, blue: 0.1623516734, alpha: 1))
                }
                
            if let loc = currentE.location {
               
                self.locationLabel.setText("(\(loc))")
                self.locationLabel.setHidden(false)
                
            } else {
                
                self.locationLabel.setHidden(true)
                
            }
            
                
               // self.nextOccurEvent = self.nextOccurFinder.findNextOccurrences(currentEvents: [current], upcomingEvents: self.calendarData.fetchEventsFromPresetPeriod(period: .Next2Weeks)).first
                

            self.showTimerUI(show: true)
        } else {
            
                self.timerLabel.stop()
                self.showTimerUI(show: false)
            
                self.nothingOnInfo = "No events are on right now"
        
        
                if self.upcoming.isEmpty == false {
            
            
            if self.NXOdays == 0 {
            
                self.nothingOnInfo = "Nothing is on until \(self.upcoming[0].startDate.formattedTime())."
         //   nextEventTimer.setDate(upcoming[0].startDate)
           // nextEventTimer.start()
                self.nextEventTimer.setHidden(true)
         //   nextEventTimer.setHidden(false)
                
            } else if let uDay = self.NXOdaysString {
                
                self.nextEventTimer.setHidden(true)
                
                self.nothingOnInfo = "Nothing is on until \(uDay)."
                
            }
        }
        
        self.nothingOnNoUpcomingText.setText(self.nothingOnInfo)
        self.nothingOnText.setText(self.nothingOnInfo)
        
    }
        
        
            self.eventMonitor?.setCurrentEvents(events: currentArray)
        
     
        
    }
        
    }
    
    @objc func nextOccurTapped() {
        
      //  pushController(withName: "NextOccurView", context: nextOccurEvent)
        
    }
    
    @IBAction func countdownViewTapped(_ sender: Any) {
        
        pushController(withName: "NextOccurView", context: nextOccurEvent)
        
    }
    
    func showTimerUI(show: Bool) {
        
        
        if show == false {
        
            //CountdownGroup.setHidden(true)
            CountdownGroup.setHidden(true)
            
        if upcoming.isEmpty == true {
            
            NothingOnAndNoUpcomingGroup.setHidden(false)
            NothingOnGroup.setHidden(true)
        } else {
            NothingOnAndNoUpcomingGroup.setHidden(true)
            NothingOnGroup.setHidden(false)
            
        }
        } else {
            
           // CountdownGroup.setHidden(false)
            
            CountdownGroup.setHidden(false)
            NothingOnAndNoUpcomingGroup.setHidden(true)
            NothingOnGroup.setHidden(true)
            
        }
        
        
    }
    
    var storedTableEvents = [HLLEvent]()
    
    func generateUpcomingEventTableText(events: [HLLEvent]) {
        
        DispatchQueue.main.async {
        
        let upcomingEvents = events
        var genedArray = [eventRowInstance]()
        
            if upcomingEvents.isEmpty == false, upcomingEvents != self.storedTableEvents  {
            
                self.upcomingSection.setHidden(true)
            
            //  currentTableIdentifiers = IDS
            
                self.storedTableEvents = upcomingEvents
            
            for event in upcomingEvents {
                
                
                let row = eventRowInstance()
                
                
                
              /*  let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                let formattedEnd = dateFormatter.string(from: event.startDate)
                
                var dayText: String?
                
                switch NXOdays {
                case 0:
                    dayText = nil
                case 1:
                    dayText = "Tomorrow"
                default:
                    dayText = formattedEnd
                } */
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mma"
                var startString = ""
                if let period = event.magdalenePeriod {
                    startString = "Period \(period)"
                } else {
                    startString = "\(dateFormatter.string(from: event.startDate))"

                
                }
                
                
              /*  if let uDayText = dayText {
                    
                    startString = "\(startString) = \(uDayText)"
                    
                } */
                
                row.eventTimeText = startString
                
                if let loc = event.location {
                    row.eventLocationText = loc
                }
                
                if let CGcolor = EventDataSource.shared.calendarFromID(event.calendarID)?.cgColor {
                    
                    let CalUIcolor = UIColor(cgColor: CGcolor)
                    row.eventTitleColour = (CalUIcolor)
                    
                } else {
                    
                    row.eventTitleColour = UIColor.white
                    
                }
                row.eventTitleText = event.title
                
                
                
                genedArray.append(row)
                
            }
            
                self.generatedEventRows = genedArray
                self.populateUpcomingEventsTable()
            
        }
        
            self.generatedEventRows = genedArray
        
    
    
    
    
        
    }
        
    }
    
    func populateUpcomingEventsTable() {
        
        
        if generatedEventRows.isEmpty == true {
            
            upcomingEventsTable.setNumberOfRows(0, withRowType: "EventRowID")
            upcomingSection.setHidden(true)
            
        } else {
            
            upcomingEventsTable.setNumberOfRows(generatedEventRows.count, withRowType: "EventRowID")
            upcomingSection.setHidden(false)
            
            for (index, rowContents) in generatedEventRows.enumerated() {
                
                let row = self.upcomingEventsTable.rowController(at: index) as! EventRow
                row.eventTitleLabel.setText(rowContents.eventTitleText)
                row.eventTitleLabel.setTextColor(rowContents.eventTitleColour)
                row.eventTimeLabel.setText(rowContents.eventTimeText)
                
                if let locLabelText = rowContents.eventLocationText {
                    
                    row.eventLocationLabel.setText(locLabelText)
                    row.eventLocationLabel.setHidden(false)
                    
                } else {
                    
                    row.eventLocationLabel.setHidden(true)
                    
                    
                }
            }
            
            
        }
        
    }
    
    override func contextsForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> [Any]? {
        
        return [upcoming[rowIndex]]
        
        
    }
    
    
    
    
    func eventHalfDone(event: HLLEvent) {
    }
    
        
        
    
}


class EventRow: NSObject {
    
    @IBOutlet weak var eventTitleLabel: WKInterfaceLabel!
    @IBOutlet var eventTimeLabel: WKInterfaceLabel!
    @IBOutlet var eventLocationLabel: WKInterfaceLabel!
}

class eventRowInstance {
 
    var eventTitleText = ""
    var eventTitleColour = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    var eventLocationText: String?
    var eventTimeText = ""
    
}
