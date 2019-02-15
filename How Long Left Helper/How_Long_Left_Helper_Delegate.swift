//
//  How_Long_Left_Helper_Delegate.swift
//  How Long Left Helper
//
//  Created by Ryan Kontos on 13/2/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class HLLHelperDelegate: NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        let exportedObject = HLLHelper()
        newConnection.exportedInterface = NSXPCInterface(with: HLLHelperProtocol.self)
        newConnection.exportedObject = exportedObject
        newConnection.resume()
        return true
    }
}
