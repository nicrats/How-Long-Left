//
//  ComplicationGenerator.swift
//  How Long Left (watchOS) Extension
//
//  Created by Ryan Kontos on 16/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import ClockKit
import EventKit

class ComplicationContentsGenerator {

    let cal = EventDataSource.shared
    
    init() {
        
        SchoolAnalyser.shared.analyseCalendar()
        
    }
    
    func generateComplicationText(complication: CLKComplication) -> [CLKComplicationTimelineEntry] {
        
        var returnArray = [CLKComplicationTimelineEntry]()
        
       let items = generateComplicationItems()
        
        
        
        for item in items {
            
            returnArray.append(contentsOf: generateComplicationEntry(complication: complication, data: item))
            
        }
        
        return returnArray
        
    }
    
    func generateComplicationEntry(complication: CLKComplication, data: HLLComplicationEntry) -> [CLKComplicationTimelineEntry] {
        
        if data.event == nil {
            
            return generateNoEventOnComlicationText(complication: complication, data: data)
            
        } else {
            
            return generateEventOnComlicationText(complication: complication, data: data)
            
        }
        
    }
    
    func generateComplicationItems() -> [HLLComplicationEntry] {
        
        HLLDefaults.defaults.set("Update started", forKey: "ComplicationDebug")
        HLLDefaults.defaults.set(Date().formattedTime(), forKey: "ComplicationDebugTime")
        
        var events = cal.fetchEventsFromPresetPeriod(period: .AllTodayPlus24HoursFromNow)
        
        
        events.sort(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
        
        
        var startDatesArray = [Date]()
        var endDatesArray = [Date]()
        
        for event in events {
            
            startDatesArray.append(event.startDate)
            endDatesArray.append(event.endDate)
            
            if event.completionStatus == .Done {
                
                if let index = events.firstIndex(of: event) {
                    
                    events.remove(at: index)
                    
                }
                
            }
            
        }
        
        if events.isEmpty {
            
            HLLDefaults.defaults.set("No events", forKey: "ComplicationDebug")
            
        } else {
            
            HLLDefaults.defaults.set("\(events.count) Events found", forKey: "ComplicationDebug")
            
        }
        
        //    var processedEvents = [HLLEvent]()
        
        var dictOfAdded = [Date:HLLEvent]()
        
        var returnItems = [HLLComplicationEntry]()
        
        for item in events {
            
            
            
            if let start = getSoonestEndingEvent(at: item.startDate, from: events) {
                
                let next = getNextEvent(after: start, events: events)
                
                print("CompSim1: \(item.startDate.formattedTime()): \(start.title), Next: \(String(describing: next?.title))")
                returnItems.append(HLLComplicationEntry(date: item.startDate, event: start, next: next))
                dictOfAdded[item.startDate] = start
                
                
                
                
            } else {
                
                let nextEv = getNextEventToStart(after: item.startDate, from: events)
                print("CompSim2: \(item.startDate.formattedTime()): No events are on")
                returnItems.append(HLLComplicationEntry(date: item.endDate, event: nil, next: nextEv))
                
            }
            
            if let end = getSoonestEndingEvent(at: item.endDate, from: events) {
                
                
                let next = getNextEvent(after: end, events: events)
                
                print("CompSim3: \(item.endDate.formattedTime()): \(end.title), Next: \(String(describing: next?.title))")
                returnItems.append(HLLComplicationEntry(date: item.endDate, event: end, next: next))
                dictOfAdded[item.endDate] = end
                
                
                
            } else {
                
                let nextEv = getNextEventToStart(after: item.endDate, from: events)
                print("CompSim4: \(item.endDate.formattedTime()): No events are on")
                returnItems.append(HLLComplicationEntry(date: item.endDate, event: nil, next: nextEv))
                
                
            }
            
            if cal.getCurrentEvents().isEmpty == true {
                
                print("CompSim5: \(Date().formattedTime()): No event is on")
                returnItems.append(HLLComplicationEntry(date: Date(), event: nil, next: events.first))
                
            }
            
            
        }
        
        if returnItems.isEmpty == true {
            
            
            
            print("CompSim6: \(Date().formattedTime()): No event is on")
            returnItems.append(HLLComplicationEntry(date: Date(), event: nil, next: events.first))
            HLLDefaults.defaults.set("returnItems empty", forKey: "ComplicationDebug")
        }
        
        returnItems.sort(by: { $0.showAt.compare($1.showAt) == .orderedAscending })
        
        CompDefaults.shared.saveEventsAsLastComplicationUpdate(events: events)
        
        return returnItems
    }
    
    func getCurrentEntry(for complication: CLKComplication) -> CLKComplicationTimelineEntry? {
        
        var events = cal.fetchEventsFromPresetPeriod(period: .AllTodayPlus24HoursFromNow)
        events.sort(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
        
        var startDatesArray = [Date]()
        var endDatesArray = [Date]()
        
        for event in events {
            
            startDatesArray.append(event.startDate)
            endDatesArray.append(event.endDate)
            
            if event.completionStatus == .Done {
                
                if let index = events.firstIndex(of: event) {
                    
                    events.remove(at: index)
                    
                }
                
            }
            
        }
        
        let next = getNextEventToStart(after: Date(), from: events)
        
        var entry = HLLComplicationEntry(date: Date(), event: nil, next: next)
    
        if let event = getSoonestEndingEvent(at: Date(), from: events) {
            
            if event.startDate.timeIntervalSinceNow < 1 {
                
                entry = HLLComplicationEntry(date: event.startDate, event: event, next: next)
                
            }
            
            
        }
        
        if entry.event == nil {
            
            return generateNoEventOnComlicationText(complication: complication, data: entry).last
            
        } else {
            
            return generateEventOnComlicationText(complication: complication, data: entry).last
            
        }
        
        
        
    }
    
    func generateNoEventOnComlicationText(complication: CLKComplication, data: HLLComplicationEntry) -> [CLKComplicationTimelineEntry] {
        
        
        var returnArray = [CLKComplicationTimelineEntry]()
        var entryItem: CLKComplicationTemplate?
        
        switch complication.family {
        case .circularSmall:
            break
        case .modularSmall:
            
           break
            
        case .modularLarge:
            
            let entry = CLKComplicationTemplateModularLargeStandardBody()
            
             var updatedTimeText = "Tap to refresh"
            
            entry.headerTextProvider.tintColor = #colorLiteral(red: 0.9944762588, green: 0.3928351742, blue: 0.08257865259, alpha: 1)
            
            if let next = data.nextEvent {
                
                
                
                entry.headerTextProvider = CLKSimpleTextProvider(text: "\(next.title) starts in")
                
                if let col = next.calendar?.cgColor {
                    
                    let uiCOl = UIColor(cgColor: col)
                    
                    entry.headerTextProvider.tintColor = uiCOl
                    
                }
                
                 entry.body1TextProvider = CLKRelativeDateTextProvider(date: next.startDate, style: .natural, units: [.day, .hour, .minute])
                
               // entry.body1TextProvider = CLKSimpleTextProvider(text: "Next: \(next.title)")
                
                if let loc = next.location {
                    
                    updatedTimeText = loc
                    
                    
                }
                
                
            } else {
                
                entry.headerTextProvider = CLKSimpleTextProvider(text: "No events on")
                entry.body1TextProvider = CLKSimpleTextProvider(text: "No upcoming today")
                
            }
            /*   let date = Date()
             let dateFormatter  = DateFormatter()
             dateFormatter.dateFormat = "hh:mm a"
             let dateInString = dateFormatter.string(from: date) */
            
            entry.body2TextProvider = CLKSimpleTextProvider(text: updatedTimeText)
            
            entry.body1TextProvider.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            entry.body2TextProvider!.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
             entryItem = entry
            
        case .utilitarianSmall:
            break
        case .utilitarianSmallFlat:
            
           break
        case .utilitarianLarge:
            
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKSimpleTextProvider(text: "No event is on")
             entryItem = template
            
        case .extraLarge:
            break
        case .graphicCorner:
            
            let imageP = CLKFullColorImageProvider(fullColorImage: UIImage(named: "GraphicCorner_NoEvent")!)
            
            if let nex = data.nextEvent {
               
                let nextTemp = CLKComplicationTemplateGraphicCornerStackText()
                nextTemp.innerTextProvider = CLKSimpleTextProvider(text: "\(nex.title) starts in")
                
                if let col = nex.calendar?.cgColor {
                    
                    let uiCOl = UIColor(cgColor: col)
                    
                    nextTemp.innerTextProvider.tintColor = uiCOl
                    
                }
                
                nextTemp.outerTextProvider = CLKRelativeDateTextProvider(date: nex.startDate, style: .naturalAbbreviated, units: [.day, .hour, .minute])
                
                
            } else {
            
           let temp = CLKComplicationTemplateGraphicCornerTextImage()
           temp.textProvider = CLKSimpleTextProvider(text: "No event is on")
            temp.textProvider.tintColor = #colorLiteral(red: 0.9944762588, green: 0.3928351742, blue: 0.08257865259, alpha: 1)
           temp.imageProvider = imageP
            entryItem = temp
                
            }
            
            
            
            
            
        case .graphicBezel:
        
            let circTemp = CLKComplicationTemplateGraphicCircularImage()
            
            circTemp.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "GraphicCircular")!)
            let temp = CLKComplicationTemplateGraphicBezelCircularText()
            temp.textProvider = CLKSimpleTextProvider(text: "No event is on")
            temp.circularTemplate = circTemp
            
            entryItem = temp
            
        case .graphicCircular:
            
            let circTemp = CLKComplicationTemplateGraphicCircularImage()
            
            circTemp.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "GraphicCircular")!)
            
