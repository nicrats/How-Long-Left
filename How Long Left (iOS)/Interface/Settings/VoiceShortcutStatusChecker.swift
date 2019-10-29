//
//  VoiceShortcutStatusChecker.swift
//  How Long Left
//
//  Created by Ryan Kontos on 28/1/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Intents
import IntentsUI

class VoiceShortcutStatusChecker {
    
    static let shared = VoiceShortcutStatusChecker()
    
    func check() {
        
            if #available(iOS 12.0, *) {
                
                let voiceShortcuts = INVoiceShortcutCenter.shared
                voiceShortcuts.getAllVoiceShortcuts(completion: { shortcuts, error in
                    
                    if let unwrappedShortcutArray = shortcuts, let shortcutIntent = INShortcut(intent: HowLongLeftIntent()) {
                        
                        for item in unwrappedShortcutArray {
                            
                            if item.shortcut.userActivity == shortcutIntent.userActivity {
                                voiceShortcutStore.registeredShortcut = item
                                return
                                
                            }
                            
                        }
                        
                        
                    }
                    
                    voiceShortcutStore.registeredShortcut = nil
                    
                })
                
                
            } else {
                
            }
            
        
        
    }
    
    
}
