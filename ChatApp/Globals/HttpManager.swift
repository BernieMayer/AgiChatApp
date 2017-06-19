//
//  HttpManager.swift
//  Munchh
//
//  Created by Agilemac-26-AMIT on 03/06/16.
//  Copyright © 2016 Agilemac-26. All rights reserved.
//

import UIKit
import Alamofire

@objc protocol HttpManagerDelegate{

    func httpResponceData(dictionary:NSMutableDictionary,manager:HttpManager)
    optional  func httpFailed(dictionary:NSMutableDictionary,error:HttpManager)
}


class HttpManager: NSObject {
    
    var delegate : HttpManagerDelegate?
    var showLoader:Bool = true

    var SINGLENOTIFICATIONURL : String = "http://180.211.99.165:8080/chatapp/index.php"
    var TOPICNOTIFICATIONURL : String = "http://180.211.99.165:8080/chatapp/"
    var SUBSCRIBEURL : String = "http://180.211.99.165:8080/chatapp/notification/subscribe?"
    var UNSUBSCRIBEURL : String = "http://180.211.99.165:8080/chatapp/notification/unsubscribe?"

    class var sharedInstance: HttpManager {
        get {
            struct Static {
                static var instance: HttpManager? = nil
                static var token: dispatch_once_t = 0
            }
            dispatch_once(&Static.token, {
                Static.instance = HttpManager()
            })
            return Static.instance!
        }
    }
    
       func intiailiation() {

        if  (self.delegate != nil) {
            let dic:NSMutableDictionary = NSMutableDictionary()
            dic.setObject("1", forKey: "first")
            //self.delegate!.httpFailed!(dic, error: self)
            
            dic.setObject("2", forKey: "second")
            
            self.delegate?.httpResponceData(dic, manager: self)
        }
    }

    
    func perform() {
        Alamofire.request(.GET, "").responseJSON { (response) in
            let bvf = response.result.value
        }
    }
    
    
    //MARK :-  SINGLE NOTIFICATION (one-to-one chat)
    //MARK :-
    func postResponse(url:NSString ,loaderShow : Bool, dict:NSMutableDictionary , SuccessCompletion :(result:AnyObject) -> Void ,FailureCompletion :(result:AnyObject) -> Void){
   
        
        let strURL : String = "\(SINGLENOTIFICATIONURL)?"
        let aby : AnyObject = dict
        
        var newUrl = NSString()
        newUrl = "\(strURL)title=\(dict.valueForKey("title")!)&body=\(dict.valueForKey("body")!)&device_key=\(dict.valueForKey("device_key")!)"
        NSLog(newUrl as String)
        
        Alamofire.request(.GET, strURL as String,parameters: aby as? [String : AnyObject] )
            .responseJSON { response in 
                switch response.result {
                case .Success:
                    self.hideLoader()

                    if let JSON = response.result.value as? NSDictionary
                    {
                        var NewDict : NSMutableDictionary = NSMutableDictionary()
                        NewDict = NSMutableDictionary(dictionary: JSON)
                        
                        if NewDict.valueForKey("status")?.intValue == 1
                        {
                            SuccessCompletion(result: NewDict)
                            
                        }
                        else
                        {
                            FailureCompletion(result: NewDict)
                        }
                    }
                    
                case .Failure(let error):
                    FailureCompletion(result: error.localizedDescription)
             }
        }
    }
    
    
    //MARK :-  TOPIC NOTIFICATION (group chat)
    //MARK :-
    func postGroup(url:NSString ,loaderShow : Bool, dict:NSMutableDictionary , SuccessCompletion :(result:AnyObject) -> Void ,FailureCompletion :(result:AnyObject) -> Void){
        
        let strURL : String = "\(TOPICNOTIFICATIONURL)/index_topic.php?"
        
        let aby : AnyObject = dict
        
        Alamofire.request(.GET, strURL as String,parameters: aby as? [String : AnyObject] )
            .responseJSON { response in
                switch response.result {
                case .Success:
                    self.hideLoader()
                   if let JSON = response.result.value as? NSDictionary
                    {
                        var NewDict : NSMutableDictionary = NSMutableDictionary()
                        NewDict = NSMutableDictionary(dictionary: JSON)
                        
                        if NewDict.valueForKey("status")?.intValue == 1
                        {
                            SuccessCompletion(result: NewDict)
                        }
                        else
                        {
                            FailureCompletion(result: NewDict)
                        }
                        
                    }
                    
                case .Failure(let error):
                    self.hideLoader()
                    FailureCompletion(result: error.localizedDescription)
                }
        }
    }
    

    
    //MARK :-  TOPIC Subscribe (group chat)
    //MARK :-
    func subscribeGroupDevice(url:NSString ,loaderShow : Bool, dict:NSMutableDictionary , SuccessCompletion :(result:AnyObject) -> Void ,FailureCompletion :(result:AnyObject) -> Void){
        
        let strURL : String = "\(SUBSCRIBEURL)"
        
        let aby : AnyObject = dict
        
        Alamofire.request(.GET, strURL as String,parameters: aby as? [String : AnyObject] )
            .responseJSON { response in
                switch response.result {
                case .Success:
                    self.hideLoader()
                    if let JSON = response.result.value as? NSDictionary
                    {
                        var NewDict : NSMutableDictionary = NSMutableDictionary()
                        NewDict = NSMutableDictionary(dictionary: JSON)
                        
                        if NewDict.valueForKey("status")?.intValue == 1
                        {
                            SuccessCompletion(result: NewDict)
                        }
                        else
                        {
                            FailureCompletion(result: NewDict)
                        }
                        
                    }
                    
                case .Failure(let error):
                    self.hideLoader()
                    FailureCompletion(result: error.localizedDescription)
                }
        }
    }
    

