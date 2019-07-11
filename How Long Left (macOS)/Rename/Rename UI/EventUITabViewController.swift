//
//  EventUITabViewController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 12/7/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Cocoa

class EventUITabViewController: RNUITabController, EventUITabViewControllerProtocol {

    var event: HLLEvent?
    
    
}

protocol EventUITabViewControllerProtocol {
    
    var event: HLLEvent? { get set }
    
}
