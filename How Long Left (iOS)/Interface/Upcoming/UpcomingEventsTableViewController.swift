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
    
class UpcomingEventsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ScrollUpDelegate, EventPoolUpdateObserver {
    
        var events = [HLLEvent]()
        var eventDates = [DateOfEvents]()
        var lastReadReturnedNoCalendarAccess = false
        var endCheckTimer: Timer!
        var previewingEvent: HLLEvent?
        
        @IBOutlet weak var tableView: UITableView!
    
        override func viewDidLoad() {
            
            self.tableView.delegate = self
            self.tableView.dataSource = self
            
            HLLEventSource.shared.addEventPoolObserver(self)
            
            self.navigationItem.title = "Upcoming"
            
            
            self.endCheckTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(self.checkForEnd), userInfo: nil, repeats: true)
            
            
        }
    
    

        @objc func calendarDidChange() {
            
            updateCountdownData()
            
            
        }
        
    @objc func checkForEnd() {
        
        
        for event in self.events {
            
            if event.endDate.timeIntervalSinceNow > 0 {
                
                
                self.updateCountdownData()
                
            }
            
        }
        
        
    }

    var gotAccess = false
    
    @objc func gotCalAccess() {
    
        if gotAccess == false {
            
            gotAccess = true
            updateCountdownData()
            
        }
    
    }
    
       @objc func updateCountdownData() {
        
        let prev = self.eventDates
        
        self.eventDates = HLLEventSource.shared.getArraysOfUpcomingEventsForNextSevenDays(returnEmptyItems: false)
        
        
        if prev != self.eventDates || prev.isEmpty {
            self.tableView.reloadData()
        }

   
    }
        
    override func viewWillAppear(_ animated: Bool) {
            
        self.updateCountdownData()
            
        DispatchQueue.main.async {
            
        RootViewController.selectedController = self
            
        }
            
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
        return eventDates[section].events.count
            
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let event = eventDates[indexPath.section].events[indexPath.row]
            
            let iden = "UpcomingEventCellLocation"
            
            if event.location != nil {
                
               // iden = "UpcomingEventCellLocation"
                
            }
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: iden, for: indexPath) as! upcomingCell            
            cell.generate(from: event)
            
            if RootViewController.hasFadedIn == false {
                cell.alpha = 0
                
                UIView.animate(withDuration: 0.30, animations: {
                    cell.alpha = 1
                })
            }

            
            return cell
            
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Upcoming \(eventDates[section].date.userFriendlyRelativeString())"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if RootViewController.hasFadedIn == false {
        
        view.alpha = 0
        
        UIView.animate(withDuration: 0.30, animations: {
            
            view.alpha = 1
            
        })
            
        }
        
    }
        
        func numberOfSections(in tableView: UITableView) -> Int {
            
            var areEvents = false
            
            if let day = eventDates.first {
                
                if day.events.isEmpty == false {
                    
                    areEvents = true
                    
                }
                
            }
        
            
            if areEvents == true || HLLEventSource.shared.neverUpdatedEventPool {
                tableView.separatorStyle = .singleLine
                tableView.backgroundView = nil
                
                
            } else {
                
                RootViewController.hasFadedIn = true
                
                var text = "No Upcoming Events"
                
                if HLLEventSource.shared.access != .Granted {
                    
                    text = "No Calendar Access"
                    
                }
                
                let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text          = text
                noDataLabel.textColor     = UIColor.lightGray
                noDataLabel.font = UIFont.systemFont(ofSize: 18)
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
                
                
                    
            }
            
            return eventDates.count
        }
        
         func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
               
            let event = eventDates[indexPath.section].events[indexPath.row]
               
               let viewController = EventInfoViewGenerator.shared.generateEventInfoView(for: event)
               
               self.navigationController?.pushViewController(viewController, animated: true)
               
               tableView.deselectRow(at: indexPath, animated: true)
           }
           
    func scrollUp() {
        
        if self.tableView.numberOfSections > 0, self.tableView.numberOfRows(inSection: 0) > 0 {
            
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            if indexPath == lastVisibleIndexPath {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    
                    RootViewController.hasFadedIn = true
                })
                
            }
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let indexPath = self.tableView.indexPathForSelectedRow {
            
            let event = eventDates[indexPath.section].events[indexPath.row]
            let destination = (segue.destination as! EventInfoViewController)
            destination.event = event
            
        }
        
    }
    
    func eventPoolUpdated() {
        DispatchQueue.main.async {
            
            self.updateCountdownData()
            

        }
    }
    
    
}

@available(iOS 13.0, *)
extension UpcomingEventsTableViewController {
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let event = eventDates[indexPath.section].events[indexPath.row]
        
        previewingEvent = event
        
        
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: {
                                            
                                            
                                              return EventInfoViewGenerator.shared.generateEventInfoView(for: event)
                                            
        },
                                            actionProvider: { _ in
                                            return HLLEventContextMenuGenerator.shared.generateContextMenuForEvent(event)  })
        
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        
        animator.addCompletion {
            
            if let event = self.previewingEvent {
            
            
            let viewController = EventInfoViewGenerator.shared.generateEventInfoView(for: event)
            self.show(viewController, sender: self)

                
            }
            
            
        }
        
    }
    
}
    

class upcomingCell: UITableViewCell {
    
    var timer: Timer!
    
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var titleLabel: MarqueeLabel!
    @IBOutlet weak var locationLabel: MarqueeLabel!
    @IBOutlet weak var startsInTimer: UILabel!
    var rowEvent: HLLEvent!
    let gradient = CAGradientLayer()
    
    @IBOutlet weak var calColBAr: UIView!
    
    func generate(from event: HLLEvent) {
        
       
        rowEvent = event
        titleLabel.text = event.title
        startLabel.text = event.startDate.formattedTime()
        endLabel.text = event.endDate.formattedTime()
        
        if event.startDate.formattedDate() != event.endDate.formattedDate() {
            
            endLabel.text = " "
            
        }
    
        var infoText: String?
        
        if let period = rowEvent.period {
            
            infoText = "Period \(period)"
            locationLabel.isHidden = false
            
            if let location = rowEvent.location {
                
                infoText = "\(infoText!) - \(location)"
                locationLabel.isHidden = false
                
            }
            
        } else if let location = rowEvent.location {
                
                infoText = location
                locationLabel.isHidden = false
                
            } else {
                
                locationLabel.isHidden = true
                
            }
        
            
            locationLabel.text = infoText
            
        
        
        calColBAr.backgroundColor = event.uiColor
        
        titleLabel.fadeLength = 10
        locationLabel.fadeLength = 10
        
       
        
        
        DispatchQueue.main.async {
            
            self.titleLabel.marqueeType = .MLContinuous
            self.titleLabel.animationDelay = 6
            self.titleLabel.scrollDuration = 15
            
            self.titleLabel.trailingBuffer = 20
            
            
            self.locationLabel.marqueeType = .MLContinuous
            self.locationLabel.animationDelay = 6
            self.locationLabel.scrollDuration = 15
            
            self.locationLabel.trailingBuffer = 20
            
            self.titleLabel.triggerScrollStart()
            self.locationLabel.triggerScrollStart()
            
        }
        
        
    }
 
    
}