            entryItem = circTemp
    
        case .graphicRectangular:
            
            let entry = CLKComplicationTemplateGraphicRectangularStandardBody()
            entry.headerTextProvider = CLKSimpleTextProvider(text: "No event is on")
            
            var updatedTimeText = "Tap to refresh"
            
            entry.headerTextProvider.tintColor = #colorLiteral(red: 0.9944762588, green: 0.3928351742, blue: 0.08257865259, alpha: 1)
            
            if let next = data.nextEvent {
                
                
                
                entry.headerTextProvider = CLKSimpleTextProvider(text: "\(next.title)")
                
                if let col = next.calendar?.cgColor {
                    
                    let uiCOl = UIColor(cgColor: col)
                    
                    entry.headerTextProvider.tintColor = uiCOl
                    
                }
                
                var providers = [CLKTextProvider]()
                providers.append(CLKSimpleTextProvider(text: "In "))
                
                
                
                providers.append(CLKRelativeDateTextProvider(date: next.startDate, style: .natural, units: [.day, .hour, .minute]))
            
                entry.body1TextProvider = CLKTextProvider(byJoining: providers, separator: nil)
                
                // entry.body1TextProvider = CLKSimpleTextProvider(text: "Next: \(next.title)")
                
                if let loc = next.location {
                    
                    updatedTimeText = loc
                    
                    
                }
                
                
            } else {
                
                entry.headerTextProvider = CLKSimpleTextProvider(text: "No events on")
                entry.body1TextProvider = CLKSimpleTextProvider(text: "No upcoming")
                
            }
            
            
            /*   let date = Date()
             let dateFormatter  = DateFormatter()
             dateFormatter.dateFormat = "hh:mm a"
             let dateInString = dateFormatter.string(from: date) */
           
            
            entry.body2TextProvider = CLKSimpleTextProvider(text: updatedTimeText)
            
