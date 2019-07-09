//
//  CurrentEventsTableViewController.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 31/3/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//
//countdowndrying=3
import UIKit
#if canImport(Intents)
import Intents
import IntentsUI
#endif
import MarqueeLabel

class CurrentEventsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DataSourceChangedDelegate, ScrollUpDelegate {
    
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
        
        tableView.frame = self.view.frame
        
        extendedLayoutIncludesOpaqueBars = true
       // NotificationCenter.default.addObserver(self, selector: #selector(self.updateTheme), name: Notification.Name("ThemeChanged"), object: nil)
        
        // NotificationCenter.default.addObserver(self, selector: #selector(self.gotCalAccess), name: Notification.Name("CalendarAllowed"), object: nil)
        
        
        //  self.tabBarController?.tabBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        
        CurrentEventsTableViewController.shared = self
        
        events = eventDatasource.getCurrentEvents()
        self.endCheckTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(self.checkForEnd), userInfo: nil, repeats: true)
        
        updateTheme()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        DispatchQueue.main.async {
            WatchSessionManager.sharedManager.addDataSourceChangedDelegate(delegate: self)
        }
        
        
       NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.calendarDidChange),
            name: .EKEventStoreChanged,
            object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.calendarDidChange), name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
  
    
    @objc func updateTheme() {
        navigationController?.navigationBar.barTintColor = AppTheme.current.plainColor
        //navigationController?.navigationBar.barStyle = AppTheme.current.barStyle
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: AppTheme.current.textColor]
        navigationController?.navigationBar.isTranslucent = AppTheme.current.translucentBars
        tableView.backgroundColor = AppTheme.current.groupedTableViewBackgroundColor
        tabBarController?.tabBar.isTranslucent = AppTheme.current.translucentBars
        tabBarController?.tabBar.barStyle = AppTheme.current.barStyle
        tableView.separatorColor = AppTheme.current.tableCellSeperatorColor
        tabBarController?.tabBar.barTintColor = AppTheme.current.plainColor
        self.navigationController?.setNeedsStatusBarAppearanceUpdate()
        tableView.reloadData()
    }
    

    
    var gotAccess = false
    
    @objc func gotCalAccess() {
        
        if gotAccess == false {
            
            gotAccess = true
            updateCountdownData()
            
        }
        
    }
    
    @objc func checkForEnd() {
        
        
        for event in self.events {
            
            if event.endDate.timeIntervalSinceNow < 0 {
                
                
                self.updateCountdownData()
                
            }
            
        }
        
        
    }
    
    func scrollUp() {
        if self.tableView.numberOfSections > 0, self.tableView.numberOfRows(inSection: 0) > 0 {
            
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            
        }
    }
    
    @objc func calendarDidChange() {
        
        print("Calendar did change")
        
        schoolAnalyser.analyseCalendar()
        print("SA6")
        updateCountdownData()
        
        
    }
    
    @objc func updateCountdownData() {
        
        print("Update countdown data")
        
        let oldEvents = self.events
        
        self.events = self.eventDatasource.getCurrentEvents()
        
        // print("E: \(self.events.count)")
        
        // self.tableView.beginUpdates()
        
        if self.events != oldEvents {
            
            self.tableView.reloadData()
            
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.tabBarController?.view.layoutSubviews()
        // self.navigationController?.view.layoutSubviews()
        
        updateTheme()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        RootViewController.selectedController = self
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

class eventCell: UITableViewCell, MCPercentageDoughnutViewDataSource {
    
    func viewForCenter(of pecentageDoughnutView: MCPercentageDoughnutView!, withCenter centerView: UIView!) -> UIView! {
        return UIView()
    }
    
    
    
    var timer: Timer!
    let timerStringGenerator = EventCountdownTimerStringGenerator()
    var rowEvent: HLLEvent!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var calColBar: UIView!
    
    
    @IBOutlet weak var progress: MCPercentageDoughnutView!
    let calc = PercentageCalculator()
    let gradient = CAGradientLayer()
    
    func generate(from event: HLLEvent) {
        
        self.backgroundColor = nil
        progress.dataSource = self
        progress.linePercentage = 0.20
        progress.showTextLabel = false
    
        progress.isHidden = true
        progress.unfillColor = .lightGray
        progress.fillColor = AppTheme.current.textColor
        self.backgroundColor = AppTheme.current.tableCellBackgroundColor
        titleLabel.textColor = AppTheme.current.textColor
        countdownLabel.textColor = AppTheme.current.textColor
        
        rowEvent = event
        
        titleLabel.text = "\(event.title) ends in"
        
        
        updateTimer()
        
        if let col = event.calendar?.cgColor {
            
            let uiCOL = UIColor(cgColor: col)
            calColBar.backgroundColor = uiCOL
            progress.fillColor = uiCOL
            
            //  let lighter = uiCOL.lighter(by: 13)!.cgColor
            //let darker = uiCOL.darker(by: 8)!.cgColor
            
            
            
            
            // gradient.frame = calColBar.bounds
            //  gradient.colors = [lighter, col, darker]
            
            //  calColBar.layer.insertSublayer(gradient, at: 0)
            
        }
        
        
        countdownLabel.font = UIFont.monospacedDigitSystemFont(ofSize: countdownLabel.font.pointSize, weight: .regular)
        
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
            
            let secondsElapsed = Date().timeIntervalSince(rowEvent.startDate)
            let totalSeconds = rowEvent.endDate.timeIntervalSince(rowEvent.startDate)
            progress.percentage = CGFloat(secondsElapsed/totalSeconds)
            progress.isHidden = false
            
            //  self.percentLabel.text = self.calc.calculatePercentageDone(event: self.rowEvent, ignoreDefaults: true)
            
            
        }
        
        
    }
    
}
