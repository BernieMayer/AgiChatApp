//
//  AppState.swift
//  ChatApp
//
//  Created by admin on 23/09/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import Foundation


class AppState: NSObject {
    
    static let sharedInstance = AppState()
    
    var signedIn = false
    var displayName: String?
    var photoUrl: NSURL?
}
