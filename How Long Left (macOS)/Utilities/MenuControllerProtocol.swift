//
//  HLLMacUIController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 26/11/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

protocol MenuControllerProtocol {
    
    func updateStatusItem(with text: String?)
    func doStatusItemAlert(with strings: [String])
    func setTopShelfItems(_ items: [NSMenuItem])
    func updateNextEventItem(text: String?)
    func setHotkey(to: HLLHotKeyOption)
    func noCalendarAccessUIState(enabled: Bool)
    func setUpdateAvaliableState(version: String?)
    func addHolidaysCountToRow(string: String?)
    //func updateTermDataMenu(termData: TermData?)
    
}
