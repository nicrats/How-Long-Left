//
//  Extensions.swift
//  How Long Left
//
//  Created by Ryan Kontos on 16/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//


import Foundation
import EventKit

extension String {
  
    func contains(text: String) -> Bool {
        if self.range(of:text) != nil {
            return true
        } else {
            return false
        }
    }
    
    func containsAnyOfThese(Strings: [String]) -> Bool {
        
        var r = false
        
        for text in Strings {
            
            if self.range(of:text) != nil {
                r = true
            }
        }
        
        return r
        
    }
    
        /**
         Truncates the string to the specified length number of characters and appends an optional trailing string if longer.
         
         - Parameter length: A `String`.
         - Parameter trailing: A `String` that will be appended after the truncation.
         
         - Returns: A `String` object.
         */

        enum TruncationPosition {
            case head
            case middle
            case tail
        }
        
        func truncated(limit: Int, position: TruncationPosition = .tail, leader: String = "...") -> String {
            guard self.count > limit else { return self }
            
            switch position {
            case .head:
                return leader + self.suffix(limit)
            case .middle:
                let headCharactersCount = Int(ceil(Float(limit - leader.count) / 2.0))
                
                let tailCharactersCount = Int(floor(Float(limit - leader.count) / 2.0))
                
                return "\(self.prefix(headCharactersCount))\(leader)\(self.suffix(tailCharactersCount))"
            case .tail:
                return self.prefix(limit) + leader
            }
        }

    
    
}

extension Collection {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Date {
    
    func formattedTime() -> String {
        
        let dateFormatter  = DateFormatter()
        dateFormatter.dateFormat = "h:mma"
        return dateFormatter.string(from: self)
        
    }
    
    func formattedDate() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter.string(from: self)
        
    }
    
    func year() -> Int {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        
        return Int(dateFormatter.string(from: self))!
        
    }
    
    func midnight() -> Date {
        
        let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        return cal.startOfDay(for: self)
        
    }
    
}