    //MARK :-  TOPIC UNSUBSCRIBE (group chat)
    //MARK :-
    func unSubscribeGroupDevice(url:NSString ,loaderShow : Bool, dict:NSMutableDictionary , SuccessCompletion :(result:AnyObject) -> Void ,FailureCompletion :(result:AnyObject) -> Void){
        
        let strURL : String = "\(UNSUBSCRIBEURL)"
        let aby : AnyObject = dict
        
        Alamofire.request(.GET, strURL as String,parameters: aby as? [String : AnyObject] )
            .responseJSON { response in
                switch response.result {
                case .Success:
                    self.hideLoader()
                    
                    if let JSON = response.result.value as? NSDictionary
                    {
                        var NewDict : NSMutableDictionary = NSMutableDictionary()
                        NewDict = NSMutableDictionary(dictionary: JSON)
                        
                        if NewDict.valueForKey("status")?.intValue == 1
                        {
                            SuccessCompletion(result: NewDict)
                        }
                        else
                        {
                            FailureCompletion(result: NewDict)
                        }
                    }
                    
                case .Failure(let error):
                    self.hideLoader()
                    FailureCompletion(result: error.localizedDescription)
                }
        }
    }
    
    
    
    // MARK:
    // MARK: Make Null Values to Blank
    
    func getValuesWithOutNull(dict:NSMutableDictionary) -> NSMutableDictionary {
        
        let dictReplaced:NSMutableDictionary = NSMutableDictionary()
        dictReplaced.addEntriesFromDictionary(dict as [NSObject : AnyObject])
        let nul = NSNull()
        let blank:NSString = ""
        
        for val in dict {
            let object:AnyObject = dict.valueForKey(val.key as! String)!
            if object as! NSObject == nul {
                dictReplaced.setObject(blank, forKey: val.key as! String)
            }
            else if object.isKindOfClass(NSMutableDictionary){
                dictReplaced.setObject(getValuesWithOutNull(object as! NSMutableDictionary), forKey: val.key as! String)
            }
            else if object.isKindOfClass(NSArray)
            {
                let array:NSMutableArray = NSMutableArray.init(array: object as! NSArray)
                
                for i in 0..<array.count
                    
                {
                    let object:AnyObject = array.objectAtIndex(i)
                    
                    if(object.isKindOfClass(NSDictionary))
                    {
                        array.replaceObjectAtIndex(i, withObject: getValuesWithOutNull(object as! NSMutableDictionary))
                    }
                    
                    dictReplaced.setObject(array, forKey: val.key as! String)
                }
            }
        }
        return dictReplaced
    }
    
    // MARK:
    // MARK:
    // MARK: ShowLoader - HideLoader
    
    func actionShowLoader()
    {
        ShowLoader()
    }
    func hideLoader(){
        HideLoader()
    }
}
