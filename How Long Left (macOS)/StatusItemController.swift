//
//  StatusItemController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 27/1/20.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class StatusItemController: NSObject, NSMenuDelegate {
    
    var statusItemTextHander: StatusItemUpdateHandler!
    var menuUpdateHandler = MenuUpdateHandler()
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let SIAttribute = [ NSAttributedString.Key.font: NSFont.monospacedDigitSystemFont(ofSize: 14.0, weight: .regular)]
    let basicIcon = NSImage(named: "statusIcon")!
    let colourIcon = NSImage(named: "ColourSI")!
    var doingStatusItemAlert = false
    var currentStatusItemText: String?
    var statusItemIsEmpty = false
    
    var icon: NSImage {
        get {
            if HLLDefaults.statusItem.appIconStatusItem {
                return colourIcon
            } else {
                return basicIcon
            }
           }
       }
       
       var statusItemImageIsTemplate: Bool {
        get {
            if HLLDefaults.statusItem.appIconStatusItem {
                return false
            } else {
                return true
            }
           }
       }
    
    override init() {
      
        super.init()
        
        self.statusItem.button?.imagePosition = .imageOnly
        self.statusItem.target = self
        
        let menu = NSMenu()
        menu.delegate = self
        
        self.statusItem.menu = menu
        
        self.icon.isTemplate = self.statusItemImageIsTemplate
        updateStatusItem(with: nil)
        
        DispatchQueue.main.async {
            
            self.statusItemTextHander = StatusItemUpdateHandler(delegate: self)
        }
        
        
        
        
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        while HLLEventSource.updatingEventPool {
            
        }
        
        let items = self.menuUpdateHandler.getMainMenu()
        
        menu.removeAllItems()
        
        for item in items {
            
            menu.addItem(item)
            
        }
        
    }
    
   /* @objc func statusItemClicked() {
        
        let startDate = Date()
            
        let endDate = Date()
        
        print("Menu generation took \(endDate.timeIntervalSince(startDate))s")
        
            
        self.statusItem.popUpMenu(menu)
                
    }*/
    
    func updateStatusItem(with text: String?, selected: Bool = false) {
        
        if self.doingStatusItemAlert == false {
        
        if let unwrappedText = text, HLLDefaults.statusItem.mode != .Off {
            
                DispatchQueue.main.async {
                    
                    [unowned self] in
                    
                    self.statusItem.button?.imagePosition = .imageLeading
                    
                    if selected {
                        
                        if #available(OSX 10.14, *) {
                        
                            self.statusItem.button?.image = NSImage(named: NSImage.menuOnStateTemplateName)
                            
                        } else {
                            
                            self.statusItem.image = NSImage(named: NSImage.menuOnStateTemplateName)
                            
                            
                        }
                        
                        self.icon.isTemplate = true
                        
                    } else {
                        
                        if #available(OSX 10.14, *) {
                        
                            self.statusItem.button?.image = nil
                            
                        } else {
                            
                            self.statusItem.image = nil
                            
                        }
                        self.icon.isTemplate = self.statusItemImageIsTemplate
                        
                    }
                    
                if #available(OSX 10.14, *) {
                
                    self.statusItem.button?.attributedTitle = NSAttributedString(string: unwrappedText, attributes: self.SIAttribute)
                
                } else {
                    
                    self.statusItem.attributedTitle = NSAttributedString(string: unwrappedText, attributes: self.SIAttribute)

                }
                    
                    self.currentStatusItemText = unwrappedText
                    self.statusItemIsEmpty = false
                    
                }
        
        } else {
                
            DispatchQueue.main.async {
            
                [unowned self] in
                
            if #available(OSX 10.14, *) {
                
                if self.statusItem.button?.title != nil {
            
                self.statusItem.button?.imagePosition = .imageOnly
                self.statusItemIsEmpty = true
                self.statusItem.button?.title = ""
                self.statusItem.button?.image = self.icon
                self.icon.isTemplate = self.statusItemImageIsTemplate
                
            }
                
        } else {
                
            if self.statusItem.title != nil {
                
                self.statusItem.button?.imagePosition = .imageOnly
                self.statusItemIsEmpty = true
                self.statusItem.attributedTitle = nil
                self.statusItem.image = self.icon
                self.icon.isTemplate = self.statusItemImageIsTemplate
                    
        }
                
        }
                
            }
            
            
            
        }
        
    }
            
    }
    
    
}
