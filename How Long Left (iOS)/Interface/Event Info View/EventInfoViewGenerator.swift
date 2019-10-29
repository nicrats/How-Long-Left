//
//  EventInfoViewGenerator.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 10/10/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import UIKit

class EventInfoViewGenerator {
    
    static var shared = EventInfoViewGenerator()
    
    func generateEventInfoView(for event: HLLEvent, distanceFromRootOccurence: Int = 0) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view = storyboard.instantiateViewController(withIdentifier: "EventInfoView") as! EventInfoViewController
        view.distanceFromRootOccurence = distanceFromRootOccurence
        view.event = event
        return view
        
    }
    
}
