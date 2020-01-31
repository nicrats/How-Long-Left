//
//  DockIconVisibilityManager.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 12/12/19.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class DockIconVisibilityManager {
    
    func checkWindows() {
        
        var visible = [NSWindow]()
              
              let windows = NSApplication.shared.windows
              
              for window in windows {
                  
                  if window.isVisible == true {
                      visible.append(window)
                  }
                  
              }
              
              if windows.count > 1 {
                  NSApp.setActivationPolicy(.regular)
              } else {
                  
                 NSApp.setActivationPolicy(.accessory)
                  
              }
              
    }
    
    
}
