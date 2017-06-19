//
//  UserDefaults.swift
//  ChatApp
//
//  Created by admin on 14/12/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import Foundation



 
class UserDefaults : NSObject{
    
    
    class var sharedInstance: UserDefaults {
        get {
            struct Static {
                static var instance: UserDefaults? = nil
                static var token: dispatch_once_t = 0
            }
            dispatch_once(&Static.token, {
                Static.instance = UserDefaults()
            })
            return Static.instance!
        }
    }

    
    //MARK:- GETTING ARRAY
    //MARK:-
    
    func GetArrayFromUserDefault(let key:String)->NSMutableArray
    {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var getArray : NSMutableArray = NSMutableArray()
        
        if(userDefaults.objectForKey(key) != nil && userDefaults.objectForKey(key)?.count > 0)
        {
            getArray =  userDefaults.objectForKey(key)?.mutableCopy() as! NSMutableArray;
        }
        return getArray;
    }
    
    //MARK:- SETTING ARRAY
    //MARK:-
    func SetArrayInUserDefault(let array:NSMutableArray,let key:String)
    {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(array, forKey: key);
        userDefaults.synchronize()
    }
    
    
    //MARK:- SET DICTIONARY
    //MARK:-
    func SetDicInUserDefault(let dic:NSMutableDictionary,let key:String)
    {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(dic, forKey: key);
        userDefaults.synchronize()
    }
    
    
    //MARK:- SETTING STRING
    //MARK:-
    func SetNSUserDefaultValues(let key:String,let value:String)
    {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(value, forKey: key);
        userDefaults.synchronize()
    }
    
    
    //MARK:- GETTING DICTIONARY
    //MARK:-
    func GetDicFromUserDefault(let key:String) -> NSMutableDictionary
    {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var dic:NSMutableDictionary = NSMutableDictionary()
        
        if(userDefaults.objectForKey(key) != nil)
        {
          dic =  userDefaults.objectForKey(key) as! NSMutableDictionary;
        }
        return dic;
    }
    
    
    //MARK:- GETTING STRING
    //MARK:-
    func GetNSUserDefaultValue(let key:String) -> String
    {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var value:String = ""
        if(userDefaults.objectForKey(key) != nil)
        {
            value  = userDefaults.objectForKey(key) as! String;
        }
        
        return value;
    }
    
    
    //MARK:- GETTING VALUES WITHOUT NULL
    //MARK:-
    func getValuesWithOutNull(yourDictionary:NSDictionary) ->NSMutableDictionary
    {
        let replaced:NSMutableDictionary = NSMutableDictionary(dictionary: yourDictionary)
        let blank:NSString = ""
        for val in yourDictionary
        {
            let object:AnyObject = yourDictionary.objectForKey(val.key)!
            
            if (object is NSNull)
            {
                replaced.setObject(blank, forKey: val.key as! String)
            }
            else if(object.isKindOfClass(NSDictionary))
            {
                replaced.setObject(getValuesWithOutNull(object as! NSDictionary), forKey: val.key as! String)
            }
            else if(object.isKindOfClass(NSArray))
            {
                let array:NSMutableArray = NSMutableArray(array: object as! NSArray)
                
                for i in 0..<array.count
                {
                    let object:AnyObject = array.objectAtIndex(i)
                    
                    if(object.isKindOfClass(NSDictionary))
                    {
                        array.replaceObjectAtIndex(i, withObject: getValuesWithOutNull(object as! NSDictionary))
                    }
                    
                    replaced.setObject(array, forKey: val.key as! String)
                }
            }
        }
        return replaced
    }

    //MARK:- Remove user default key
    //MARK:-
    func RemoveKeyUserFefault(key : String){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey(key)
    }
    
}