            entry.body1TextProvider.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            entry.body2TextProvider!.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
             entryItem = entry
            
        @unknown default:
            break
        }
        
        
        if let safeE = entryItem {
            
            
            returnArray.append(CLKComplicationTimelineEntry(date: data.showAt, complicationTemplate: safeE))
        }
        
        return returnArray
        
    }
    
    
    private func generateEventOnComlicationText(complication: CLKComplication, data: HLLComplicationEntry) -> [CLKComplicationTimelineEntry] {
        
        let event = data.event!
        
        var eventTint = #colorLiteral(red: 0.9944762588, green: 0.3928351742, blue: 0.08257865259, alpha: 1)
        if let calCGCol = EventDataSource.shared.calendarFromID(event.calendarID)?.cgColor {
        eventTint = UIColor(cgColor: calCGCol)
        }
        
        var rArray = [CLKComplicationTimelineEntry]()
        let current = event
        
        switch complication.family {
            
            
            
            
        case .modularSmall:
            
            
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider.tintColor = eventTint
            template.line2TextProvider.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            template.line1TextProvider = CLKSimpleTextProvider(text: current.title)
            template.line2TextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .timer, units: [.day, .hour, .minute])
            rArray.append(CLKComplicationTimelineEntry(date: data.showAt, complicationTemplate: template))
            
        case .modularLarge:
            
            if HLLDefaults.complication.largeCountdown == false {
            
            
            let template = CLKComplicationTemplateModularLargeStandardBody()
            
            template.headerTextProvider.tintColor = eventTint
            template.body1TextProvider.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            template.body2TextProvider?.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
            template.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) ends in")
            
            template.body1TextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: [.day, .hour, .minute])
            
            if let loc = current.location, loc != "" {
                
                template.body2TextProvider = CLKSimpleTextProvider(text: "\(loc)")
                
            } else {
                
                template.body2TextProvider = CLKSimpleTextProvider(text: "No location")
                
            }
            
            template.headerTextProvider.tintColor = eventTint
            template.body1TextProvider.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            template.body2TextProvider?.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
            rArray.append(CLKComplicationTimelineEntry(date: data.showAt, complicationTemplate: template))
            
            
            if let uNext = data.nextEvent {
                
                let nextName = uNext.title
                
                if let loc = uNext.location, loc != "" {
                    
                    template.body2TextProvider = CLKSimpleTextProvider(text: "\(nextName), \(loc)")
                    
                } else {
                    
                    template.body2TextProvider = CLKSimpleTextProvider(text: "Next: \(nextName)")
                    
                }
                
            } else {
                
                template.body2TextProvider = CLKSimpleTextProvider(text: "Nothing next")
                
            }
                
            
            
            template.headerTextProvider.tintColor = eventTint
            template.body1TextProvider.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            template.body2TextProvider?.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
            rArray.append(CLKComplicationTimelineEntry(date: data.showAt.addingTimeInterval(600), complicationTemplate: template))
            
            } else {
                
                let template = CLKComplicationTemplateModularLargeTallBody()
                
                template.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) ends in")
                template.headerTextProvider.tintColor = eventTint
                template.bodyTextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: [.day, .hour, .minute])
                
                template.bodyTextProvider.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
                
               rArray.append(CLKComplicationTimelineEntry(date: data.showAt, complicationTemplate: template))
                
            }
                
        case .utilitarianSmall:
            
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider.tintColor = eventTint
            template.textProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .naturalAbbreviated, units: [.day, .hour, .minute])
            rArray.append(CLKComplicationTimelineEntry(date: data.showAt, complicationTemplate: template))
            
            
        case .utilitarianSmallFlat:
           
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider.tintColor = eventTint
            
            template.textProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .naturalAbbreviated, units: [.day, .hour, .minute])
            
            rArray.append(CLKComplicationTimelineEntry(date: data.showAt, complicationTemplate: template))
            
            
        case .utilitarianLarge:
            
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider.tintColor = eventTint
            
            var providerArray = [CLKTextProvider]()
            
            providerArray.append(CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: [.day, .hour, .minute]))
            
            providerArray.append(CLKSimpleTextProvider(text: "\(current.title): "))
            
            template.textProvider = CLKTextProvider(byJoining: providerArray.reversed(), separator: nil)
                
                
            rArray.append(CLKComplicationTimelineEntry(date: data.showAt, complicationTemplate: template))
            
        case .circularSmall:
            
           break
            
        case .extraLarge:
            
            let template = CLKComplicationTemplateExtraLargeStackText()
            template.line1TextProvider.tintColor = eventTint
            template.line2TextProvider.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            template.line1TextProvider = CLKSimpleTextProvider(text: current.title)
            template.line2TextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .timer, units: [.day, .hour, .minute])
            rArray.append(CLKComplicationTimelineEntry(date: data.showAt, complicationTemplate: template))
            
            
            
        case .graphicCorner:
        
            
            let template = CLKComplicationTemplateGraphicCornerGaugeText()
            template.outerTextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .naturalAbbreviated, units: [.day, .hour, .minute])
            
            template.leadingTextProvider = CLKSimpleTextProvider(text: current.title)
            let gaugeProvider = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: [#colorLiteral(red: 1, green: 0.7437175817, blue: 0.02428589218, alpha: 1),#colorLiteral(red: 0.9627912974, green: 0.3692123313, blue: 0, alpha: 1)], gaugeColorLocations: nil, start: current.startDate, end: current.endDate)
            template.gaugeProvider = gaugeProvider
            rArray.append(CLKComplicationTimelineEntry(date: data.showAt, complicationTemplate: template))
            
            
        case .graphicBezel:
            
        
            let imageTemplate = CLKComplicationTemplateGraphicCircularClosedGaugeImage()
            
            imageTemplate.gaugeProvider = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: [#colorLiteral(red: 1, green: 0.7437175817, blue: 0.02428589218, alpha: 1),#colorLiteral(red: 0.9627912974, green: 0.3692123313, blue: 0, alpha: 1)], gaugeColorLocations: nil, start: current.startDate, end: current.endDate)
            imageTemplate.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "GraphicCircular_ClosedGauge")!)
            
           let template = CLKComplicationTemplateGraphicBezelCircularText()
        
            template.circularTemplate = imageTemplate
            
            var providers = [CLKTextProvider]()
            
            
            providers.append(CLKSimpleTextProvider(text: "\(current.title): "))
            providers.append(CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: [.day, .hour, .minute]))
            
            template.textProvider = CLKTextProvider(byJoining: providers, separator: nil)
            rArray.append(CLKComplicationTimelineEntry(date: data.showAt, complicationTemplate: template))
            
        case .graphicCircular:
            
            let imageTemplate = CLKComplicationTemplateGraphicCircularClosedGaugeImage()
            
            imageTemplate.gaugeProvider = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: [#colorLiteral(red: 1, green: 0.7437175817, blue: 0.02428589218, alpha: 1),#colorLiteral(red: 0.9627912974, green: 0.3692123313, blue: 0, alpha: 1)], gaugeColorLocations: nil, start: current.startDate, end: current.endDate)
            imageTemplate.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "GraphicCircular_ClosedGauge")!)
            
            rArray.append(CLKComplicationTimelineEntry(date: data.showAt, complicationTemplate: imageTemplate))
            
        case .graphicRectangular:
            
    
            if let loc = current.location, loc != "" {
            let template = CLKComplicationTemplateGraphicRectangularStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) ends in")
            template.body1TextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: [.day, .hour, .minute])
            
    
                template.body2TextProvider = CLKSimpleTextProvider(text: "\(loc)")
                
                template.headerTextProvider.tintColor = eventTint
                template.body1TextProvider.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                template.body2TextProvider?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                rArray.append(CLKComplicationTimelineEntry(date: current.startDate, complicationTemplate: template))
                
                let template2 = CLKComplicationTemplateGraphicRectangularTextGauge()
                template2.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) ends in")
                template2.headerTextProvider.tintColor = eventTint
                template2.body1TextProvider.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                template2.body1TextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: [.day, .hour, .minute])
                let gaugeProvider2 = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: [#colorLiteral(red: 1, green: 0.7437175817, blue: 0.02428589218, alpha: 1),#colorLiteral(red: 0.9627912974, green: 0.3692123313, blue: 0, alpha: 1)], gaugeColorLocations: nil, start: current.startDate, end: current.endDate)
                template2.gaugeProvider = gaugeProvider2
                rArray.append(CLKComplicationTimelineEntry(date: data.showAt.addingTimeInterval(600), complicationTemplate: template2))
                
            } else {
                let template2 = CLKComplicationTemplateGraphicRectangularTextGauge()
                template2.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) ends in")
                template2.headerTextProvider.tintColor = eventTint
                template2.body1TextProvider.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                template2.body1TextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: [.day, .hour, .minute])
                let gaugeProvider2 = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: [#colorLiteral(red: 1, green: 0.7437175817, blue: 0.02428589218, alpha: 1),#colorLiteral(red: 0.9627912974, green: 0.3692123313, blue: 0, alpha: 1)], gaugeColorLocations: nil, start: current.startDate, end: current.endDate)
                template2.gaugeProvider = gaugeProvider2
                rArray.append(CLKComplicationTimelineEntry(date: data.showAt, complicationTemplate: template2))
                
            }
            
            
        @unknown default:
            break
        }
        
        
        
        return rArray
        
    }
    
    func getTimelineStartDate() -> Date? {
        
        let cal = EventDataSource.shared
        cal.updateEventStore()
        return cal.fetchEventsFromPresetPeriod(period: .AllTodayPlus24HoursFromNow).first?.startDate
        
    }
    
    func getTimelineEndDate() -> Date? {
        let cal = EventDataSource.shared
        cal.updateEventStore()
        return cal.fetchEventsFromPresetPeriod(period: .AllTodayPlus24HoursFromNow).last?.endDate
        
    }
    
    


