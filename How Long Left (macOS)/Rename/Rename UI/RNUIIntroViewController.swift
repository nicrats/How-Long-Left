//
//  RNUIIntroViewController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 9/7/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class RNUIIntroViewController: NSViewController, ControllerTab {
    
    var delegate: ControllableTabView?
    
    func setSharedItem(to: Any) {
    }
    
    @IBAction func neverClicked(_ sender: NSButton) {
        
        HLLDefaults.rename.promptToRename = false
        close()
        
    }
    
    @IBAction func notNowClicked(_ sender: NSButton) {
        
        close()
        
    }
    
    func close() {
        
        self.view.window?.performClose(nil)
    }
    
    @IBAction func continueClicked(_ sender: NSButton) {
        
        delegate?.nextPage()
        
    }
    
    
}
