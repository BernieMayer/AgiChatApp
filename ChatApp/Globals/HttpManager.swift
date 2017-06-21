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

    func httpResponceData(_ dictionary:NSMutableDictionary,manager:HttpManager)
    @objc optional  func httpFailed(_ dictionary:NSMutableDictionary,error:HttpManager)
}


class HttpManager: NSObject {
    struct Static {
        static var instance: HttpManager? = nil
        static var token: Int = 0
    }
    private static var __once: () = {
                Static.instance = HttpManager()
            }()
    
    var delegate : HttpManagerDelegate?
    var showLoader:Bool = true

    var SINGLENOTIFICATIONURL : String = "http://180.211.99.165:8080/chatapp/index.php"
    var TOPICNOTIFICATIONURL : String = "http://180.211.99.165:8080/chatapp/"
    var SUBSCRIBEURL : String = "http://180.211.99.165:8080/chatapp/notification/subscribe?"
    var UNSUBSCRIBEURL : String = "http://180.211.99.165:8080/chatapp/notification/unsubscribe?"

    class var sharedInstance: HttpManager {
        get {
            
            _ = HttpManager.__once
            return Static.instance!
        }
    }
    
       func intiailiation() {

        if  (self.delegate != nil) {
            let dic:NSMutableDictionary = NSMutableDictionary()
            dic.setObject("1", forKey: "first" as NSCopying)
            //self.delegate!.httpFailed!(dic, error: self)
            
            dic.setObject("2", forKey: "second" as NSCopying)
            
            self.delegate?.httpResponceData(dic, manager: self)
        }
    }

    
    func perform() {
        //might not be fixed right
        Alamofire.request("").responseJSON { (response) in
            let bvf = response.result.value
        }
    }
    
    
    //MARK :-  SINGLE NOTIFICATION (one-to-one chat)
    //MARK :-
    func postResponse(_ url:NSString ,loaderShow : Bool, dict:NSMutableDictionary , SuccessCompletion :@escaping (_ result:AnyObject) -> Void ,FailureCompletion :@escaping (_ result:AnyObject) -> Void){
   
        
        let strURL : String = "\(SINGLENOTIFICATIONURL)?"
        let aby : AnyObject = dict
        
        var newUrl = NSString()
        newUrl = "\(strURL)title=\(dict.value(forKey: "title")!)&body=\(dict.value(forKey: "body")!)&device_key=\(dict.value(forKey: "device_key")!)" as NSString
        NSLog(newUrl as String)
        
        //might need to .GET as a parameter
        Alamofire.request(strURL as String, parameters: aby as? [String : AnyObject] )
            .responseJSON { response in 
                switch response.result {
                case .success:
                    self.hideLoader()

                    if let JSON = response.result.value as? NSDictionary
                    {
                        var NewDict : NSMutableDictionary = NSMutableDictionary()
                        NewDict = NSMutableDictionary(dictionary: JSON)
                        
                        if (NewDict.value(forKey: "status") as AnyObject).intValue == 1
                        {
                            SuccessCompletion(NewDict)
                            
                        }
                        else
                        {
                            FailureCompletion(NewDict)
                        }
                    }
                    
                case .failure(let error):
                    FailureCompletion(error.localizedDescription as AnyObject)
             }
        }
    }
    
    
    //MARK :-  TOPIC NOTIFICATION (group chat)
    //MARK :-
    func postGroup(_ url:NSString ,loaderShow : Bool, dict:NSMutableDictionary , SuccessCompletion :@escaping (_ result:AnyObject) -> Void ,FailureCompletion :@escaping (_ result:AnyObject) -> Void){
        
        let strURL : String = "\(TOPICNOTIFICATIONURL)/index_topic.php?"
        
        let aby : AnyObject = dict
        //might need to add .GET
        Alamofire.request( strURL as String,parameters: aby as? [String : AnyObject] )
            .responseJSON { response in
                switch response.result {
                case .success:
                    self.hideLoader()
                   if let JSON = response.result.value as? NSDictionary
                    {
                        var NewDict : NSMutableDictionary = NSMutableDictionary()
                        NewDict = NSMutableDictionary(dictionary: JSON)
                        
                        if (NewDict.value(forKey: "status") as AnyObject).intValue == 1
                        {
                            SuccessCompletion(NewDict)
                        }
                        else
                        {
                            FailureCompletion(NewDict)
                        }
                        
                    }
                    
                case .failure(let error):
                    self.hideLoader()
                    FailureCompletion(error.localizedDescription as AnyObject)
                }
        }
    }
    

    
    //MARK :-  TOPIC Subscribe (group chat)
    //MARK :-
    func subscribeGroupDevice(_ url:NSString ,loaderShow : Bool, dict:NSMutableDictionary , SuccessCompletion :@escaping (_ result:AnyObject) -> Void ,FailureCompletion :@escaping (_ result:AnyObject) -> Void){
        
        let strURL : String = "\(SUBSCRIBEURL)"
        
        let aby : AnyObject = dict
        
        Alamofire.request(strURL as String, method: .get, parameters: aby as? [String : AnyObject] )
            .responseJSON { response in
                switch response.result {
                case .success:
                    self.hideLoader()
                    if let JSON = response.result.value as? NSDictionary
                    {
                        var NewDict : NSMutableDictionary = NSMutableDictionary()
                        NewDict = NSMutableDictionary(dictionary: JSON)
                        
                        if (NewDict.value(forKey: "status") as AnyObject).intValue == 1
                        {
                            SuccessCompletion(NewDict)
                        }
                        else
                        {
                            FailureCompletion(NewDict)
                        }
                        
                    }
                    
                case .failure(let error):
                    self.hideLoader()
                    FailureCompletion(error.localizedDescription as AnyObject)
                }
        }
    }
    

