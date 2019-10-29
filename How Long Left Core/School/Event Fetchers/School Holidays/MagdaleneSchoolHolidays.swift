//
//  SchoolHolidayPeriodsStore.swift
//  How Long Left
//
//  Created by Ryan Kontos on 1/12/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class SchoolHolidayPeriodsStore {
    
    var holidayPeriods = [SchoolHolidaysPeriod]()
    
    init() {
        
        let start = NSDateComponents()
        let end = NSDateComponents()
        
        // Term 2 Holidays 2019
        
        start.year = 2019
        start.month = 7
        start.day = 4
        start.hour = 14
        start.minute = 35
        start.second = 00
        
        end.year = 2019
        end.month = 7
        end.day = 22
        //end.day = 17
        end.hour = 8
        end.minute = 15
        end.second = 00
        holidayPeriods.append(SchoolHolidaysPeriod(startComp: start, endComp: end, term: 2))
        
        // Term 3 Holidays 2019
        
        start.year = 2019
        start.month = 9
        start.day = 27
        start.hour = 14
        start.minute = 35
        start.second = 00
        
        end.year = 2019
        end.month = 10
        end.day = 14
        end.hour = 8
        end.minute = 15
        end.second = 00
        holidayPeriods.append(SchoolHolidaysPeriod(startComp: start, endComp: end, term: 3))
        
        // Term 4 Holidays 2019
        
        start.year = 2019
        start.month = 12
        start.day = 20
        start.hour = 14
        start.minute = 35
        start.second = 00
        
        end.year = 2020
        end.month = 1
        end.day = 29
        end.hour = 8
        end.minute = 15
        end.second = 00
        holidayPeriods.append(SchoolHolidaysPeriod(startComp: start, endComp: end, term: 4))
        
    }
    
}
