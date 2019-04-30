//
//  Theming.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 20/4/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import UIKit
import DeviceKit

class AppTheme {
    
    static var current: HLLTheme {
        
        get {
        
        if HLLDefaults.defaults.bool(forKey: "useDarkTheme") == true {
            
            return HLLDarkTheme()
            
        } else {
            
            return HLLDefaultTheme()
            
        }
            
        }
        
        
    }
    
    
    
}


class HLLDefaultTheme: HLLTheme {
    
    var plainColor: UIColor = .white
    
    var groupedTableViewBackgroundColor: UIColor = .groupTableViewBackground
    
    var barStyle: UIBarStyle = .default
    
    var translucentBars: Bool = true
    
    var tableCellSeperatorColor: UIColor = .gray
    
    var tableCellBackgroundColor: UIColor = .white
    
    var textColor: UIColor = .black
    
    var secondaryTextColor: UIColor = #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1)
    
    var selectedCellView: UIView? = nil
}

class HLLDarkTheme: HLLTheme {
    
    var plainColor: UIColor = .black
    
    var groupedTableViewBackgroundColor: UIColor = .black
    
    var barStyle: UIBarStyle = .black
    
    var translucentBars: Bool = false
    
    var tableCellSeperatorColor: UIColor = .darkGray
    
    var tableCellBackgroundColor: UIColor = #colorLiteral(red: 0.03044098624, green: 0.03074238215, blue: 0.03074238215, alpha: 1)
    
    var textColor: UIColor = .white
    
    var secondaryTextColor: UIColor = #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 1)
    
    var selectedCellView: UIView? {
        
        get {
            
            let bgColorView = UIView()
            bgColorView.backgroundColor = #colorLiteral(red: 0.1670962881, green: 0.1670962881, blue: 0.1670962881, alpha: 1)
            return bgColorView
            
        }
        
    }
    
}

protocol HLLTheme {
    
    var groupedTableViewBackgroundColor: UIColor { get }
    
    var plainColor: UIColor { get }
    
    var barStyle: UIBarStyle { get }
    
    var translucentBars: Bool { get }
    
    var tableCellSeperatorColor: UIColor { get }
    
    var tableCellBackgroundColor: UIColor { get }
    
    var textColor: UIColor { get }
    
    var secondaryTextColor: UIColor { get }
    
    var selectedCellView: UIView? { get }
    
}
