//
//  EventInfoViewController.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 10/10/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import UIKit

class EventInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var sections = [[HLLEventInfoItem]]()
    var event: HLLEvent!
    let formatter = DateComponentsFormatter()
    var distanceFromRootOccurence = 0
    var cellUpdateTimer: Timer!
    var infoItemGenerator: HLLEventInfoItemGenerator!
    
    //var activity: NSUserActivity?
    
    override func viewDidLoad() {
        
        self.navigationItem.title = self.event.title
        self.getSections()
        tableView.delegate = self
        tableView.dataSource = self
        
        /*let activityObject = NSUserActivity(activityType: "com.ryankontos.how-long-left.viewEventActivity")
        activityObject.title = event.title
        
        let id = event.identifier
        activityObject.addUserInfoEntries(from: ["EventID":id])
        //activityObject.persistentIdentifier = "ViewEvent"
        activityObject.isEligibleForHandoff = true
        
        activityObject.becomeCurrent()
        self.activity = activityObject*/
        
        
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        updateInfoRows()
        cellUpdateTimer = Timer(timeInterval: 0.25, target: self, selector: #selector(updateInfoRows), userInfo: nil, repeats: true)
        RunLoop.main.add(cellUpdateTimer, forMode: .common)
        
        if self.event?.refresh() == nil {
            self.navigationController?.popToRootViewController(animated: true)
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.activity?.resignCurrent()
        cellUpdateTimer.invalidate()
    }
    
    func getSections() {
        
        infoItemGenerator = HLLEventInfoItemGenerator(self.event)
        
        var sections = [[HLLEventInfoItem]]()
        
        sections.append(infoItemGenerator.getInfoItems(for: [.completion]))
        sections.append(infoItemGenerator.getInfoItems(for: [.location, .period]))
        sections.append(infoItemGenerator.getInfoItems(for: [.start, .end]))
        sections.append(infoItemGenerator.getInfoItems(for: [.elapsed, .duration]))
        sections.append(infoItemGenerator.getInfoItems(for: [.calendar, .teacher]))
        sections.append(infoItemGenerator.getInfoItems(for: [.nextOccurence]))
        
        self.sections = sections.filter({ !$0.isEmpty })
        
    }
    
    func setup() {
        
        DispatchQueue.main.async {
            self.navigationItem.title = self.event.title
            self.getSections()
            self.tableView.reloadData()
        }
        
    }
    
    @objc func updateInfoRows() {
        
        DispatchQueue.global(qos: .default).async {
        
        let previousEvent = self.event
            
        if let event = self.event.refresh() {
                
            // Matching event still exists
            
            if event != previousEvent {
                
                // ...But has been modified
                
                self.setup()
            }
                
        } else {
            
            // Matching event no longer exists
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
            
        }
  
        let previousSections = self.sections
        self.getSections()
           
        if self.sections != previousSections {
            self.setup()
        }
        
        }
        
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            let height = view.bounds.height*0.18
            
            if height < 100 {
                
                return 100
                
            } else {
                
                return height
                
            }
            
        } else {
            
            let realSection = indexPath.section-1
            let pair = sections[realSection][indexPath.row]
            
            if pair.type == .nextOccurence {
                return 64
            } else {
                return 43
            }
            
        }
    }
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if section == 0 {
            return 1
        }
    
        let realSection = section-1
        return sections[realSection].count
    
      }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count+1
    }
    
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimerCell", for: indexPath) as! TimerCell
            cell.setup(with: self.event)
            return cell
    
        }
        
        let realSection = indexPath.section-1
        
        let pair = sections[realSection][indexPath.row]
        
        if pair.type == .nextOccurence {
            
            let id = "DoubleHeightEventInfoItemCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! DoubleHeightEventInfoItemCell
            cell.setUp(infoType: pair.title, infoString: pair.info)
            return cell
            
        } else {
            
           let id = "RegularHeightEventInfoItemCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! RegularHeightEventInfoItemCell
            cell.setUp(infoType: pair.title, infoString: pair.info)
            return cell
            
        }
        
        
      }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = getInfoItemFor(indexPath: indexPath), item.type == .nextOccurence, let next = event.followingOccurence {
            
            let distance = self.distanceFromRootOccurence+1
            
            let infoView = EventInfoViewGenerator.shared.generateEventInfoView(for: next, distanceFromRootOccurence: distance)
    
            self.navigationController?.pushViewController(infoView, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func getInfoItemFor(indexPath: IndexPath) -> HLLEventInfoItem? {
        
        let realSection = indexPath.section-1
        if sections.indices.contains(realSection) {
            
            let section = sections[realSection]
            
            if section.indices.contains(indexPath.row) {
                
                return section[indexPath.row]
                
            }
            
        }
        
        return nil
        
    }
    
}

@available(iOS 13.0, *)
extension EventInfoViewController {
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let realSection = indexPath.section-1
        
        if let followingOccurence = self.event.followingOccurence, sections.indices.contains(realSection), sections[realSection].indices.contains(indexPath.row), sections[realSection][indexPath.row].type == .nextOccurence {

            let distance = self.distanceFromRootOccurence+1
            
            let config = UIContextMenuConfiguration(identifier: NSString("FollowingOccurence"),
                                              previewProvider: {
                                                
                                                
                                                  return EventInfoViewGenerator.shared.generateEventInfoView(for: followingOccurence, distanceFromRootOccurence: distance)
                                                
            },
                                                actionProvider: { _ in
                                                return HLLEventContextMenuGenerator.shared.generateContextMenuForEvent(followingOccurence)  })
            
        return config
            
        }
        
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        
        if configuration.identifier as? String == "FollowingOccurence" {
        
        animator.addCompletion {
            
            if let followingOccurence = self.event.followingOccurence {
            
                let distance = self.distanceFromRootOccurence+1
            
                let viewController = EventInfoViewGenerator.shared.generateEventInfoView(for: followingOccurence, distanceFromRootOccurence: distance)
                
                self.navigationController?.pushViewController(viewController, animated: true)

                
            }
            
            }
            
        }
        
    }
    
}

protocol EventInfoItemCell {
    func setUp(infoType: String, infoString: String)
}
