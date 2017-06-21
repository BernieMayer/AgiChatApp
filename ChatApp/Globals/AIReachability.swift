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
    
    struct Static {
        static var onceToken: Int = 0
        static var instance: AIReachability? = nil
    }
   
    private static var __once: () = {
            Static.instance = AIReachability()
            
        }()
   
    fileprivate var reachability: Reachability?
    
    // MARK: - SHARED MANAGER
    class var sharedManager: AIReachability {
      
        
        _ = AIReachability.__once
        return Static.instance!
    }
    
    
    func isAavailable() -> Bool {
        if reachability == nil {
            setup()
        }
        
        if self.reachability!.isReachable || self.reachability!.isReachableViaWiFi || self.reachability!.isReachableViaWWAN {
            return true
        } else {
            
            
           let alert : UIAlertView = UIAlertView()
            alert.addButton(withTitle: "OK")
            alert.title = "ChatApp"
            alert.message = "Internet connection not available.Please check your connection and try again."
            alert.show()
            
           return false
        }
    }

    
    fileprivate func setup() {
        do {
            self.reachability = try Reachability()
            try reachability?.startNotifier()
          } catch _ {
            
        }
    }
    
    
    //MARK: - check internet is lost & come
    func connectionWhenReachable(_ reachableComplitionBlock: @escaping () -> ()) {
        if reachability == nil {
            self.setup()
        }
        
        reachability?.whenReachable = { reachable in
            reachableComplitionBlock()
        }
    }
    
    func connectionWhenUnReachable(_ unReachableComplitionBlock: @escaping () -> ()) {
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
