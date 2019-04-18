//
//  UpcomingEventsTableViewController.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 23/2/19.
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
    
    let defaults = HLLDefaults.defaults
    let eventDatasource = EventDataSource()
   
    var events = [HLLEvent]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noEventsStack: UIStackView!
    var endCheckTimer: Timer!
    

    
    
    override func viewDidLoad() {
     
      //  self.tabBarController?.tabBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        IAPHandler.shared.fetchAvailableProducts()
        
        CurrentEventsTableViewController.shared = self
        
        events = eventDatasource.getCurrentEvents()
        self.endCheckTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(self.checkForEnd), userInfo: nil, repeats: true)
        RunLoop.main.add(self.endCheckTimer, forMode: .common)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
       
        //defaults.set(false, forKey: "ShownWatchAlert")
        
        WatchSessionManager.sharedManager.addDataSourceChangedDelegate(delegate: self)
        
        
        if WKInterfaceDevice.current().name != "", defaults.bool(forKey: "ShownWatchAlert") == false {
            
            defaults.set(true, forKey: "ShownWatchAlert")
            
            DispatchQueue.main.async {
                
                let alertController = UIAlertController(title: "Apple Watch App", message: "You can also use How Long Left on your Apple watch, and enable the Complication on the Modular Watch Face.", preferredStyle: .alert)
                let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                    print("You've pressed default");
                }
                alertController.addAction(action1)
                self.present(alertController, animated: true, completion: nil)
            }
            
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.calendarDidChange),
            name: .EKEventStoreChanged,
            object: nil)
      
        
    }
    
    
    @objc func checkForEnd() {
        
        DispatchQueue.global(qos: .default).async {
            
            if self.eventDatasource.getCurrentEvents() != self.events {
                
                self.updateCountdownData()
                
            }
            
            
        }
        
        
    }
    
    @objc func calendarDidChange() {
        
        SchoolAnalyser.shared.analyseCalendar()
        updateCountdownData()
       
        
    }
    
    func updateCountdownData() {
        
        eventDatasource.updateEventStore()
        events = eventDatasource.getCurrentEvents()
        DispatchQueue.main.async {
           // self.tableView.beginUpdates()
            self.tableView.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.view.layoutSubviews()
        self.navigationController?.view.layoutSubviews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
         SchoolAnalyser.shared.analyseCalendar()
        
        AppFunctions.shared.run()
        
        updateCountdownData()
        
        checkLaunchToCurrent(external: false)
        
        
    }
    
    func checkLaunchToCurrent(external: Bool) {
        
        if AppDelegate.launchToCurrentEvent == true {
            AppDelegate.launchToCurrentEvent = false
            
            if events.isEmpty == false {
                
                if external == true {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.50, execute: {
                    
                  //  self.performSegue(withIdentifier: "FullScreenCountdownSegue", sender: nil)
                    
                })
                    
                } else {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                        
                     //   self.performSegue(withIdentifier: "FullScreenCountdownSegue", sender: nil)
                        
                    })
                    
                    
                }
            
            }
            
        }
        
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
        
        if events.isEmpty == false {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
            if #available(iOS 11.0, *) {
                navigationItem.largeTitleDisplayMode = .always
            }
       
        } else {
            
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Events Are On"
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
        
        timer = Timer(fire: Date(), interval: 0.1, repeats: true, block: {_ in
            
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
