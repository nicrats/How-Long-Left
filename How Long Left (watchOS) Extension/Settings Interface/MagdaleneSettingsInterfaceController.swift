//
//  MagdaleneSettingsInterfaceController.swift
//  How Long Left (watchOS) Extension
//
//  Created by Ryan Kontos on 17/10/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import WatchKit
import Foundation


class MagdaleneSettingsInterfaceController: WKInterfaceController, DefaultsTransferObserver {
    
    @IBOutlet weak var magdaleneModeSwitch: WKInterfaceSwitch!
    @IBOutlet weak var breaksAndHomeroomSwitch: WKInterfaceSwitch!

    override func awake(withContext context: Any?) {
        HLLDefaultsTransfer.shared.addTransferObserver(self)
    }
    
    override func willActivate() {
        setup()
        super.willActivate()
    }
    
    func setup() {
        
        magdaleneModeSwitch.setOn(!HLLDefaults.magdalene.manuallyDisabled)
        breaksAndHomeroomSwitch.setOn(HLLDefaults.magdalene.hideExtras)
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func magdaleneModeSwitched(_ value: Bool) {
        
        HLLDefaults.magdalene.manuallyDisabled = !value
        HLLDefaultsTransfer.shared.userModifiedPrferences()
        
    }
    
    @IBAction func hideBreaksAndHomeroomSwitched(_ value: Bool) {
        
        HLLDefaults.magdalene.hideExtras = value
        HLLDefaultsTransfer.shared.userModifiedPrferences()

        
    }
    
    func defaultsUpdatedRemotely() {
        setup()
    }
    
    

}
