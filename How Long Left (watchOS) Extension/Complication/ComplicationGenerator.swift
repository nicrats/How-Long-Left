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
    
    func generateComplicationEntries(complication: CLKComplication) -> [CLKComplicationTimelineEntry] {
        
        var returnArray = [CLKComplicationTimelineEntry]()
        let items = generateComplicationItems()
        
        HLLDefaults.defaults.set(false, forKey: "ComplicationPurchased")
        
        if HLLDefaults.defaults.bool(forKey: "ComplicationPurchased") == true || SchoolAnalyser.privSchoolMode == .Magdalene {
        
            HLLDefaults.defaults.set(true, forKey: "UpdatedWithEvents")
            
            
        for item in items {
            
            returnArray.append(contentsOf: getEntryForItem(complication: complication, data: item))
            
        }
            
        } else {
            
            HLLDefaults.defaults.set(false, forKey: "UpdatedWithEvents")
            
           returnArray.append(generateComplicationNotPurchasedEntry(for: complication))
            
            
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
        
        var events = HLLEventSource.shared.eventPool
        events.sort(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
        
        var entryDates = [Date]()
        
        for event in events {
            
            entryDates.append(event.startDate)
            entryDates.append(event.endDate)
            
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
        
        
        var dictOfAdded = [Date:HLLEvent]()
        
        var returnItems = [HLLComplicationEntry]()
        
        for date in entryDates {
            
            if let current = getSoonestEndingEvent(at: date, from: events) {
                
                let next = getNextEventToStart(after: current.startDate, from: events)
                
                print("CompSim1: \(date.formattedDate()) \(date.formattedTime()): \(current.title), Next: \(String(describing: next?.title))")
                
                let entry = HLLComplicationEntry(date: date, event: current, next: next)
                
                if getSoonestEndingEvent(at: current.startDate.addingTimeInterval(600), from: events) != current {
                    
                    entry.switchToNext = false
                    
                }
                
                returnItems.append(entry)
                dictOfAdded[date] = current
                
                
                
                
            } else {
                
                let nextEv = getNextEventToStart(after: date, from: events)
                print("CompSim2: \(date.formattedDate()) \(date.formattedTime()): No events are on")
                returnItems.append(HLLComplicationEntry(date: date, event: nil, next: nextEv))
                
            }
            
        }
        
        if HLLEventSource.shared.getCurrentEvents().isEmpty == true {
            
            let nextEv = getNextEventToStart(after: Date(), from: events)
            
            print("CompSim5: \(Date().formattedDate()) \(Date().formattedTime()): No event is on, Next: \(nextEv?.title ?? "None")")
            returnItems.append(HLLComplicationEntry(date: Date(), event: nil, next: nextEv))
            
        }
        
        if returnItems.isEmpty == true {
            
            let nextEv = getNextEventToStart(after: Date(), from: events)
            
            print("CompSim6: \(Date().formattedDate()) \(Date().formattedTime()): No event is on, Next: \(nextEv?.title ?? "None")")
            returnItems.append(HLLComplicationEntry(date: Date(), event: nil, next: nextEv))
            HLLDefaults.defaults.set("returnItems empty", forKey: "ComplicationDebug")
        }
        
        returnItems.sort(by: { $0.showAt.compare($1.showAt) == .orderedAscending })
        
        ComplicationUpdateHandler.shared.didComplicationUpdate()
        
        return returnItems
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
            template.line1TextProvider = CLKSimpleTextProvider(text: current.title)
            template.line2TextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .naturalAbbreviated, units: [.day, .hour, .minute])
            template.line1TextProvider.tintColor = eventTint
            template.line2TextProvider.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            rArray.append(CLKComplicationTimelineEntry(date: data.showAt, complicationTemplate: template))
            
            
        case .modularLarge:
            
            if HLLDefaults.complication.largeCountdown == false {
                
                
                let template = CLKComplicationTemplateModularLargeStandardBody()
                
                template.headerTextProvider.tintColor = eventTint
                template.body1TextProvider.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                template.body2TextProvider?.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
                template.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) \(current.countdownStringEnd) in")
                
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
                
                template.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) \(current.countdownStringEnd) in")
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
            
            providerArray.append(CLKSimpleTextProvider(text: "\(current.truncateTitle(limit: 14, postion: .middle)): "))
            
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
                template.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) \(current.countdownStringEnd) in")
                template.body1TextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: [.day, .hour, .minute])
                
                
                template.body2TextProvider = CLKSimpleTextProvider(text: "\(loc)")
                
                template.headerTextProvider.tintColor = eventTint
                template.body1TextProvider.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                template.body2TextProvider?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                rArray.append(CLKComplicationTimelineEntry(date: current.startDate, complicationTemplate: template))
                
                
                
                let template2 = CLKComplicationTemplateGraphicRectangularTextGauge()
                template2.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) \(current.countdownStringEnd) in")
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
                template2.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) \(current.countdownStringEnd) in")
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
                
                entry.headerTextProvider = CLKSimpleTextProvider(text: "\(next.title)")
                
                
                
                
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
            
          /*  let image = UIImage(named: "UtilitySmallIcon")!
            let imageP = CLKImageProvider(onePieceImage: image)
            imageP.tintColor = nextTint
            
            template.imageProvider = imageP */
            
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
                nextTemp.innerTextProvider = CLKSimpleTextProvider(text: "\(nex.title) \(nex.countdownStringStart) in")
                
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
    
    func generateComplicationNotPurchasedEntry(for complication: CLKComplication) -> CLKComplicationTimelineEntry {
        
        var entryItem: CLKComplicationTemplate?
        
        switch complication.family {
            
        case .modularSmall:
            
            let modularSmallEntry = CLKComplicationTemplateModularSmallSimpleImage()
            let image = UIImage(named: "ModularSmallIcon")!
            let imageP = CLKImageProvider(onePieceImage: image)
            imageP.tintColor = UIColor.orange
            modularSmallEntry.imageProvider = imageP
            
            entryItem = modularSmallEntry
            
        case .modularLarge:
            
            let modularLargeEntry = CLKComplicationTemplateModularLargeStandardBody()
            modularLargeEntry.headerTextProvider = CLKSimpleTextProvider(text: "How Long Left")
            modularLargeEntry.headerTextProvider.tintColor = UIColor.orange
            modularLargeEntry.body1TextProvider = CLKSimpleTextProvider(text: "Tap to open")
            
            entryItem = modularLargeEntry
            
        case .utilitarianSmall:
            
            let utilitySmallEntry = CLKComplicationTemplateUtilitarianSmallSquare()
            let image = UIImage(named: "UtilitySmallIcon")!
            let imageP = CLKImageProvider(onePieceImage: image)
            imageP.tintColor = UIColor.orange
            utilitySmallEntry.imageProvider = imageP
            
            entryItem = utilitySmallEntry
            
            
        case .utilitarianSmallFlat:
            
            
            let utilitySmallEntry = CLKComplicationTemplateUtilitarianSmallFlat()
            utilitySmallEntry.textProvider = CLKSimpleTextProvider(text: "HLL")
            
            entryItem = utilitySmallEntry
            
        case .utilitarianLarge:
            
            
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            
            template.textProvider = CLKSimpleTextProvider(text: "How Long Left")
            entryItem = template
            
        case .circularSmall:
            
            let circSmallEntry = CLKComplicationTemplateCircularSmallSimpleImage()
            let image = UIImage(named: "CircularSmallIcon")!
            let imageP = CLKImageProvider(onePieceImage: image)
            imageP.tintColor = UIColor.orange
            
            circSmallEntry.imageProvider = imageP
            
            entryItem = circSmallEntry
            
        case .extraLarge:
            
            let XLEntry = CLKComplicationTemplateExtraLargeSimpleImage()
            let image = UIImage(named: "ExtraLargeIcon")!
            let imageP = CLKImageProvider(onePieceImage: image)
            imageP.tintColor = UIColor.orange
            
            XLEntry.imageProvider = imageP
            
            entryItem = XLEntry
            
        case .graphicCorner:
            
             let imageP = CLKFullColorImageProvider(fullColorImage: UIImage(named: "GraphicCorner_NoEvent")!)
            
             let temp = CLKComplicationTemplateGraphicCornerTextImage()
             temp.textProvider = CLKSimpleTextProvider(text: "How Long Left")
             temp.textProvider.tintColor = UIColor.orange
             temp.imageProvider = imageP
             entryItem = temp
            
            
        case .graphicBezel:
            
            let circTemp = CLKComplicationTemplateGraphicCircularImage()
            
            circTemp.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "GraphicCircular")!)
            let temp = CLKComplicationTemplateGraphicBezelCircularText()
            temp.textProvider = CLKSimpleTextProvider(text: "How Long Left")
            temp.textProvider?.tintColor = UIColor.orange
            temp.circularTemplate = circTemp
            
            entryItem = temp
            
            
        case .graphicCircular:
            
            
            let circTemp = CLKComplicationTemplateGraphicCircularImage()
            
            circTemp.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "GraphicCircular")!)
            
            entryItem = circTemp
            
        case .graphicRectangular:
            
            let entry = CLKComplicationTemplateGraphicRectangularStandardBody()
            entry.headerTextProvider = CLKSimpleTextProvider(text: "How Long Left")
            
            entry.headerTextProvider.tintColor = UIColor.orange
            
            entry.body1TextProvider = CLKSimpleTextProvider(text: "Tap to open")
            
            entry.body1TextProvider.tintColor = UIColor.white
            
            entryItem = entry
            
        @unknown default:
            fatalError()
        }
        
        let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: entryItem!)
        
        return timelineEntry
        
    }
    
    func generateComplicationSample(complication: CLKComplication) -> CLKComplicationTemplate? {
        
        let current = HLLEvent(title: "Meeting", start: Date().addingTimeInterval(-10800), end: Date().addingTimeInterval(5400), location: nil)
        
        let next = HLLEvent(title: "Lunch", start: Date().addingTimeInterval(5500), end: Date().addingTimeInterval(6000), location: nil)
        
        let entry = HLLComplicationEntry(date: Date(), event: current, next: next)
        
        return generateEventOnComlicationText(complication: complication, data: entry).last?.complicationTemplate
        
        
        
        
    }
    
    
   
    
    func getTimelineStartDate() -> Date? {
        
        
        return HLLEventSource.shared.eventPool.first?.startDate
        
    }
    
    func getTimelineEndDate() -> Date? {
        
        return HLLEventSource.shared.eventPool.last?.startDate
        
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
