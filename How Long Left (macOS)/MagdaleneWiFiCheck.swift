//
//  MagdaleneWiFiCheck.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 17/3/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import CoreWLAN

class MagdaleneWifiCheck {

let wifiClient = CWWiFiClient()

func isOnMagdaleneWifi() -> Bool {
    
    var returnVal = false
        
        // Return whether or not the device's wifi network is Magdalene's.
        
        let wrappedSSID = wifiClient.interface(withName: nil)?.ssid()
    
        if let SSID = wrappedSSID, SSID == "NARELLAN" || SSID == "Smeaton" {
            returnVal = true
        }
    
    
    return returnVal
    
}
    
}
