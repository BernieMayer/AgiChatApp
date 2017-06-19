//
//  AIDateTime.swift
//  ChatApp
//
//  Created by admin on 21/11/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import Foundation




//MARK:- Get Current Year
//MARK:-
func getCurrentYear() -> Int
{
    
    let date = NSDate()
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Day , .Month , .Year], fromDate: date)
    let year =  components.year
    return year
}


//MARK:- Convert Date to String
//MARK:-
func convertDate(str:String) -> String
{
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MMM dd, yyyy hh:mm:ss a"
    var date = dateFormatter.dateFromString(str)
    var dateString:String!
    if(date == nil){
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss a"
        date = dateFormatter.dateFromString(str)
        
        dateFormatter.dateFormat = "HH:mm a"
        dateString  = dateFormatter.stringFromDate(date!)
    }else{
        dateFormatter.dateFormat = "hh:mm a"
        dateString  = dateFormatter.stringFromDate(date!)
    }
    return dateString
}


//MARK:- Convert Date From String
//MARK:-
func convertDateFromString(str:String) -> Int
{
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "hh:mm:ss a"
    let date = dateFormatter.dateFromString(str)
    
    // To convert the date into an HH:mm format
    dateFormatter.dateFormat = "HH:mm"
    let dateString = dateFormatter.stringFromDate(date!)
   
    return Int(dateString)!
}


