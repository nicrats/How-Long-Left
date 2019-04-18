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

    let cal = EventDataSource()
    
    init() {
        
        SchoolAnalyser.shared.analyseCalendar()
        
    }
    
    func generateComplicationEntries(complication: CLKComplication) -> [CLKComplicationTimelineEntry] {
        
        var returnArray = [CLKComplicationTimelineEntry]()
        let items = generateComplicationItems()
        
        for item in items {
            
            returnArray.append(contentsOf: getEntryForItem(complication: complication, data: item))
            
        }
        
        return returnArray
        
    }
    
    func getEntryForItem(complication: CLKComplication, data: HLLComplicationEntry) -> [CLKComplicationTimelineEntry] {
        
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
        
        let upcomingEvents = cal.fetchEventsFromPresetPeriod(period: .Next2Weeks)
        
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
        
        events.sort(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
        
        
        
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
                
                let next = getNextEvent(after: start, events: upcomingEvents)
                
                print("CompSim1: \(item.startDate.formattedDate()) \(item.startDate.formattedTime()): \(start.title), Next: \(String(describing: next?.title))")
                
                let entry = HLLComplicationEntry(date: item.startDate, event: start, next: next)
                
                if getSoonestEndingEvent(at: start.startDate.addingTimeInterval(600), from: events) != start {
                    
                    entry.switchToNext = false
                    
                }
                
                returnItems.append(entry)
                dictOfAdded[item.startDate] = start
                
                
                
                
            } else {
                
                let nextEv = getNextEventToStart(after: item.startDate, from: upcomingEvents)
                print("CompSim2: \(item.endDate.formattedDate()) \(item.endDate.formattedTime()): No events are on")
                returnItems.append(HLLComplicationEntry(date: item.endDate, event: nil, next: nextEv))
                
            }
            
            if let end = getSoonestEndingEvent(at: item.endDate, from: events) {
                
                
                let next = getNextEvent(after: end, events: upcomingEvents)
                
                print("CompSim3: \(item.endDate.formattedDate()) \(item.endDate.formattedTime()): No event is on, Next: \(next?.title ?? "None")")
                
                let entry = HLLComplicationEntry(date: item.endDate, event: end, next: next)
                
                if getSoonestEndingEvent(at: end.startDate.addingTimeInterval(600), from: events) != end {
                    
                    entry.switchToNext = false
                    
                }
                
                returnItems.append(entry)
                
                dictOfAdded[item.endDate] = end
                
            } else {
                
                let nextEv = getNextEventToStart(after: item.endDate, from: upcomingEvents)
                print("CompSim4: \(item.endDate.formattedDate()) \(item.endDate.formattedTime()): No event is on, Next: \(nextEv?.title ?? "None")")
                returnItems.append(HLLComplicationEntry(date: item.endDate, event: nil, next: nextEv))
                
                
            }
            
            if cal.getCurrentEvents().isEmpty == true {
                
                let nextEv = getNextEventToStart(after: Date(), from: upcomingEvents)
                
                print("CompSim5: \(Date().formattedDate()) \(Date().formattedTime()): No event is on, Next: \(nextEv?.title ?? "None")")
                returnItems.append(HLLComplicationEntry(date: Date(), event: nil, next: nextEv))
                
            }
            
            
        }
        
        if returnItems.isEmpty == true {
            
            let nextEv = getNextEventToStart(after: Date(), from: upcomingEvents)
            
            print("CompSim6: \(Date().formattedDate()) \(Date().formattedTime()): No event is on, Next: \(nextEv?.title ?? "None")")
            returnItems.append(HLLComplicationEntry(date: Date(), event: nil, next: nextEv))
            HLLDefaults.defaults.set("returnItems empty", forKey: "ComplicationDebug")
        }
        
        returnItems.sort(by: { $0.showAt.compare($1.showAt) == .orderedAscending })
        
        ComplicationDataStatusHandler.shared.didComplicationUpdate()
        
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
    
    
    private func generateEventOnComlicationText(complication: CLKComplication, data: HLLComplicationEntry) -> [CLKComplicationTimelineEntry] {
        
        let event = data.event!
        
        var eventTint = UIColor.orange
        if let calCGCol = event.calendar?.cgColor {
            eventTint = UIColor(cgColor: calCGCol)
        }
        
        var rArray = [CLKComplicationTimelineEntry]()
        let current = event
        
        var coloursGradient = [#colorLiteral(red: 1, green: 0.7437175817, blue: 0.02428589218, alpha: 1),#colorLiteral(red: 0.9627912974, green: 0.3692123313, blue: 0, alpha: 1)]
        
        if let cal = current.calendar {
            
            let col = UIColor(cgColor: cal.cgColor)
            
            coloursGradient = col.HLLCalendarGradient()
            
            
        }
        
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
                
                template.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) \(current.endsInString) in")
                
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
                
                if data.switchToNext == true {
                    
                    rArray.append(CLKComplicationTimelineEntry(date: data.showAt.addingTimeInterval(600), complicationTemplate: template))
                    
                }
                
            } else {
                
                let template = CLKComplicationTemplateModularLargeTallBody()
                
                template.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) \(current.endsInString) in")
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
            
            
            let gaugeProvider = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: coloursGradient, gaugeColorLocations: nil, start: current.startDate, end: current.endDate)
            template.gaugeProvider = gaugeProvider
            rArray.append(CLKComplicationTimelineEntry(date: data.showAt, complicationTemplate: template))
            
            
        case .graphicBezel:
            
            
            let imageTemplate = CLKComplicationTemplateGraphicCircularClosedGaugeImage()
            
            imageTemplate.gaugeProvider = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: coloursGradient, gaugeColorLocations: nil, start: current.startDate, end: current.endDate)
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
            
            imageTemplate.gaugeProvider = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: coloursGradient, gaugeColorLocations: nil, start: current.startDate, end: current.endDate)
            imageTemplate.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "GraphicCircular_ClosedGauge")!)
            
            rArray.append(CLKComplicationTimelineEntry(date: data.showAt, complicationTemplate: imageTemplate))
            
        case .graphicRectangular:
            
            
            if let loc = current.location, loc != "" {
                let template = CLKComplicationTemplateGraphicRectangularStandardBody()
                template.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) \(current.endsInString) in")
                template.body1TextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: [.day, .hour, .minute])
                
                
                template.body2TextProvider = CLKSimpleTextProvider(text: "\(loc)")
                
                template.headerTextProvider.tintColor = eventTint
                template.body1TextProvider.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                template.body2TextProvider?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                rArray.append(CLKComplicationTimelineEntry(date: current.startDate, complicationTemplate: template))
                
                
                
                let template2 = CLKComplicationTemplateGraphicRectangularTextGauge()
                template2.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) \(current.endsInString) in")
                template2.headerTextProvider.tintColor = eventTint
                template2.body1TextProvider.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                template2.body1TextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: [.day, .hour, .minute])
                let gaugeProvider2 = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: coloursGradient, gaugeColorLocations: nil, start: current.startDate, end: current.endDate)
                template2.gaugeProvider = gaugeProvider2
                
                if data.switchToNext == true {
                    
                    rArray.append(CLKComplicationTimelineEntry(date: data.showAt.addingTimeInterval(600), complicationTemplate: template2))
                    
                }
                
            } else {
                let template2 = CLKComplicationTemplateGraphicRectangularTextGauge()
                template2.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) \(current.endsInString) in")
                template2.headerTextProvider.tintColor = eventTint
                template2.body1TextProvider.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                template2.body1TextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: [.day, .hour, .minute])
                let gaugeProvider2 = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: coloursGradient, gaugeColorLocations: nil, start: current.startDate, end: current.endDate)
                template2.gaugeProvider = gaugeProvider2
                rArray.append(CLKComplicationTimelineEntry(date: data.showAt, complicationTemplate: template2))
                
            }
            
            
        @unknown default:
            break
        }
        
        
        
        return rArray
        
    }
    
    func generateNoEventOnComlicationText(complication: CLKComplication, data: HLLComplicationEntry) -> [CLKComplicationTimelineEntry] {
        
        var nextTint = UIColor.orange
        
        if let next = data.nextEvent, let calCGCol = next.calendar?.cgColor {
            nextTint = UIColor(cgColor: calCGCol)
        }
        
        var returnArray = [CLKComplicationTimelineEntry]()
        var entryItem: CLKComplicationTemplate?
        
        switch complication.family {
        case .circularSmall:
            
            let circSmallEntry = CLKComplicationTemplateCircularSmallSimpleImage()
            let image = UIImage(named: "CircularSmallIcon")!
            let imageP = CLKImageProvider(onePieceImage: image)
            imageP.tintColor = nextTint
            
            circSmallEntry.imageProvider = imageP
            
            entryItem = circSmallEntry
            
        case .modularSmall:
            
            let modularSmallEntry = CLKComplicationTemplateModularSmallSimpleImage()
            let image = UIImage(named: "ModularSmallIcon")!
            let imageP = CLKImageProvider(onePieceImage: image)
            imageP.tintColor = nextTint
            modularSmallEntry.imageProvider = imageP
            
            entryItem = modularSmallEntry
            
        case .modularLarge:
            
            let entry = CLKComplicationTemplateModularLargeStandardBody()
            
             var updatedTimeText = "Tap to refresh"
            
            entry.headerTextProvider.tintColor = UIColor.orange
            
            if let next = data.nextEvent {
                
                updatedTimeText = "\(next.startDate.formattedTime())"
                
                entry.headerTextProvider = CLKSimpleTextProvider(text: "Next: \(next.title)")
                
                
                
                
                var providers = [CLKTextProvider]()
                providers.append(CLKSimpleTextProvider(text: "in "))
                
                
                providers.append(CLKRelativeDateTextProvider(date: next.startDate, style: .natural, units: [.day, .hour, .minute]))
                
                entry.body1TextProvider = CLKTextProvider(byJoining: providers, separator: nil)
                
               entry.headerTextProvider.tintColor = nextTint
                
                
               // entry.body1TextProvider = CLKSimpleTextProvider(text: "Next: \(next.title)")
                
                if let loc = next.location {
                    
                    updatedTimeText = loc
                    
                    
                }
                
                
            } else {
                
                entry.headerTextProvider = CLKSimpleTextProvider(text: "No events on")
                
                entry.headerTextProvider.tintColor = UIColor.orange
                
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
            
        case .utilitarianSmall:
            
            let utilitySmallEntry = CLKComplicationTemplateUtilitarianSmallSquare()
            let image = UIImage(named: "UtilitySmallIcon")!
            let imageP = CLKImageProvider(onePieceImage: image)
            imageP.tintColor = nextTint
            utilitySmallEntry.imageProvider = imageP
            
            entryItem = utilitySmallEntry
            
        case .utilitarianSmallFlat:
            
            let utilitySmallEntry = CLKComplicationTemplateUtilitarianSmallFlat()
            utilitySmallEntry.textProvider = CLKSimpleTextProvider(text: "NO EVENT")
            
            entryItem = utilitySmallEntry
            
        case .utilitarianLarge:
            
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            
            let image = UIImage(named: "UtilitySmallIcon")!
            let imageP = CLKImageProvider(onePieceImage: image)
            imageP.tintColor = nextTint
            
            template.imageProvider = imageP
            
            template.textProvider = CLKSimpleTextProvider(text: "No event is on")
             entryItem = template
            
        case .extraLarge:
            
            let XLEntry = CLKComplicationTemplateExtraLargeSimpleImage()
            let image = UIImage(named: "ExtraLargeIcon")!
            let imageP = CLKImageProvider(onePieceImage: image)
            imageP.tintColor = nextTint
            
            XLEntry.imageProvider = imageP
            
            entryItem = XLEntry
            
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
            temp.textProvider.tintColor = UIColor.orange
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
            
            entry.headerTextProvider.tintColor = UIColor.orange
            
            if let next = data.nextEvent {
                
                entry.headerTextProvider = CLKSimpleTextProvider(text: "Next: \(next.title)")
                
                if let col = next.calendar?.cgColor {
                    
                    let uiCOl = UIColor(cgColor: col)
                    
                    entry.headerTextProvider.tintColor = uiCOl
                    
                }
                
                var providers = [CLKTextProvider]()
                providers.append(CLKSimpleTextProvider(text: "in "))
                
                
                
                providers.append(CLKRelativeDateTextProvider(date: next.startDate, style: .natural, units: [.day, .hour, .minute]))
            
                entry.body1TextProvider = CLKTextProvider(byJoining: providers, separator: nil)
                
                // entry.body1TextProvider = CLKSimpleTextProvider(text: "Next: \(next.title)")
                
                entry.headerTextProvider.tintColor = nextTint
                
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
    
    func generateComplicationSample(complication: CLKComplication) -> CLKComplicationTemplate? {
        
        let current = HLLEvent(title: "Meeting", start: Date().addingTimeInterval(-10800), end: Date().addingTimeInterval(5400), location: nil)
        
        let next = HLLEvent(title: "Lunch", start: Date().addingTimeInterval(5500), end: Date().addingTimeInterval(6000), location: nil)
        
        let entry = HLLComplicationEntry(date: Date(), event: current, next: next)
        
        return generateEventOnComlicationText(complication: complication, data: entry).last?.complicationTemplate
        
        
        
        
    }
    
    
  /*  func generateComplicationNotPurchasedEntry(for complication: CLKComplication) -> CLKComplicationTimelineEntry {
        
        
        switch complication.family {
            
        case .modularSmall:
            break
        case .modularLarge:
            
        case .utilitarianSmall:
            
        case .utilitarianSmallFlat:
            
        case .utilitarianLarge:
            
        case .circularSmall:
            break
        case .extraLarge:
            break
        case .graphicCorner:
            
        case .graphicBezel:
            
        case .graphicCircular:
            break
        case .graphicRectangular:
            
        @unknown default:
     
        }
        
    }
     */
    
    func getTimelineStartDate() -> Date? {
        
        let cal = EventDataSource()
        cal.updateEventStore()
        return cal.fetchEventsFromPresetPeriod(period: .AllTodayPlus24HoursFromNow).first?.startDate
        
    }
    
    func getTimelineEndDate() -> Date? {
        let cal = EventDataSource()
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
        
        if event.startDate.timeIntervalSince(date) > 0, event.startDate != date {
            
            upcomingEvents.append(event)
            
        }
    }
    
    return upcomingEvents.first
    
    
}
    
    
}
