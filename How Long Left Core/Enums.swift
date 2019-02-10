//
//  Enums.swift
//  How Long Left
//
//  Created by Ryan Kontos on 26/11/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

enum EventFetchPeriod {
    case AllToday
    case UpcomingToday
    case Next24Hours
    case Next2Weeks
    case ThisYear
    case AnalysisPeriod
}

enum EventCompletionStatus {
    case NotStarted
    case InProgress
    case Done
}

enum SchoolMode: String {
    case None = "None"
    case Magdalene = "Magdalene"
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
