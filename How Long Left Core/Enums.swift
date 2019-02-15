//
//  Enums.swift
//  How Long Left
//
//  Created by Ryan Kontos on 26/11/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

@objc enum EventFetchPeriod: Int {
    case AllToday = 0
    case UpcomingToday = 1
    case AllTodayPlus24HoursFromNow = 2
    case Next2Weeks = 3
    case ThisYear = 4
    case AnalysisPeriod = 5
}

enum EventCompletionStatus {
    case NotStarted
    case InProgress
    case Done
}

@objc enum SchoolMode: Int {
    case None = 0
    case Magdalene = 1
}

enum EventDate {
    case Start
    case End
}


enum StatusItemMode: Int {
    
    case Off = 2
    case Timer = 0
    case Minute = 1
    
}

enum StatusItemUnitsFormat: Int {
    
    case Short = 3
    case Full = 4
    
}

enum HLLHotKeyOption: Int {
    
    case Off = 2
    case OptionW = 0
    case CommandT = 1
    
}

enum calendarAccess {
    
    case Granted
    case Denied
    case Unknown
    
}
