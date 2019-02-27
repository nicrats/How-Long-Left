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
        
        var r = [CLKComplicationTimelineEntry]()
        cal.updateEventStore()
        var events = cal.fetchEventsFromPresetPeriod(period: .AllToday)
        
        for event in events {
            
            if event.completionStatus == .Done {
                
                if let index = events.index(of: event) {
                    
                    events.remove(at: index)
                    
                }
                
            }
            
        }
        
        for (index, item) in events.enumerated() {
            
            var nextEvent: HLLEvent?
            
            if events.indices.contains(index+1) {
                
                nextEvent = events[index+1]
                
            }
            
            
            var next: HLLEvent?
            
            if events.indices.contains(index+1) {
                next = events[index+1]
            }
            
            let gen = generateEventComlicationText(complication: complication, event: item, next: next)
            
            r.append(contentsOf: gen)
            
            var addNoEventsAfterThisEvent = false
            
            if let uNext = next {
                
                if item.endDate != uNext.startDate {
                    
                    addNoEventsAfterThisEvent = true
                    
                }
                
            } else {
                
                addNoEventsAfterThisEvent = true
                
            }
            
            if addNoEventsAfterThisEvent == true {
                
                let entry = generateNoEventOnComlicationText(complication: complication, nextEvent: nextEvent)
                
                let e = CLKComplicationTimelineEntry(date: item.endDate, complicationTemplate: entry!)
                r.append(e)
                
            }
            
            
        }
        
        
        if cal.getCurrentEvents().isEmpty == true {
            
            let entry = generateNoEventOnComlicationText(complication: complication, nextEvent: cal.getUpcomingEventsToday().first)
            let e = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: entry!)
            r.insert(e, at: 0)
            
        }
        
        
        if r.isEmpty == true {
            
            let entry = generateNoEventOnComlicationText(complication: complication, nextEvent: cal.getUpcomingEventsToday().first)
            
            r = [CLKComplicationTimelineEntry(date: Date(), complicationTemplate: entry!)]
            
        }
        
        return r
    }
    
    
    func generateNoEventOnComlicationText(complication: CLKComplication, nextEvent: HLLEvent?) -> CLKComplicationTemplate? {
        
        
        switch complication.family {
        case .circularSmall:
            break
        case .modularSmall:
            
            let entry = CLKComplicationTemplateModularSmallSimpleText()
            entry.textProvider = CLKSimpleTextProvider(text: "HLL")
            
            return entry
            
        case .modularLarge:
            
            let entry = CLKComplicationTemplateModularLargeStandardBody()
            entry.headerTextProvider = CLKSimpleTextProvider(text: "No events on")
            if let next = nextEvent {
                
                entry.body1TextProvider = CLKSimpleTextProvider(text: "Next: \(next.title)")
                
            } else {
                entry.body1TextProvider = CLKSimpleTextProvider(text: "No upcoming today")
                
            }
            /*   let date = Date()
             let dateFormatter  = DateFormatter()
             dateFormatter.dateFormat = "hh:mm a"
             let dateInString = dateFormatter.string(from: date) */
            let updatedTimeText = "Tap to refresh"
            
            entry.body2TextProvider = CLKSimpleTextProvider(text: updatedTimeText)
            entry.headerTextProvider.tintColor = #colorLiteral(red: 0.9944762588, green: 0.3928351742, blue: 0.08257865259, alpha: 1)
            entry.body1TextProvider.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            entry.body2TextProvider!.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
            return entry
            
        case .utilitarianSmall:
            break
        case .utilitarianSmallFlat:
            
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: "No event")
            return template
            
        case .utilitarianLarge:
            
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKSimpleTextProvider(text: "No event is on")
            return template
            
        case .extraLarge:
            break
        case .graphicCorner:
            
            let entry = CLKComplicationTemplateGraphicCornerCircularImage()
            let image = UIImage(named: "ComplicationAppIcon")!
            entry.imageProvider = CLKFullColorImageProvider(fullColorImage: image)
            return entry
            
        case .graphicBezel:
            
            let image = UIImage(named: "ComplicationAppIcon")!
            let imageTemplate = CLKComplicationTemplateGraphicCircularImage()
            imageTemplate.imageProvider = CLKFullColorImageProvider(fullColorImage: image)
            let template = CLKComplicationTemplateGraphicBezelCircularText()
            template.circularTemplate = imageTemplate
            template.textProvider = CLKSimpleTextProvider(text: "No event is on")
            return template
            
        case .graphicCircular:
            
            let image = UIImage(named: "ComplicationAppIcon")!
            let entry = CLKComplicationTemplateGraphicCircularImage()
            entry.imageProvider = CLKFullColorImageProvider(fullColorImage: image)
            return entry
    
        case .graphicRectangular:
            
            let entry = CLKComplicationTemplateGraphicRectangularStandardBody()
            entry.headerTextProvider = CLKSimpleTextProvider(text: "No events on")
            
            if let next = cal.getUpcomingEventsToday().first {
                
                entry.body1TextProvider = CLKSimpleTextProvider(text: "Next: \(next.title)")
                
            } else {
               entry.body1TextProvider = CLKSimpleTextProvider(text: "Nothing next")
                
            }
            
            
            /*   let date = Date()
             let dateFormatter  = DateFormatter()
             dateFormatter.dateFormat = "hh:mm a"
             let dateInString = dateFormatter.string(from: date) */
            let updatedTimeText = "Tap to refresh"
            
            entry.body2TextProvider = CLKSimpleTextProvider(text: updatedTimeText)
            entry.headerTextProvider.tintColor = #colorLiteral(red: 0.9944762588, green: 0.3928351742, blue: 0.08257865259, alpha: 1)
            entry.body1TextProvider.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            entry.body2TextProvider!.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
            return entry
            
        }
        
        
        return nil
        
    }
    
    
    private func generateEventComlicationText(complication: CLKComplication, event: HLLEvent, next: HLLEvent?) -> [CLKComplicationTimelineEntry] {
        
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
            template.line2TextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: .minute)
            rArray.append(CLKComplicationTimelineEntry(date: current.startDate, complicationTemplate: template))
            
        case .modularLarge:
            
            let template = CLKComplicationTemplateModularLargeStandardBody()
            
            template.headerTextProvider.tintColor = eventTint
            template.body1TextProvider.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            template.body2TextProvider?.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
            template.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) ends in")
            
            template.body1TextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: .minute)
            
            if let loc = current.location, loc != "" {
                
                template.body2TextProvider = CLKSimpleTextProvider(text: "\(loc)")
                
            } else {
                
                template.body2TextProvider = CLKSimpleTextProvider(text: "No location")
                
            }
            
            template.headerTextProvider.tintColor = eventTint
            template.body1TextProvider.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            template.body2TextProvider?.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
            rArray.append(CLKComplicationTimelineEntry(date: current.startDate, complicationTemplate: template))
            
            
            if let uNext = next {
                
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
            
            rArray.append(CLKComplicationTimelineEntry(date: current.startDate.addingTimeInterval(600), complicationTemplate: template))
            
        case .utilitarianSmall:
            
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider.tintColor = eventTint
            template.textProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: .minute)
            rArray.append(CLKComplicationTimelineEntry(date: current.startDate, complicationTemplate: template))
            
            
        case .utilitarianSmallFlat:
            break
        case .utilitarianLarge:
            
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider.tintColor = eventTint
            template.textProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: .minute)
            rArray.append(CLKComplicationTimelineEntry(date: current.startDate, complicationTemplate: template))
            
        case .circularSmall:
            
            break
            
        case .extraLarge:
            break
        case .graphicCorner:
            
            let template = CLKComplicationTemplateGraphicCornerGaugeText()
            template.outerTextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: .minute)
            template.leadingTextProvider = CLKSimpleTextProvider(text: current.title)
            let gaugeProvider = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: [#colorLiteral(red: 1, green: 0.7437175817, blue: 0.02428589218, alpha: 1),#colorLiteral(red: 0.9627912974, green: 0.3692123313, blue: 0, alpha: 1)], gaugeColorLocations: nil, start: current.startDate, end: current.endDate)
            template.gaugeProvider = gaugeProvider
            rArray.append(CLKComplicationTimelineEntry(date: current.startDate, complicationTemplate: template))
            
            
        case .graphicBezel:
            
            let image = UIImage(named: "ComplicationAppIcon")!
            let imageTemplate = CLKComplicationTemplateGraphicCircularClosedGaugeImage()
            imageTemplate.gaugeProvider = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)], gaugeColorLocations: nil, start: current.startDate, end: current.endDate)
            imageTemplate.imageProvider = CLKFullColorImageProvider(fullColorImage: image)
           let template = CLKComplicationTemplateGraphicBezelCircularText()
        
            template.circularTemplate = imageTemplate
            template.textProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: .minute)
            rArray.append(CLKComplicationTimelineEntry(date: current.startDate, complicationTemplate: template))
            
        case .graphicCircular:
            
            let image = UIImage(named: "ComplicationAppIcon")!
            let template = CLKComplicationTemplateGraphicCircularImage()
            template.imageProvider = CLKFullColorImageProvider(fullColorImage: image)
            rArray.append(CLKComplicationTimelineEntry(date: current.startDate, complicationTemplate: template))
            
            
        case .graphicRectangular:
            
            if let loc = current.location, loc != "" {
            let template = CLKComplicationTemplateGraphicRectangularStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) ends in")
            template.body1TextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: .minute)
            
                
                template.body2TextProvider = CLKSimpleTextProvider(text: "\(loc)")
                
                template.headerTextProvider.tintColor = eventTint
                template.body1TextProvider.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                template.body2TextProvider?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                rArray.append(CLKComplicationTimelineEntry(date: current.startDate, complicationTemplate: template))
                
                let template2 = CLKComplicationTemplateGraphicRectangularTextGauge()
                template2.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) ends in")
                template2.headerTextProvider.tintColor = eventTint
                template2.body1TextProvider.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                template2.body1TextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: .minute)
                let gaugeProvider2 = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: [#colorLiteral(red: 1, green: 0.7437175817, blue: 0.02428589218, alpha: 1),#colorLiteral(red: 0.9627912974, green: 0.3692123313, blue: 0, alpha: 1)], gaugeColorLocations: nil, start: current.startDate, end: current.endDate)
                template2.gaugeProvider = gaugeProvider2
                rArray.append(CLKComplicationTimelineEntry(date: current.startDate.addingTimeInterval(600), complicationTemplate: template2))
                
            } else {
                let template2 = CLKComplicationTemplateGraphicRectangularTextGauge()
                template2.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) ends in")
                template2.headerTextProvider.tintColor = eventTint
                template2.body1TextProvider.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                template2.body1TextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: .minute)
                let gaugeProvider2 = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: [#colorLiteral(red: 1, green: 0.7437175817, blue: 0.02428589218, alpha: 1),#colorLiteral(red: 0.9627912974, green: 0.3692123313, blue: 0, alpha: 1)], gaugeColorLocations: nil, start: current.startDate, end: current.endDate)
                template2.gaugeProvider = gaugeProvider2
                rArray.append(CLKComplicationTimelineEntry(date: current.startDate, complicationTemplate: template2))
                
            }
            
            
        }
        
        
        
        return rArray
        
    }
    
    func getTimelineStartDate() -> Date? {
        
        let cal = EventDataSource.shared
        cal.updateEventStore()
        return cal.fetchEventsFromPresetPeriod(period: .AllToday).first?.startDate
        
    }
    
    func getTimelineEndDate() -> Date? {
        let cal = EventDataSource.shared
        cal.updateEventStore()
        return cal.fetchEventsFromPresetPeriod(period: .AllToday).last?.endDate
        
    }
    
    
}
