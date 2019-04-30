//
//  IAPOnboardViewController.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 13/4/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import UIKit
import Foundation


class IAPRootView: UIViewController {
    
    
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var infoText: UILabel!
    
    
    override func viewDidLoad() {
        
   // let image = #imageLiteral(resourceName: "Background_Light")
        
      //  buyButton.setBackgroundImage(image, for: UIControl.State.normal)
        
        self.view.backgroundColor = AppTheme.current.plainColor
        infoText.textColor = AppTheme.current.textColor
        
        self.buyButton.layer.cornerRadius = 8.0
        self.buyButton.layer.masksToBounds = true
        
        self.buyButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        
       // self.buyButton.setBackgroundImage(image, for: .normal)
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func buyTapped(_ sender: UIButton) {
        
        
        SettingsMainTableViewController.justPurchasedComplication = true
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
            
            self.dismiss(animated: true, completion: nil)
            
        })
            
    }
    
}