func getSoonestEndingEvent(at date: Date, from events: [HLLEvent]) -> HLLEvent? {
    
    var currentEvents = [HLLEvent]()
    
    for event in events {
        
        if event.startDate.timeIntervalSince(date) < 1, event.endDate.timeIntervalSince(date) > 0 {
            
            currentEvents.append(event)
            
        }
    }
    
    currentEvents.sort(by: { $0.endDate.compare($1.endDate) == .orderedAscending })
    
    return currentEvents.first
    
}


func getNextEvent(after event: HLLEvent, events: [HLLEvent]) -> HLLEvent? {
    
    if let index = events.firstIndex(of: event) {
        
        if events.indices.contains(index+1) {
            
            return events[index+1]
            
        } else {
            
            return nil
            
        }
        
    } else {
        
        return nil
        
    }
    
    
}


func getNextEventToStart(after date: Date, from events: [HLLEvent]) -> HLLEvent? {
    
    var upcomingEvents = [HLLEvent]()
    
    for event in events {
        
        if event.startDate.timeIntervalSinceNow > 0 {
            
            upcomingEvents.append(event)
            
        }
    }
    
    return upcomingEvents.first
    
    
}
    
    
}

class HLLComplicationEntry {
    
    var showAt: Date
    var event: HLLEvent?
    var nextEvent: HLLEvent?
    
    init(date: Date, event currentEvent: HLLEvent?, next: HLLEvent?) {
        showAt = date
        event = currentEvent
        nextEvent = next
    }
    
}


class CompDefaults {
    
    static var shared = CompDefaults()
    
    
    func saveEventsAsLastComplicationUpdate(events: [HLLEvent]) {
        
        let ids = events.map { $0.identifier }.joined()
        
        HLLDefaults.defaults.set(ids, forKey: "ComplicationUpdateData")
        
        
    }
    
    func hasUpdatedComplicationWith(events: [HLLEvent]) -> Bool {
        
        if let data = HLLDefaults.defaults.string(forKey: "ComplicationUpdateData") {
            
            let eventString = events.map { $0.identifier }.joined()
            
            if data == eventString {
                
                return true
                
            } else {
                
                return false
                
            }
            
            
            
        } else {
            
            return false
            
        }
        
        
    }
    
    
}
