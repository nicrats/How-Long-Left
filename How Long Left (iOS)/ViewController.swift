//
//  ViewController.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 15/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import UIKit
import WatchKit
#if canImport(Intents)
import Intents
import IntentsUI
#endif
import ViewAnimator
import Hero

class ViewController: UIViewController, HLLCountdownController, DataSourceChangedDelegate {
    
    
    
    func percentageMilestoneReached(milestone percentage: Int, event: HLLEvent) {
        
    }
    
    func eventStarted(event: HLLEvent) {
        
    }
    
    
    func eventHalfDone(event: HLLEvent) {
    }
    
    
    @IBOutlet weak var settingsStack: UIStackView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return UIStatusBarStyle.lightContent
        
    }
    
    func userInfoChanged(date: Date) {
    }
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        
    }
    
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    
    @IBOutlet weak var upcomingLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var upcomingLocationLabel: UILabel!
    
    @IBOutlet weak var upcomingButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    let defaults = HLLDefaults.defaults
    
    @IBAction func countdownTapped(_ sender: UITapGestureRecognizer) {
        
      //  showingProgress = !showingProgress
      //  setBackgroundImage()
        
    }
    
    let notoScheduler = MilestoneNotificationScheduler()
    let backgroundImageView = UIImageView()
    let darkView = UIView()
    let gradient = CAGradientLayer()
    let calData = EventDataSource.shared
    var timer: Timer!
    var FastTimer: Timer!
    let timerStringGenerator = EventCountdownTimerStringGenerator()
    let upcomingStringGenerator = UpcomingEventStringGenerator()
    let schoolChecker = SchoolAnalyser()
    lazy var eventMonitor = EventTimeRemainingMonitor(delegate: self)
    static var launchedWithSettingsShortcut = false
    
    var countdownEvent: HLLEvent? {
        
        didSet {
            
            var currentArray = [HLLEvent]()
            
            if let current = countdownEvent {
                
                currentArray.append(current)
                
            }
            
            eventMonitor.setCurrentEvents(events: currentArray)
            
        }
        
    }
    
    func segueToSettings() {
        
        performSegue(withIdentifier: "OpenSettings", sender: nil)
        
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        
     //   self.notoScheduler.getAccess()
      //  self.notoScheduler.scheduleTestNotification()
        
    }
    
    @IBAction func upcomingButtonTapped(_ sender: Any) {
        
        
        
    }
    
    func showAlertBanner(Title: String, Subtitle: String) {
        
       /* let banner = GrowingNotificationBanner(title: Title, subtitle: Subtitle, style: .info)
        banner.backgroundColor = UIColor.white
        banner.applyStyling(titleColor: UIColor.black, titleTextAlign: NSTextAlignment.left, subtitleColor: UIColor.black, subtitleTextAlign: NSTextAlignment.left)
        DispatchQueue.main.async {
        banner.show() 
        } */
        
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackgroundImage()
        //shift.startTimedAnimation()
        run()
        updateTimer()
        DispatchQueue.main.async {
        
        VoiceShortcutStatusChecker.shared.check()
        }
        
        DispatchQueue.main.async {
            SchoolAnalyser.shared.analyseCalendar()
            
            self.notoScheduler.getAccess()
            self.notoScheduler.scheduleNotificationsForUpcomingEvents()
            
        }
        
       
        
    }
    
    override func viewDidLoad() {
        

        //let notoS = MilestoneNotificationScheduler()
       // notoS.scheduleTestNotification()
        
        self.hero.isEnabled = true
        self.upcomingLabel.hero.id = "UpcomingTitle"
        super.viewDidLoad()
        
        if ViewController.launchedWithSettingsShortcut == false {
        let animation = AnimationType.zoom(scale: 2.1)
        
        view.animate(animations: [animation], reversed: false, initialAlpha: 0.0, finalAlpha: 1.0, delay: 0, duration: 0.6, options: .allowAnimatedContent, completion: nil)
        
            
        }
        
        timer = Timer(fire: Date(), interval: 3, repeats: true, block: {_ in
            
           self.run()
            
        })
        
        FastTimer = Timer(fire: Date(), interval: 0.5, repeats: true, block: {_ in
            
            self.updateTimer()
            
        })
        
        RunLoop.main.add(timer, forMode: .common)
        RunLoop.main.add(FastTimer, forMode: .common)
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
       // updateBackgroundGradient()
        setBackgroundImage()
        donateInteraction()
        
        
        WatchSessionManager.sharedManager.addDataSourceChangedDelegate(delegate: self)
        
        countdownLabel.font = UIFont.monospacedDigitSystemFont(ofSize: countdownLabel.font.pointSize, weight: .regular)
        
        run()
        
        WatchSessionManager.sharedManager.startSession()
        //defaults.set(false, forKey: "ShownWatchAlert")
        
    
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
        
        SchoolAnalyser.shared.analyseCalendar()
        
        
    }
    
    func updateTimer() {
        
        
        
        DispatchQueue.main.async {
            
            if let event = self.countdownEvent {
                
                if event.endDate.timeIntervalSinceNow < 0 {
                    
                    self.run()
                    
                }
                
                
                let string = self.timerStringGenerator.generateStringFor(event: event)
                
                self.countdownLabel.text = string
                
                
    
            }
            
            if ViewController.launchedWithSettingsShortcut == true {
                
                ViewController.launchedWithSettingsShortcut = false
                
                self.segueToSettings()
                
            }
            
        }
        
        
    }
    
    func run() {
        
        DispatchQueue.global(qos: .default).async {
            
        
        self.calData.updateEventStore()
        
        let currentEvents = self.calData.getCurrentEvents()
        let upcomingEvents = self.calData.getUpcomingEventsToday()
        
        if let current = currentEvents.first {
            
            self.countdownEvent = current
            
            
            DispatchQueue.main.async {
                
                self.eventTitleLabel.text = "\(current.title) ends in"
                self.countdownLabel.text = self.timerStringGenerator.generateStringFor(event: current)
                self.countdownLabel.isHidden = false
                self.eventTitleLabel.isHidden = false
                
                
                
            }
            
            
            
        } else {
            
            self.countdownEvent = nil
            
            DispatchQueue.main.async {
                self.progressLabel.isHidden = true
                self.eventTitleLabel.isHidden = false
                if EventDataSource.accessToCalendar == .Granted {
                    
                    self.eventTitleLabel.text = "No events are on"
                    self.upcomingLabel.isHidden = false
                } else if EventDataSource.accessToCalendar == .Denied {
                    
                    self.eventTitleLabel.text = "Enable calendar access in the Settings app."
                    self.upcomingLabel.isHidden = true
                    
                }
                
                
                self.countdownLabel.isHidden = true
                
            }
            
            
            
        }
        
        let upcomingTuple = self.upcomingStringGenerator.generateNextEventString(upcomingEvents: upcomingEvents, currentEvents: currentEvents, isForDoneNotification: false)
        
        if let upcomingInfo = upcomingTuple.0 {
            
            DispatchQueue.main.async {
                
                self.upcomingLabel.text = upcomingInfo
                self.upcomingLabel.isHidden = false
                
            }
            
        } else {
            
            DispatchQueue.main.async {
                
                self.upcomingLabel.isHidden = true
                
            }
            
        }
        
        if let upcomingLocation = upcomingTuple.1 {
            
            DispatchQueue.main.async {
                
                self.upcomingLocationLabel.text = upcomingLocation
                self.upcomingLocationLabel.isHidden = false
                
            }
            
        } else {
            
            DispatchQueue.main.async {
                
                self.upcomingLocationLabel.isHidden = true
                
            }
            
        }
        
        self.eventMonitor.checkCurrentEvents()
        
            
        
        
        }
    }
    
    
    func updateDueToEventEnd(event: HLLEvent, endingNow: Bool) {
        
        if endingNow == true {
        showAlertBanner(Title: "\(event.title) is done.", Subtitle: "")
        }
    }
    
    func milestoneReached(milestone seconds: Int, event: HLLEvent) {
        print("Milestone reached")
    }
    
    let bArray = [UIImage(named: "Background_Light"), UIImage(named: "Background_Dark"), UIImage(named: "Background_Black")]
    
    func setBackgroundImage() {
              
    //  backgroundImageView.image = bArray[0]
        
        if defaults.bool(forKey: "useDarkBackground") == true {
            backgroundImageView.image = bArray[1]
            /*darkView.backgroundColor = UIColor.black
            darkView.alpha = 0.75
            view.addSubview(darkView)
            view.sendSubviewToBack(darkView)
            darkView.translatesAutoresizingMaskIntoConstraints = false
            darkView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            darkView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            darkView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            darkView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true*/
            
        } else {
            backgroundImageView.image = bArray[0]
            darkView.removeFromSuperview()
            
        }
        
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        
        
    }
    
    var HLLYellow = #colorLiteral(red: 0.7659620876, green: 0.569952517, blue: 0.02249037123, alpha: 1)
    var HLLMiddle = #colorLiteral(red: 1, green: 0.6172748902, blue: 0.01708748773, alpha: 1)
    var HLLOrange = #colorLiteral(red: 0.9627912974, green: 0.3692123313, blue: 0, alpha: 1)
    
    var colourArray = [#colorLiteral(red: 1, green: 0.7437175817, blue: 0.02428589218, alpha: 1), #colorLiteral(red: 1, green: 0.6172748902, blue: 0.01708748773, alpha: 1), #colorLiteral(red: 0.9627912974, green: 0.3692123313, blue: 0, alpha: 1)]
    
    func donateInteraction() {
        if #available(iOS 12.0, *) {
            let intent = HowLongLeftIntent()
        
        intent.suggestedInvocationPhrase = "How long left"
        
        let interaction = INInteraction(intent: intent, response: nil)
        
        interaction.donate { (error) in
            if error != nil {
                if let error = error as NSError? {
                    print("Failed to donate because \(error)")
                } else {
                    print("Successfully donated")
                }
            }
        }
    }
    
    }

}


