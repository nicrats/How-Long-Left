//
//  TodayViewController.swift
//  How Long Left Widget (iOS)
//
//  Created by Ryan Kontos on 28/1/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var noEventOnInfoLabel: UILabel!
    var noEventOn = true
    
    var timer = Timer()
    let timerStringGenerator = EventCountdownTimerStringGenerator()
    let cal = EventDataSource()
    let backgroundImageView = UIImageView()
    var current: HLLEvent?
    let schoolAnalyser = SchoolAnalyser()
    
     let bArray = [UIImage(named: "Background_Light"), UIImage(named: "Background_Dark"), UIImage(named: "Background_Black")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImageView.image = bArray[0]
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        
      /*  let view = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        
        // Create a gradient layer
        let gradient = CAGradientLayer()
        
        // gradient colors in order which they will visually appear
        gradient.colors = [#colorLiteral(red: 1, green: 0.7437175817, blue: 0.02428589218, alpha: 1).cgColor, #colorLiteral(red: 0.9627912974, green: 0.3692123313, blue: 0, alpha: 1).cgColor]
        
        // Gradient from left to right
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // set the gradient layer to the same size as the view
        gradient.frame = view.bounds
        // add the gradient layer to the views layer for rendering
        view.layer.addSublayer(gradient)
        view.addSubview(timerLabel)
        view.mask = timerLabel*/
        
        // Do any additional setup after loading the view from its nib.
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        infoLabel.isHidden = true
        timerLabel.isHidden = true
        noEventOnInfoLabel.isHidden = true
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        schoolAnalyser.analyseCalendar()
        
        current = self.cal.getCurrentEvent()
        
        
        timer = Timer(fireAt: Date(), interval: 0.5, target: self, selector: #selector(timerLoop), userInfo: nil, repeats: true)
        
        
        RunLoop.main.add(timer, forMode: .common)
        
    }
    
    @objc func timerLoop () {
        
        if let currentEvent = self.current {
            
            self.timerLabel.isHidden = false
            self.infoLabel.isHidden = false
            self.noEventOnInfoLabel.isHidden = true
            self.timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: self.timerLabel.font.pointSize, weight: .thin)
            self.timerLabel.text = self.timerStringGenerator.generateStringFor(event: currentEvent)
            self.infoLabel.text = "\(currentEvent.title) \(currentEvent.endsInString) in"
            
            if currentEvent.endDate.timeIntervalSinceNow < 1 {
                
                self.current = self.cal.getCurrentEvent()
                
            }
            
        } else {
            
            self.timerLabel.isHidden = true
            self.infoLabel.isHidden = true
            self.noEventOnInfoLabel.isHidden = false
            self.noEventOnInfoLabel.text = "No Events Are On"
            
            
        }
        
        //completionHandler(NCUpdateResult.newData)
        
    }
    
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        
        let url = URL(string: "HowLongLeft://ViewCurrentEvent")!
        self.extensionContext?.open(url, completionHandler: nil)
        
    }
}
