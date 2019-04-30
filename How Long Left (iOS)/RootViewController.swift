//
//  RootViewController.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 4/4/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import UIKit

class RootViewController: UITabBarController, EventDataSourceDelegate {
    
    static var shared: RootViewController?
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        return
    }
    
    var currentPage: TabBarPage {
        
        get {
            
            return TabBarPage(rawValue: self.selectedIndex)!
            
        }
        
    }
    
    var dataSource: EventDataSource?
    let cal = EventDataSource()
    static var hasLaunched = false
    let schoolAnalyser = SchoolAnalyser()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        RootViewController.shared = self
        
        if RootViewController.hasLaunched == false {
        
            schoolAnalyser.analyseCalendar()
            
            RootViewController.hasLaunched = true
            
        if let launchPage = AppDelegate.launchPage {
            
            setSelectedPage(to: launchPage)
            
            
        } else if cal.getCurrentEvents().isEmpty, cal.getUpcomingEventsFromNextDayWithEvents().isEmpty == false {
            
           setSelectedPage(to: .Upcoming)
            
        } else {
            
            setSelectedPage(to: .Current)
            
        }
            
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            
            self.dataSource = EventDataSource(with: self)
            
            if self.currentPage != .Settings {
                
               // let vc = AppFunctions.shared.getPurchaseComplicationViewController()
                
              //  self.present(vc, animated: true, completion: nil)
            }
            
            
        })
        
        
        DispatchQueue.main.async {
            
            self.viewControllers?.forEach {
                if let navController = $0 as? UINavigationController {
                    let _ = navController.topViewController?.view
                } else {
                   let _ = $0.view.description
                }
            }
            
        }
        
    }
    
    @objc func updateTheme() {
    
      /*  self.navigationController?.navigationBar.barStyle = AppTheme.currentTheme.barStyle
        self.tabBar.barStyle = AppTheme.currentTheme.barStyle
        self.navigationController?.navigationBar.isTranslucent = AppTheme.currentTheme.translucentBars
        self.tabBar.isTranslucent = AppTheme.currentTheme.translucentBars
        self.tabBar.barStyle = AppTheme.currentTheme.barStyle */
        
    }
    
    func setSelectedPage(to page: TabBarPage) {
        
        self.selectedIndex = page.rawValue
        
    }
    
    func calendarAccessDenied() {
        let alertController = UIAlertController(title: "How Long Left does not have permission to access your calendar", message: "You can grant it in Settings.", preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Settings", style: .default) { (action:UIAlertAction) in
            if let url = URL(string:UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: { success in
                    })
                }
            }
        }
        
        let action2 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
        }
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.view.tintColor = UIColor.HLLOrange
        self.present(alertController, animated: true, completion: nil)
        
    }

}

enum TabBarPage: Int {
    
    case Current = 0
    case Upcoming = 1
    case Settings = 2
    
}