extension CALayer {
    
    func bringToFront() {
        guard let sLayer = superlayer else {
            return
        }
        removeFromSuperlayer()
        sLayer.insertSublayer(self, at: UInt32(sLayer.sublayers?.count ?? 0))
    }
    
    func sendToBack() {
        guard let sLayer = superlayer else {
            return
        }
        removeFromSuperlayer()
        sLayer.insertSublayer(self, at: 0)
    }
}

/*
 
 class webView: UIViewController, WKNavigationDelegate {
 
 @IBOutlet weak var viewW: UIView!
 var webView: WKWebView!
 var browser: Erik!
 override func viewDidLoad() {
 
 super.viewDidLoad()
 self.navigationItem.title = "Erik"
 
 let url = URL(string: "https://spring.edval.education/timetable")
 
 let frame = UIScreen.main.bounds
 
 
 webView = WKWebView(frame: frame, configuration:  WKWebViewConfiguration())
 webView.allowsBackForwardNavigationGestures = true
 viewW.addSubview(webView)
 
 webView.navigationDelegate = self
 
 browser = Erik(webView: webView)
 
 browser.visit(url: url!) { object, error in
 if let e = error {
 
 } else if let doc = object {
 
 if let input = doc.querySelectorAll("input[name=\"webCode\"]").first {
 input["value"] = "ETMF55V"
 
 if let form = doc.querySelector("button") {
 form.click()
 }
 
 
 
 }
 
 
 
 
 }
 }
 
 
 browser!.visit(url: url!) { object, error in
 
 DispatchQueue.main.asyncAfter(deadline: .now() + 0, execute: {
 
 
 
 
 
 if let e = error {
 
 } else if let doc = object {
 
 print(doc.toHTML)
 
 
 
 
 
 
 } else {
 
 
 }
 
 
 
 })
 
 }
 
 }
 
 
 }
 
 */
