//
//  RootViewController.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 4/4/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import UIKit
import StoreKit
import EventKit

class RootViewController: UITabBarController, UITabBarControllerDelegate, EventDataSourceDelegate {
    
    static var shared: RootViewController?
    static var selectedController: UIViewController?
    
   
    
    var prev: UIViewController?
    
    var gotComplicationPrice = false
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if self.selectedViewController == viewController, viewController == prev {
            
            if let nav = viewController as? UINavigationController {
                
                if let vc = nav.topViewController as? ScrollUpDelegate {
                
                vc.scrollUp()
                    
                }
                
                
            }
            
        }
        
        prev = viewController
        
    }
    
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
        
        
        self.prev = self.selectedViewController
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showIAPSuggestion), name: Notification.Name("gotComplicationPrice"), object: nil)
        
        self.delegate = self
        
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
    
    @objc func showIAPSuggestion() {
        
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                
                if EventDataSource.accessToCalendar == .Granted {
                
                self.dataSource = EventDataSource(with: self)
                
                if let safeSession = WatchSessionManager.sharedManager.validSession, safeSession.isPaired == true {
                
                
                if IAPHandler.shared.hasPurchasedComplication() == false, HLLDefaults.defaults.bool(forKey: "ShownIAPSuggestion") == false, IAPHandler.complicationPriceString != nil {
                    
                    
                    
                    if self.gotComplicationPrice == false {
                        
                        HLLDefaults.defaults.set(true, forKey: "ShownIAPSuggestion")
                    
                        self.gotComplicationPrice = true
                        
                    let vc = AppFunctions.shared.getPurchaseComplicationViewController()
                    
                    self.present(vc, animated: true, completion: nil)
                        
                    }
                }
                    
                    if SchoolAnalyser.privSchoolMode == .Magdalene {
                        
                        HLLDefaults.defaults.set(true, forKey: "ShownIAPSuggestion")
                        
                    }
                    
                }
                    
                }
                
            })
        
        
                
        
        
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
    
    
    func showComplicationPurchasedFailedAlert() {
        
        var errorReasonString: String? = "Please try again"
        
        if let error = IAPHandler.recentTransaction?.error as? SKError {
            
            switch error.code {
                
            case .unknown:
                break
            case .clientInvalid:
                break
            case .paymentCancelled:
                errorReasonString = nil
            case .paymentInvalid:
                errorReasonString = "Invalid payment"
            case .paymentNotAllowed:
                errorReasonString = "Invalid payment"
            case .storeProductNotAvailable:
                errorReasonString = "The product is not avaliable"
            case .cloudServicePermissionDenied:
                errorReasonString = "Could could connect to the App Store."
            case .cloudServiceNetworkConnectionFailed:
                errorReasonString = "Could could connect to the App Store."
            case .cloudServiceRevoked:
                errorReasonString = "Could could connect to the App Store."
            case .privacyAcknowledgementRequired:
                errorReasonString = nil
            case .unauthorizedRequestData:
                break
            case .invalidOfferIdentifier:
                break
            case .invalidSignature:
                break
            case .missingOfferParams:
                break
            case .invalidOfferPrice:
                break
            @unknown default:
                break
            }
        }
        
        if let reason = errorReasonString {
        
            let alertController = UIAlertController(title: "Purchase Failed", message: reason, preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action1)
        alertController.view.tintColor = UIColor.HLLOrange
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
            
            }
        }
        
    }
    
    func showComplicationPurchasedAlert(purchasedNow: Bool, restored: Bool = false) {
        
        var message = "You may need to launch How Long Left on your watch to trigger changes."
        var titleText = "You've purchased the Apple Watch Complication"
        
        if purchasedNow {
            
            titleText = "Purchase Successful!"
            
        } else {
            
            if SchoolAnalyser.privSchoolMode == .Magdalene {
                
                titleText = "Apple Watch Complication is enabled"
                message = "As a Magdalene user, you have access to the complication for free."
                
            }
            
        }
        
        if restored == true {
            
            titleText = "Restore Successful!"
            
        }
        
        
        let alertController = UIAlertController(title: titleText, message: message, preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action1)
        alertController.view.tintColor = UIColor.HLLOrange
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
        
        
    }


}

enum TabBarPage: Int {
    
    case Current = 0
    case Upcoming = 1
    case Settings = 2
    
}



protocol ScrollUpDelegate {
    func scrollUp()
}


extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return AppTheme.current.statusBarStyle
    }
}
