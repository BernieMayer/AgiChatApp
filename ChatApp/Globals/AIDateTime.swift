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
    
    let date = Date()
    let calendar = Calendar.current
    let components = (calendar as NSCalendar).components([.day , .month , .year], from: date)
    let year =  components.year
    return year!
}


//MARK:- Convert Date to String
//MARK:-
func convertDate(_ str:String) -> String
{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd, yyyy hh:mm:ss a"
    var date = dateFormatter.date(from: str)
    var dateString:String!
    if(date == nil){
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss a"
        date = dateFormatter.date(from: str)
        
        dateFormatter.dateFormat = "HH:mm a"
        dateString  = dateFormatter.string(from: date!)
    }else{
        dateFormatter.dateFormat = "hh:mm a"
        dateString  = dateFormatter.string(from: date!)
    }
    return dateString
}


//MARK:- Convert Date From String
//MARK:-
func convertDateFromString(_ str:String) -> Int
{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "hh:mm:ss a"
    let date = dateFormatter.date(from: str)
    
    // To convert the date into an HH:mm format
    dateFormatter.dateFormat = "HH:mm"
    let dateString = dateFormatter.string(from: date!)
   
    return Int(dateString)!
}


