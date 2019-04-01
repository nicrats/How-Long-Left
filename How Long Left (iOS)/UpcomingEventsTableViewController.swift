//
//  UpcomingEventsTableViewController.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 31/3/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import UIKit
    
    class UpcomingEventsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DataSourceChangedDelegate {
        
        
        let eventDatasource = EventDataSource()
        var events = [HLLEvent]()
        var endCheckTimer: Timer!
        @IBOutlet weak var tableView: UITableView!
        
        override func viewDidLoad() {
            
            //  self.tabBarController?.tabBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
            self.endCheckTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(self.checkForEnd), userInfo: nil, repeats: true)
            RunLoop.main.add(self.endCheckTimer, forMode: .common)
            
            tableView.delegate = self
            tableView.dataSource = self
            tableView.reloadData()
            
            WatchSessionManager.sharedManager.addDataSourceChangedDelegate(delegate: self)
            
            SchoolAnalyser.shared.analyseCalendar()
            
            
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
            
            eventDatasource.updateEventStore()
            events = eventDatasource.getUpcomingEventsFromNextDayWithEvents()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
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
                
                return 64
                
            } else {
                
                return 76
                
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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var calColBAr: UIView!
    var rowEvent: HLLEvent!
    
    func generate(from event: HLLEvent) {
        
        rowEvent = event
        titleLabel.text = event.title
        
        if let period = rowEvent.magdalenePeriod {
        
            timeLabel.text = "Period: \(period)"
            
        } else {
            
            timeLabel.text = "\(event.startDate.formattedTime()) - \(event.endDate.formattedTime())"
            
        }
        
        
            
            
        if let loc = rowEvent.location {
            
            locationLabel.text = loc
            
        } else {
            
            locationLabel.isHidden = true
            
        }
        
        if let CGcolor = EventDataSource.shared.calendarFromID(event.calendarID)?.cgColor {
            
            let CalUIcolor = UIColor(cgColor: CGcolor)
            calColBAr.backgroundColor = CalUIcolor
            
        }
        
    }
    
    
}


