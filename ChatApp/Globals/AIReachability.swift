//
//  AIReachability.swift
//  Spotliss
//
//  Created by Agile-mac on 01/08/16.
//  Copyright © 2016 Agile-mac. All rights reserved.
//

import UIKit
import ReachabilitySwift


class AIReachability: NSObject {
   
    private var reachability: Reachability?
    
    // MARK: - SHARED MANAGER
    class var sharedManager: AIReachability {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: AIReachability? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = AIReachability()
            
        }
        return Static.instance!
    }
    
    
    func isAavailable() -> Bool {
        if reachability == nil {
            setup()
        }
        
        if self.reachability!.isReachable() || self.reachability!.isReachableViaWiFi() || self.reachability!.isReachableViaWWAN() {
            return true
        } else {
            
            
           let alert : UIAlertView = UIAlertView()
            alert.addButtonWithTitle("OK")
            alert.title = "ChatApp"
            alert.message = "Internet connection not available.Please check your connection and try again."
            alert.show()
            
           return false
        }
    }

    
    private func setup() {
        do {
            self.reachability = try Reachability.reachabilityForInternetConnection()
            try reachability?.startNotifier()
          } catch _ {
            
        }
    }
    
    
    //MARK: - check internet is lost & come
    func connectionWhenReachable(reachableComplitionBlock: () -> ()) {
        if reachability == nil {
            self.setup()
        }
        
        reachability?.whenReachable = { reachable in
            reachableComplitionBlock()
        }
    }
    
    func connectionWhenUnReachable(unReachableComplitionBlock: () -> ()) {
        if reachability == nil {
            self.setup()
        }
        
        reachability?.whenUnreachable = { unreachable in
            unReachableComplitionBlock()
        }
    }

    
    deinit {
        reachability?.stopNotifier()
        reachability = nil
    }



}
