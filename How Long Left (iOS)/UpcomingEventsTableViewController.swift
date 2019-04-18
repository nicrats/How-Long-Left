//
//  UpcomingEventsTableViewController.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 31/3/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import UIKit
import MarqueeLabel
    
    class UpcomingEventsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DataSourceChangedDelegate {
        
        
        let eventDatasource = EventDataSource()
        var events = [HLLEvent]()
        var endCheckTimer: Timer!
        @IBOutlet weak var tableView: UITableView!
        
        override func viewDidLoad() {
            
            //  self.tabBarController?.tabBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            SchoolAnalyser.shared.analyseCalendar()
            self.endCheckTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(self.checkForEnd), userInfo: nil, repeats: true)
            RunLoop.main.add(self.endCheckTimer, forMode: .common)
            
            events = eventDatasource.getUpcomingEventsFromNextDayWithEvents()
            
            tableView.delegate = self
            tableView.dataSource = self
            tableView.reloadData()
            
            updateCountdownData()
            
            WatchSessionManager.sharedManager.addDataSourceChangedDelegate(delegate: self)
            
            
            
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.calendarDidChange),
                name: .EKEventStoreChanged,
                object: nil)
            
            
        }
        
        @objc func calendarDidChange() {
            
            SchoolAnalyser.shared.analyseCalendar()
            updateCountdownData()
            
            
        }
        
        @objc func checkForEnd() {
            
            DispatchQueue.global(qos: .default).async {
                
                if self.eventDatasource.getUpcomingEventsFromNextDayWithEvents() != self.events {
                    
                    self.updateCountdownData()
                    
                }
                
                
            }
            
            
        }
        
        func updateCountdownData() {
            
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
                
            }
            
            self.events = self.eventDatasource.getUpcomingEventsFromNextDayWithEvents()
            
            var tabTitle = "Upcoming Events"
            
            if let firstUpcoming = self.events.first {
            
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                let formattedEnd = dateFormatter.string(from: firstUpcoming.startDate)
            
           let days = firstUpcoming.startDate.midnight().timeIntervalSince(Date().midnight())/60/60/24
            
           
                
            switch days {
            case 0:
                tabTitle = "Upcoming Today"
            case 1:
                tabTitle = "Upcoming Tomorrow"
            default:
                tabTitle = "Upcoming \(formattedEnd)"
            }
            
        }
           
            self.navigationItem.title = tabTitle
                
            
            
        }
        
        override func viewDidAppear(_ animated: Bool) {
            
            SchoolAnalyser.shared.analyseCalendar()
            
            
            updateCountdownData()
            
            
            
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            if events.isEmpty == false {
                tableView.separatorStyle = .singleLine
                tableView.backgroundView = nil
                if #available(iOS 11.0, *) {
                    navigationItem.largeTitleDisplayMode = .always
                }
                
            } else {
                
                let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text          = "No Upcoming Events"
                noDataLabel.textColor     = UIColor.lightGray
                noDataLabel.font = UIFont.systemFont(ofSize: 18)
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
                if #available(iOS 11.0, *) {
                    navigationItem.largeTitleDisplayMode = .never
                }
            }
            
            //self.tabBarController?.tabBar.items?.first?.badgeValue = "\(events.count)"
            return events.count
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            
            let event = events[indexPath.row]
            
            if event.location == nil {
                
                return 70
                
            } else {
                
                return 95
                
            }
            
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let event = events[indexPath.row]
            
            let iden = "UpcomingEventCellLocation"
            
            if event.location != nil {
                
               // iden = "UpcomingEventCellLocation"
                
            }
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: iden, for: indexPath) as! upcomingCell
            
            cell.generate(from: event)
            
            return cell
            
        }
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           // tableView.deselectRow(at: indexPath, animated: true)
        }
        
        func userInfoChanged(date: Date) {
        }
        
        
    }
    

class upcomingCell: UITableViewCell {
    
    var timer: Timer!
    
    @IBOutlet weak var titleLabel: MarqueeLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: MarqueeLabel!
    @IBOutlet weak var startsInTimer: UILabel!
    let timerStringGenerator = EventCountdownTimerStringGenerator()
    var rowEvent: HLLEvent!
    let gradient = CAGradientLayer()
    
    @IBOutlet weak var calColBAr: UIView!
    
    func generate(from event: HLLEvent) {
        
        for label in [titleLabel!, locationLabel!] {
        
        label.marqueeType = .MLContinuous
        label.animationDelay = 6
        label.scrollDuration = 15
        label.fadeLength = 10
        label.trailingBuffer = 20
        label.triggerScrollStart()
            
        }
        
        
        rowEvent = event

        
       // updateTimer()
        
       /* timer = Timer(fire: Date(), interval: 0.1, repeats: true, block: {_ in
            
          //  self.updateTimer()
            
        })
        
        RunLoop.main.add(timer, forMode: .default) */
        
        
        titleLabel.text = event.title
        
        var timeLabelText = "\(event.startDate.formattedTime()) - \(event.endDate.formattedTime())"
        
        if let period = rowEvent.magdalenePeriod {
        
            timeLabelText = "Period \(period): \(timeLabelText)"
            
        }
        
        timeLabel.text = timeLabelText
        
        
            
        if let loc = rowEvent.location {
            
            locationLabel.text = loc
            locationLabel.isHidden = false
            
        } else {
            
            locationLabel.isHidden = true
            
        }
        
        if let col = event.calendar?.cgColor {
            
            let uiCOL = UIColor(cgColor: col)
            
          //  let lighter = uiCOL.lighter(by: 13)!.cgColor
           // let darker = uiCOL.darker(by: 8)!.cgColor
            
            
            
            
           // gradient.frame = calColBAr.bounds
           // gradient.colors = [lighter, col, darker]
            
          //  calColBAr.layer.insertSublayer(gradient, at: 0)
            
            calColBAr.backgroundColor = uiCOL
            
        }
        
    }
    
    func updateTimer() {
        
        if let countdownString = self.timerStringGenerator.generateStringFor(event: rowEvent, start: true) {
            startsInTimer.text = "\(countdownString)"
        }
        
        
    }
    
    
}
