//
//  RenameTabController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 21/6/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class RNUITabController: NSTabViewController, ControllableTabView {
    
    
    func goToIndex(_ tabIndex: Int) {
        
        DispatchQueue.main.async {
        
            [unowned self] in
            
        if tabIndex < self.tabView.tabViewItems.count, tabIndex > -1 {
            
            self.tabView.selectTabViewItem(at: tabIndex)
            
        }
            
        }
    }
    

    func previousPage() {
        
        DispatchQueue.main.async {
        
            [unowned self] in
            
            let index = self.indexOfSelectedItem()-1
        
        if index < self.tabView.tabViewItems.count, index > -1 {
            
            self.tabView.selectTabViewItem(at: index)
            
        }
            
        }
    }
    
    
    func nextPage() {
        
        DispatchQueue.main.async {
        
            
            
            [unowned self] in
            
            let index = self.indexOfSelectedItem()+1
        
        if index < self.tabView.tabViewItems.count, index > -1 {
            
            self.tabView.selectTabViewItem(at: index)
            
        }
        
        }
    }
    
    func indexOfSelectedItem() -> Int {
        
        let current = tabView.selectedTabViewItem!
        let index = tabView.indexOfTabViewItem(current)
        return index
        
        
    }
    
     private lazy var tabViewSizes: [String : NSSize] = [:]
    
    
 override func viewDidLoad() {
        super.viewDidLoad()
    
   NSApp.activate(ignoringOtherApps: true)
    let items = tabViewItems
    var newItems = [NSTabViewItem]()
    
    for item in items {
        
        let newTVItem = item
        
        if var newVCItem = item.viewController as? ControllerTab {
            
            newVCItem.delegate = self
            newTVItem.viewController = newVCItem as? NSViewController
            newItems.append(newTVItem)
            
            
        } else {
            
            newItems.append(newTVItem)
            
        }
        
        
    }
    
    tabViewItems = newItems
        
    
    }
    
    
}

protocol ControllableTabView {
    
    func nextPage()
    func previousPage()
    func goToIndex(_ tabIndex: Int)
    
}

protocol ControllerTab {

    
    var delegate: ControllableTabView? { get set }
    


}
