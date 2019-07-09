//
//  BoizDetection.swift
//  How Long Left
//
//  Created by Ryan Kontos on 29/4/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class BoizDetection {
    
    
    
    func userIsOneOfTheBoiz() -> Bool {
        
        var returnVal = false
        
        if let deviceName = Host.current().localizedName {
            
            for name in boiz {
                
                if deviceName.lowercased().contains(text: name.lowercased()) {
                   
                    returnVal = true
                    break
                    
                }

            }
            
        }
        
        return returnVal
        
    }
    
    
    func userIsJosh() -> Bool {
        
        var returnVal = false
        
        if let deviceName = Host.current().localizedName {
            
                if deviceName.lowercased().contains(text: "niesj0") {
                    
                    returnVal = true
                    
                }
        }
        
        return returnVal
        
    }
    
    
}

enum BoizTypes {
    
    case OneOfTheBoiz
    case NotOneOfTheBoiz
    case Josh
    
}



enum Boiz: String {
    
    case Hayden = "RichardsH0"
    case Kane = "HarringtonK0"
    case Michael = "FullerM0"
    
}
