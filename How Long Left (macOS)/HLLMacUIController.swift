//
//  HLLMacUIController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 26/11/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

protocol HLLMacUIController {
    
    func updateStatusItem(with text: String?)
    func doStatusItemAlert(with strings: [String])
    func addCurrentEventRows(with strings: [(String, String?, HLLEvent?, HLLEvent?)], updateNextOccurs: Bool)
    func updateExistingCurrentEventRows(with strings: [(String, String?, HLLEvent?, HLLEvent?)])
    func updateNextEventItem(text: String?)
    func updateUpcomingEventsMenu(data: upcomingDayOfEvents?)
    func updateUpcomingWeekMenu(data: [upcomingDayOfEvents])
    func setHotkey(to: HLLHotKeyOption)
    func noCalendarAccessUIState(enabled: Bool)
    func setUpdateAvaliableState(version: String?)
    func addHolidaysCountToRow(string: String?)
    func updateTermDataMenu(termData: TermData?)
    
}
