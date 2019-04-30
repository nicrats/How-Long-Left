//
//  CurrentEventsTableViewController.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 31/3/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import UIKit
import WatchKit
#if canImport(Intents)
import Intents
import IntentsUI
#endif
import MarqueeLabel

class CurrentEventsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DataSourceChangedDelegate {
    
    static var shared: CurrentEventsTableViewController?
    static var selectedEvent: HLLEvent?
    
    static var timerStartDate = Date()
    
    let defaults = HLLDefaults.defaults
    let eventDatasource = EventDataSource()
   
    var events = [HLLEvent]()
    var lastReadReturnedNoCalendarAccess = false
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noEventsStack: UIStackView!
    var endCheckTimer: Timer!
    let schoolAnalyser = SchoolAnalyser()
    

    
    
    override func viewDidLoad() {
        
        extendedLayoutIncludesOpaqueBars = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTheme), name: Notification.Name("ThemeChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCountdownData), name: Notification.Name("CalendarAllowed"), object: nil)
        
        
      //  self.tabBarController?.tabBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        IAPHandler.shared.fetchAvailableProducts()
        schoolAnalyser.analyseCalendar()
        CurrentEventsTableViewController.shared = self
        
        events = eventDatasource.getCurrentEvents()
        self.endCheckTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(self.checkForEnd), userInfo: nil, repeats: true)
        RunLoop.main.add(self.endCheckTimer, forMode: .common)
        
        updateTheme()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        
        WatchSessionManager.sharedManager.addDataSourceChangedDelegate(delegate: self)
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.calendarDidChange),
            name: .EKEventStoreChanged,
            object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.calendarDidChange), name: UIApplication.willEnterForegroundNotification, object: nil)

    }
    
    @objc func updateTheme() {
        
       self.navigationController?.navigationBar.barStyle = AppTheme.current.barStyle
        self.tabBarController?.tabBar.barStyle = AppTheme.current.barStyle
        self.navigationController?.navigationBar.isTranslucent = AppTheme.current.translucentBars
        self.tabBarController?.tabBar.isTranslucent = AppTheme.current.translucentBars
        self.tabBarController?.tabBar.barStyle = AppTheme.current.barStyle
        self.tabBarController?.tabBar.backgroundColor = nil
        self.tableView.backgroundColor = AppTheme.current.groupedTableViewBackgroundColor
        self.tableView.separatorColor = AppTheme.current.tableCellSeperatorColor
        
        tableView.reloadData()
    }
    
    @objc func checkForEnd() {
        
        DispatchQueue.global(qos: .default).async {
            
            if self.eventDatasource.getCurrentEvents() != self.events {
                
                self.updateCountdownData()
                
            }
            
            
            if self.lastReadReturnedNoCalendarAccess == true {
                
                self.updateCountdownData()
                
            }
            
            if EventDataSource.accessToCalendar != .Granted {
                
                self.lastReadReturnedNoCalendarAccess = true
                
            } else {
                
                self.lastReadReturnedNoCalendarAccess = false
                
            }
            
        }
        
        
    }
    
    @objc func calendarDidChange() {
        
        schoolAnalyser.analyseCalendar()
        updateCountdownData()
       
        
    }
    
    @objc func updateCountdownData() {
        
        DispatchQueue.main.async {
        
            self.events = self.eventDatasource.getCurrentEvents()
        
           // self.tableView.beginUpdates()
            self.tableView.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.view.layoutSubviews()
        self.navigationController?.view.layoutSubviews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        schoolAnalyser.analyseCalendar()
        AppFunctions.shared.run()
        updateCountdownData()
        
    }
    
   /* let interactor = Interactor()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if let destinationViewController = segue.destination as? ViewController {
            
            if let cell = sender as? UITableViewCell {
                
                let path = tableView.indexPath(for: cell)!
                CurrentEventsTableViewController.selectedEvent = events[path.row]
                
            } else {
                
               CurrentEventsTableViewController.selectedEvent = events.first
                
            }
            
            if segue.identifier == "FullScreenCountdownSegue Preview" {
                
            destinationViewController.hideTapToDismiss = true
                
                
            } else {
                
               destinationViewController.hideTapToDismiss = false
                
            }
            
            
            destinationViewController.transitioningDelegate = self
            destinationViewController.interactor = interactor
        }
    } */
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        CurrentEventsTableViewController.timerStartDate = Date()
        
        if events.isEmpty == false {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
            if #available(iOS 11.0, *) {
                navigationItem.largeTitleDisplayMode = .always
            }
       
        } else {
            
            var text = "No Events Are On"
            
            if EventDataSource.accessToCalendar == .Denied {
                
                text = "No Calendar Access"
                
            }
            
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = text
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountdownCell", for: indexPath) as! eventCell
        
        cell.generate(from: events[indexPath.row])

        return cell
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
   
    
    func userInfoChanged(date: Date) {
    }
    
    
}

class eventCell: UITableViewCell {
    

    
    var timer: Timer!
    let timerStringGenerator = EventCountdownTimerStringGenerator()
    var rowEvent: HLLEvent!
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var titleLabel: MarqueeLabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var calColBar: UIView!

    
    let calc = PercentageCalculator()
    let gradient = CAGradientLayer()
    
    func generate(from event: HLLEvent) {
        
        self.backgroundColor = AppTheme.current.tableCellBackgroundColor
        titleLabel.textColor = AppTheme.current.textColor
        countdownLabel.textColor = AppTheme.current.textColor
        
        rowEvent = event
        
        titleLabel.text = "\(event.title) \(event.endsInString) in"
        
        titleLabel.marqueeType = .MLContinuous
        titleLabel.animationDelay = 4
        titleLabel.scrollDuration = 15
        titleLabel.fadeLength = 10
        titleLabel.trailingBuffer = 20
        titleLabel.triggerScrollStart()
        
        updateTimer()
        
        if let col = event.calendar?.cgColor {
            
            let uiCOL = UIColor(cgColor: col)
            progressBar.progressTintColor = uiCOL
            calColBar.backgroundColor = uiCOL
            
            
          //  let lighter = uiCOL.lighter(by: 13)!.cgColor
        //let darker = uiCOL.darker(by: 8)!.cgColor
            
            
            
            
           // gradient.frame = calColBar.bounds
          //  gradient.colors = [lighter, col, darker]
            
          //  calColBar.layer.insertSublayer(gradient, at: 0)
            
        }
        
        
        countdownLabel.font = UIFont.monospacedDigitSystemFont(ofSize: countdownLabel.font.pointSize, weight: .thin)
        
        timer = Timer(fire: CurrentEventsTableViewController.timerStartDate, interval: 0.07, repeats: true, block: {_ in
            
            DispatchQueue.main.async {
            self.updateTimer()
            }
            
        })
        
        RunLoop.main.add(timer, forMode: .default)
        
    }
    
    func updateTimer() {
        
        if let countdownString = self.timerStringGenerator.generateStringFor(event: rowEvent) {
            
                self.countdownLabel.text = "\(countdownString)"
                
                self.progressBar.progress = self.calc.calculateDoubleDone(of: self.rowEvent)
                
              //  self.percentLabel.text = self.calc.calculatePercentageDone(event: self.rowEvent, ignoreDefaults: true)
                
            
        }
        
        
    }
    
}
