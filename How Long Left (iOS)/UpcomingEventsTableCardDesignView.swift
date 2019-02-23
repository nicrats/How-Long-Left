//
//  UpcomingEventsTableCardDesignView.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 23/2/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class DesignView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0
    
    @IBInspectable var shadowColour: CGColor? = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 1
    
    @IBInspectable var shadowOpacity: Float = 0.2
    
    override func layoutSubviews() {
        
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColour
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight)
        
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        layer.shadowPath = shadowPath
    }
    
    
    
}
