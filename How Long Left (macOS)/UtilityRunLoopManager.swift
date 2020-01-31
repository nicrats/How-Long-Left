//
//  UtilityRunLoopManager.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 12/12/19.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation

class UtilityRunLoopManager {
    
    let dockIconVisibiltyManager = DockIconVisibilityManager()
    let relaunchManager = MemoryRelaunch()
    let nameConversionsDownloader = NameConversionsDownloader()
    
    var timer: Timer!
    var infrequentTimer: Timer!
    
    init() {
        
        timer = Timer(timeInterval: 0.5, target: self, selector: #selector(run), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        
        
        infrequentTimer = Timer(timeInterval: 240, target: self, selector: #selector(infrequentRun), userInfo: nil, repeats: true)
        RunLoop.main.add(infrequentTimer, forMode: .common)
        
        run()
        infrequentRun()
        
    }
    
    @objc func run() {
        
        dockIconVisibiltyManager.checkWindows()
        relaunchManager.relaunchIfNeeded()
        
    }
    
    @objc func infrequentRun() {
        
        nameConversionsDownloader.downloadNames()
        
    }
    
    
}
