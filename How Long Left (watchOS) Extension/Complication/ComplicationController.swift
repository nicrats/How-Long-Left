//
//  ComplicationController.swift
//  How Long Left (watchOS) Extension
//
//  Created by Ryan Kontos on 15/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration

    let Generator = ComplicationContentsGenerator()
    
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        
        handler(Generator.getTimelineStartDate())
        
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        
       handler(Generator.getTimelineEndDate())
        
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        DispatchQueue.global(qos: .default).async {
            
        
        handler(self.Generator.generateComplicationText(complication: complication).first)
        
        }
            
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        
        DispatchQueue.global(qos: .default).async {
        
     //   WatchSessionManager.sharedManager.sendUpdatedComplicationMessage()
        
            handler(self.Generator.generateComplicationText(complication: complication))
        
        
    }
        
    }
    
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        
        let current = HLLEvent(title: "Event", start: Date().addingTimeInterval(-800), end: Date().addingTimeInterval(300), location: nil)
        
        switch complication.family {
            
            
            
        case .modularSmall:
            
            
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider.tintColor = #colorLiteral(red: 0.9627912974, green: 0.3692123313, blue: 0, alpha: 1)
            template.line2TextProvider.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            template.line1TextProvider = CLKSimpleTextProvider(text: current.title)
            template.line2TextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: .minute)
            handler(template)
        case .modularLarge:
            
            let template = CLKComplicationTemplateModularLargeStandardBody()
            
            template.headerTextProvider.tintColor = #colorLiteral(red: 0.9627912974, green: 0.3692123313, blue: 0, alpha: 1)
            template.body1TextProvider.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            template.body2TextProvider?.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
            template.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) ends in")
            
            template.body1TextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: .minute)
            
            if let loc = current.location, loc != "" {
                
                template.body2TextProvider = CLKSimpleTextProvider(text: "\(loc)")
                
            } else {
                
                template.body2TextProvider = CLKSimpleTextProvider(text: "No location")
                
            }
            
            template.headerTextProvider.tintColor = #colorLiteral(red: 0.9627912974, green: 0.3692123313, blue: 0, alpha: 1)
            template.body1TextProvider.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            template.body2TextProvider?.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
            handler(template)
            
        
        case .utilitarianSmall:
            
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider.tintColor = #colorLiteral(red: 0.9627912974, green: 0.3692123313, blue: 0, alpha: 1)
            template.textProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: .minute)
            handler(template)
            
            
        case .utilitarianSmallFlat:
            handler(nil)
            break
        case .utilitarianLarge:
            
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider.tintColor = #colorLiteral(red: 0.9627912974, green: 0.3692123313, blue: 0, alpha: 1)
            template.textProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: .minute)
           handler(template)
            
        case .circularSmall:
            
            handler(nil)
            break
            
        case .extraLarge:
            break
        case .graphicCorner:
            
            let template = CLKComplicationTemplateGraphicCornerGaugeText()
            template.outerTextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: .minute)
            template.leadingTextProvider = CLKSimpleTextProvider(text: current.title)
            let gaugeProvider = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: [#colorLiteral(red: 1, green: 0.7437175817, blue: 0.02428589218, alpha: 1),#colorLiteral(red: 0.9627912974, green: 0.3692123313, blue: 0, alpha: 1)], gaugeColorLocations: nil, start: current.startDate, end: current.endDate)
            template.gaugeProvider = gaugeProvider
            handler(template)
            
            
        case .graphicBezel:
            
            let image = UIImage(named: "ComplicationAppIcon")!
            let imageTemplate = CLKComplicationTemplateGraphicCircularClosedGaugeImage()
            imageTemplate.gaugeProvider = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)], gaugeColorLocations: nil, start: current.startDate, end: current.endDate)
            imageTemplate.imageProvider = CLKFullColorImageProvider(fullColorImage: image)
            let template = CLKComplicationTemplateGraphicBezelCircularText()
            
            template.circularTemplate = imageTemplate
            template.textProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: .minute)
            handler(template)
            
        case .graphicCircular:
            
            let image = UIImage(named: "ComplicationAppIcon")!
            let template = CLKComplicationTemplateGraphicCircularImage()
            template.imageProvider = CLKFullColorImageProvider(fullColorImage: image)
            handler(template)
            
            
        case .graphicRectangular:
            
           
                let template2 = CLKComplicationTemplateGraphicRectangularTextGauge()
                template2.headerTextProvider = CLKSimpleTextProvider(text: "\(current.title) ends in")
                template2.headerTextProvider.tintColor = #colorLiteral(red: 0.9627912974, green: 0.3692123313, blue: 0, alpha: 1)
                template2.body1TextProvider.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                template2.body1TextProvider = CLKRelativeDateTextProvider(date: current.endDate, style: .natural, units: .minute)
                let gaugeProvider2 = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: [#colorLiteral(red: 1, green: 0.7437175817, blue: 0.02428589218, alpha: 1),#colorLiteral(red: 0.9627912974, green: 0.3692123313, blue: 0, alpha: 1)], gaugeColorLocations: nil, start: current.startDate, end: current.endDate)
                template2.gaugeProvider = gaugeProvider2
                handler(template2)
                
            
            
        }
        
        
        
    }
    
    
}
