//
//  UserDefaults.swift
//  ChatApp
//
//  Created by admin on 14/12/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}




 
class UserDefaults : NSObject{
    
    struct Static {
        static var instance: UserDefaults? = nil
        static var token: Int = 0
    }
    
    
    private static var __once: () = {
                Static.instance = UserDefaults()
            }()
    
    
    class var sharedInstance: UserDefaults {
        get {
           
            _ = UserDefaults.__once
            return Static.instance!
        }
    }

    
    //MARK:- GETTING ARRAY
    //MARK:-
    
    func GetArrayFromUserDefault(_ key:String)->NSMutableArray
    {
        let userDefaults = Foundation.UserDefaults.standard
        var getArray : NSMutableArray = NSMutableArray()
        
        if(userDefaults.object(forKey: key) != nil && (userDefaults.object(forKey: key) as AnyObject).count > 0)
        {
            getArray =  userDefaults.object(forKey: key) as! NSMutableArray;
        }
        return getArray;
    }
    
    //MARK:- SETTING ARRAY
    //MARK:-
    func SetArrayInUserDefault(_ array:NSMutableArray,key:String)
    {
        let userDefaults = Foundation.UserDefaults.standard
        userDefaults.set(array, forKey: key);
        userDefaults.synchronize()
    }
    
    
    //MARK:- SET DICTIONARY
    //MARK:-
    func SetDicInUserDefault(_ dic:NSMutableDictionary,key:String)
    {
        let userDefaults = Foundation.UserDefaults.standard
        userDefaults.set(dic, forKey: key);
        userDefaults.synchronize()
    }
    
    
    //MARK:- SETTING STRING
    //MARK:-
    func SetNSUserDefaultValues(_ key:String,value:String)
    {
        let userDefaults = Foundation.UserDefaults.standard
        userDefaults.set(value, forKey: key);
        userDefaults.synchronize()
    }
    
    
    //MARK:- GETTING DICTIONARY
    //MARK:-
    func GetDicFromUserDefault(_ key:String) -> NSMutableDictionary
    {
        let userDefaults = Foundation.UserDefaults.standard
        var dic:NSMutableDictionary = NSMutableDictionary()
        
        if(userDefaults.object(forKey: key) != nil)
        {
          dic =  userDefaults.object(forKey: key) as! NSMutableDictionary;
        }
        return dic;
    }
    
    
    //MARK:- GETTING STRING
    //MARK:-
    func GetNSUserDefaultValue(_ key:String) -> String
    {
        let userDefaults = Foundation.UserDefaults.standard
        var value:String = ""
        if(userDefaults.object(forKey: key) != nil)
        {
            value  = userDefaults.object(forKey: key) as! String;
        }
        
        return value;
    }
    
    
    //MARK:- GETTING VALUES WITHOUT NULL
    //MARK:-
    func getValuesWithOutNull(_ yourDictionary:NSDictionary) ->NSMutableDictionary
    {
        let replaced:NSMutableDictionary = NSMutableDictionary(dictionary: yourDictionary)
        let blank:NSString = ""
        for val in yourDictionary
        {
            let object:AnyObject = yourDictionary.object(forKey: val.key)! as AnyObject
            
            if (object is NSNull)
            {
                replaced.setObject(blank, forKey: val.key as! String as NSCopying)
            }
            else if(object.isKind(of: NSDictionary.self))
            {
                replaced.setObject(getValuesWithOutNull(object as! NSDictionary), forKey: val.key as! String as NSCopying)
            }
            else if(object.isKind(of: NSArray.self))
            {
                let array:NSMutableArray = NSMutableArray(array: object as! NSArray)
                
                for i in 0..<array.count
                {
                    let object:AnyObject = array.object(at: i) as AnyObject
                    
                    if(object.isKind(of: NSDictionary.self))
                    {
                        array.replaceObject(at: i, with: getValuesWithOutNull(object as! NSDictionary))
                    }
                    
                    replaced.setObject(array, forKey: val.key as! String as NSCopying)
                }
            }
        }
        return replaced
    }

    //MARK:- Remove user default key
    //MARK:-
    func RemoveKeyUserFefault(_ key : String){
        let userDefaults = Foundation.UserDefaults.standard
        userDefaults.removeObject(forKey: key)
    }
    
}

