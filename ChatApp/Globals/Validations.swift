//
//  Validations.swift
//  ChatApp
//
//  Created by admin on 14/11/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import Foundation


func isGivenEmailValidForString(strEmail:String) -> Bool{
    /*
     validate email address using string
     */
    let stricterFilterString:String = "[A-Z0-9a-z]+([._+-]{1}[A-Z0-9a-z]+)*@[A-Za-z0-9]+\\.([A-Za-z])*([A-Za-z0-9]+\\.[A-Za-z]{2,4})*" as String
    
    //Create predicate with format matching your regex string
    let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", stricterFilterString)
    
    //return true if email address is valid
    let boolToReturn:Bool = emailTest.evaluateWithObject(strEmail as String)
    
    return boolToReturn;
}


func isGivenPhoneNumberValidForString(strPhone:String) -> Bool{
    /*
     validate phone number using string
     */

    let phoneRegex = "^((\\+)|(00))[0-9]{6,14}$" as String
    
    //Create predicate with format matching your regex string
    let phone:NSPredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
    
    //return true if email address is valid
    let boolToReturn:Bool = phone.evaluateWithObject(strPhone as String)
    
    return boolToReturn;
}

