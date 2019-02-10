//
//  IntentHandler.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 28/1/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Intents
import IntentsUI

@available(iOS 10.0, *)
@available(iOS 12.0, *)
class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        guard intent is HowLongLeftIntent else {
            fatalError("Unhandled intent type: \(intent)")
        }
        
        return HowLongLeftIntentHandler()
    }
    
}

import Foundation

@available(iOS 12.0, *)
class HowLongLeftIntentHandler: NSObject, HowLongLeftIntentHandling {
    
    override init() {
        SchoolAnalyser.shared.analyseCalendar()
    }
    
    func confirm(intent: HowLongLeftIntent, completion: @escaping (HowLongLeftIntentResponse) -> Void) {
        let responseGen = SiriResponseGenerator()
        completion(HowLongLeftIntentResponse.success(countdownString: responseGen.generateResponseForCurrentEvent()))
        
    }
    
    func handle(intent: HowLongLeftIntent, completion: @escaping (HowLongLeftIntentResponse) -> Void) {
        let responseGen = SiriResponseGenerator()
        
                completion(HowLongLeftIntentResponse.success(countdownString: responseGen.generateResponseForCurrentEvent()))
            
        }
    }
