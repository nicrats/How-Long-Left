//
//  UpcomingEventsTableViewController.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 23/2/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import UIKit
import ViewAnimator
import Hero

class UpcomingEventsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    let defaults = HLLDefaults.defaults
    let eventDatasource = EventDataSource()
    
    var events = [HLLEvent]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.willClose), name: Notification.Name("upcomingEventsViewWillClose"), object: nil)
        
        
        tableView.isHidden = true
        
        events = eventDatasource.getUpcomingEventsFromNextDayWithEvents()
        
        tableView.separatorColor = .white
        tableView.delegate = self
        tableView.dataSource = self
      
        
       // let backgroundImage = UIImage(named: "Background_Light")
       // let imageView = UIImageView(image: backgroundImage)
       // self.tableView.backgroundView = imageView
        
    }
    
    @objc func willClose() {
        
        let cells = tableView.visibleCells
        UIView.animate(views: cells, animations: [AnimationType.from(direction: .left, offset: 20)], initialAlpha: 1.0,finalAlpha: 0.0 ,duration: 0.5)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
   // setBackgroundImage()
        
        tableView.isHidden = false
        
      let cells = self.tableView.visibleCells
      //  UIView.animate(views: cells, animations: [AnimationType.from(direction: .bottom, offset: 50)], duration: 0.5)
        
        for cell in cells {
        cell.hero.modifiers = [.translate(y:100)]
        }
        
        
        
        
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! eventCell
        
        cell.generate(from: events[indexPath.row])
        
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}

class eventCell: UITableViewCell {
    
    let colourDataSource = EventDataSource()
    
    @IBOutlet weak var cellCard: DesignView!
    @IBOutlet weak var colorBox: UIView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    
    func generate(from event: HLLEvent) {
        
        colorBox.layer.cornerRadius = colorBox.frame.size.width/2
        colorBox.clipsToBounds = true
        
        colorBox.layer.borderColor = UIColor.white.cgColor
        colorBox.layer.borderWidth = 5.0
        
        eventTitleLabel.text = event.title
        
        if let loc = event.location {
            
            eventLocationLabel.isHidden = false
            eventLocationLabel.text = loc
            
        } else {
            
            eventLocationLabel.isHidden = true
            
        }
        
        
        if let cal = colourDataSource.calendarFromID(event.calendarID) {
            
            if let color = cal.cgColor {
                
                colorBox.layer.backgroundColor = color
                
            }
            
        }
        
        
        
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
        if highlighted {
            
            
            UIView.animate(withDuration: 0.4, animations: {
                
                
                self.cellCard.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                
            })
            
        } else {
            
            UIView.animate(withDuration: 0.4, animations: {
                
                
                self.cellCard.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
            })
            
        }
        
    }

    
}

class UpcomingEventParentView: UIViewController {
    
    let defaults = HLLDefaults.defaults
    
    @IBOutlet weak var upcomingLabel: UILabel!
    let bArray = [UIImage(named: "Background_Light"), UIImage(named: "Background_Dark"), UIImage(named: "Background_Black")]
    let backgroundImageView = UIImageView()
    func setBackgroundImage() {
        
        
        if defaults.bool(forKey: "useDarkBackground") == true {
            backgroundImageView.image = bArray[1]
            
        } else {
            backgroundImageView.image = bArray[0]
            
        }
        
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        backgroundImageView.removeFromSuperview()
    }
    
    @IBAction func doneTapped(_ sender: UIButton) {
        
      //  NotificationCenter.default.post(name: Notification.Name("upcomingEventsViewWillClose"), object: nil)
        
            
            self.dismiss(animated: true, completion: nil)
        
        
        
        
    }
    
    override func viewDidLoad() {
        setBackgroundImage()
       // self.hero.isEnabled = true
        //self.upcomingLabel.hero.id = "UpcomingTitle"
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return UIStatusBarStyle.lightContent
        
    }
    
    
    
}
