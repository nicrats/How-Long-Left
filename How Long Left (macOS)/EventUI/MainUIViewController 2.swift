//
//  MainUIViewController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 1/7/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Cocoa

class MainUIViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    @IBOutlet weak var titleLabel: NSTextField!
    
    var event: HLLEvent?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        if let uEvent = event {
            
            titleLabel.stringValue = uEvent.title
            
        }
    }
    
    
    
}