    //MARK :-  TOPIC UNSUBSCRIBE (group chat)
    //MARK :-
    func unSubscribeGroupDevice(_ url:NSString ,loaderShow : Bool, dict:NSMutableDictionary , SuccessCompletion :@escaping (_ result:AnyObject) -> Void ,FailureCompletion :@escaping (_ result:AnyObject) -> Void){
        
        let strURL : String = "\(UNSUBSCRIBEURL)"
        let aby : AnyObject = dict
        
        //might not be fixed right
        Alamofire.request(strURL as String, parameters: aby as? [String : AnyObject] )
            .responseJSON { response in
                switch response.result {
                case .success:
                    self.hideLoader()
                    
                    if let JSON = response.result.value as? NSDictionary
                    {
                        var NewDict : NSMutableDictionary = NSMutableDictionary()
                        NewDict = NSMutableDictionary(dictionary: JSON)
                        
                        if (NewDict.value(forKey: "status") as AnyObject).intValue == 1
                        {
                            SuccessCompletion(NewDict)
                        }
                        else
                        {
                            FailureCompletion(NewDict)
                        }
                    }
                    
                case .failure(let error):
                    self.hideLoader()
                    FailureCompletion(error.localizedDescription as AnyObject)
                }
        }
    }
    
    
    
    // MARK:
    // MARK: Make Null Values to Blank
    
    func getValuesWithOutNull(_ dict:NSMutableDictionary) -> NSMutableDictionary {
        
        let dictReplaced:NSMutableDictionary = NSMutableDictionary()
        dictReplaced.addEntries(from: dict as! [AnyHashable: Any])
        let nul = NSNull()
        let blank:NSString = ""
        
        for val in dict {
            let object:AnyObject = dict.value(forKey: val.key as! String)! as AnyObject
            if object as! NSObject == nul {
                dictReplaced.setObject(blank, forKey: val.key as! String as NSCopying)
            }
            else if object.isKind(of: NSMutableDictionary.self){
                dictReplaced.setObject(getValuesWithOutNull(object as! NSMutableDictionary), forKey: val.key as! String as NSCopying)
            }
            else if object.isKind(of: NSArray.self)
            {
                let array:NSMutableArray = NSMutableArray.init(array: object as! NSArray)
                
                for i in 0..<array.count
                    
                {
                    let object:AnyObject = array.object(at: i) as AnyObject
                    
                    if(object.isKind(of: NSDictionary.self))
                    {
                        array.replaceObject(at: i, with: getValuesWithOutNull(object as! NSMutableDictionary))
                    }
                    
                    dictReplaced.setObject(array, forKey: val.key as! String as NSCopying)
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
