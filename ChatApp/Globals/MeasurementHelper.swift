//
//  MeasurementHelper.swift
//  ChatApp
//
//  Created by admin on 23/09/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import Firebase
class MeasurementHelper: NSObject {
    
    static func sendLoginEvent() {
    }
    
    static func sendLogoutEvent() {
    }
    
    static func sendMessageEvent() {
        FIRAnalytics.logEventWithName("message", parameters: nil)
    }
}

