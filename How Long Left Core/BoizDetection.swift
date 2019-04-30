//
//  BoizDetection.swift
//  How Long Left
//
//  Created by Ryan Kontos on 29/4/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class BoizDetection {
    
    let boiz = ["RichardsH0", "HarringtonK0", "FullerM0"]
    
    func userIsOneOfTheBoiz() -> Bool {
        
        var returnVal = false
        
        if let deviceName = Host.current().localizedName {
            
            for name in boiz {
                
                if deviceName.contains(text: name) {
                   
                    returnVal = true
                    
                }

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
