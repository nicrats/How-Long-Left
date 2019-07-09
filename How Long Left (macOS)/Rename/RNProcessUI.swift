//
//  RNProcessUI.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 23/6/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

protocol RNProcessUI {
    
    func log(_ string: String)
    func setProgress(_ to: Double)
    func setStatusString(_ to: String)
    func processStateChanged(to: RNProcessState)
    
}

enum RNProcessState {
    
    case InProgress
    case Failed
    case Done
    
}
