//
//  Extensions.swift
//  Spotliss
//
//  Created by Agile-mac on 07/07/16.
//  Copyright © 2016 Agile-mac. All rights reserved.
//

import Foundation
import UIKit



//MARK: - NSBundle EXTENSIONS
//MARK: -
extension NSBundle {
    
    var releaseVersionNumber: String! {
        return self.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    var buildVersionNumber: String {
        return self.infoDictionary?["CFBundleVersion"] as! String
    }
    
    var appName: String {
        return self.infoDictionary?["CFBundleName"] as! String
    }
}


//MARK: - Character EXTENSIONS
//MARK: -
extension Character {
    func isEmoji() -> Bool {
        return Character(UnicodeScalar(0x1d000)) <= self && self <= Character(UnicodeScalar(0x1f77f))
            || Character(UnicodeScalar(0x1f900)) <= self && self <= Character(UnicodeScalar(0x1f9ff))
            || Character(UnicodeScalar(0x2100)) <= self && self <= Character(UnicodeScalar(0x26ff))
    }
}



//MARK: - NSDictionary EXTENSIONS
//MARK: -
extension NSDictionary{
    
    func object_forKeyWithValidationForClass_Int(aKey: String) -> Int {
        
        // CHECK FOR EMPTY
        if(self.allKeys.count == 0) {
            return Int()
        }
        
        // CHECK IF KEY EXIST
        if let val = self.objectForKey(aKey) {
            if(val.isEqual(NSNull())) {
                return Int()
            }
        } else {
            // KEY NOT FOUND
            return Int()
        }
        
        // CHECK FOR NIL VALUE
        let aValue : AnyObject = self.objectForKey(aKey)!
        if aValue.isEqual(NSNull()) {
            return Int()
        }
        else {
            return self.objectForKey(aKey) as! Int
        }
    }
    
    func object_forKeyWithValidationForClass_CGFloat(aKey: String) -> CGFloat {
        
        // CHECK FOR EMPTY
        if(self.allKeys.count == 0) {
            return CGFloat()
        }
        
        // CHECK IF KEY EXIST
        if let val = self.objectForKey(aKey) {
            if(val.isEqual(NSNull())) {
                return CGFloat()
            }
            else if(val as! String == "") {
                return 0.00
            }
        } else {
            // KEY NOT FOUND
            return CGFloat()
        }
        
        // CHECK FOR NIL VALUE
        let aValue : AnyObject = self.objectForKey(aKey)!
        if aValue.isEqual(NSNull()) {
            return CGFloat()
        }
        else {
            return self.objectForKey(aKey) as! CGFloat
        }
    }
    
    func object_forKeyWithValidationForClass_String(aKey: String) -> String {
        
        
        // CHECK FOR EMPTY
        if(self.allKeys.count == 0) {
            return String()
        }
        
        // CHECK IF KEY EXIST
        if let val = self.objectForKey(aKey) {
            if(val.isEqual(NSNull())) {
                return String()
            }
        } else {
            // KEY NOT FOUND
            return String()
        }
        
        // CHECK FOR NIL VALUE
        let aValue : AnyObject = self.objectForKey(aKey)!
        if aValue.isEqual(NSNull()) {
        
            return String()
        }
        else {
            
            if aValue is String {
                return self.objectForKey(aKey) as! String
            }
            else{
                return String()
            }
            
            //			return self.objectForKey(aKey) as! String
        }
        
    }
    
 
    
    func object_forKeyWithValidationForClass_Bool(aKey: String) -> Bool {
        // CHECK FOR EMPTY
        if(self.allKeys.count == 0) {
            return Bool()
        }
        
        // CHECK IF KEY EXIST
        if let val = self.objectForKey(aKey) {
            if(val.isEqual(NSNull())) {
                return Bool()
            }
        } else {
            // KEY NOT FOUND
            return Bool()
        }
        
        // CHECK FOR NIL VALUE
        let aValue : AnyObject = self.objectForKey(aKey)!
        if aValue.isEqual(NSNull()) {
            return Bool()
        }
        else {
            return self.objectForKey(aKey) as! Bool
        }
    }
    
    func object_forKeyWithValidationForClass_NSArray(aKey: String) -> NSArray {
        // CHECK FOR EMPTY
        if(self.allKeys.count == 0) {
            return NSArray()
        }
        
        // CHECK IF KEY EXIST
        if let val = self.objectForKey(aKey) {
            if(val.isEqual(NSNull())) {
                return NSArray()
            }
        } else {
            // KEY NOT FOUND
            return NSArray()
        }
        
        // CHECK FOR NIL VALUE
        let aValue : AnyObject = self.objectForKey(aKey)!
        if aValue.isEqual(NSNull()) {
            return NSArray()
        }
        else {
            return self.objectForKey(aKey) as! NSArray
        }
    }
    
    func object_forKeyWithValidationForClass_NSMutableArray(aKey: String) -> NSMutableArray {
        // CHECK FOR EMPTY
        
        if(self.allKeys.count == 0) {
            return NSMutableArray()
        }
        
        // CHECK IF KEY EXIST
        if let val = self.objectForKey(aKey) {
            if(val.isEqual(NSNull())) {
                return NSMutableArray()
            }
        } else {
            // KEY NOT FOUND
            return NSMutableArray()
        }
        
        // CHECK FOR NIL VALUE
        let aValue : AnyObject = self.objectForKey(aKey)!
        if aValue.isEqual(NSNull()) {
            return NSMutableArray()
        }
        else {
            return (self.objectForKey(aKey))?.mutableCopy() as! NSMutableArray
        }
    }
    
    func object_forKeyWithValidationForClass_NSDictionary(aKey: String) -> NSDictionary {
        // CHECK FOR EMPTY
        if(self.allKeys.count == 0) {
            return NSDictionary()
        }
        
        // CHECK IF KEY EXIST
        if let val = self.objectForKey(aKey) {
            if(val.isEqual(NSNull())) {
                return NSDictionary()
            }
        } else {
            // KEY NOT FOUND
            return NSDictionary()
        }
        
        // CHECK FOR NIL VALUE
        let aValue : AnyObject = self.objectForKey(aKey)!
        if aValue.isEqual(NSNull()) {
            return NSDictionary()
        }
        else {
            return self.objectForKey(aKey) as! NSDictionary
        }
    }
    
    func object_forKeyWithValidationForClass_NSMutableDictionary(aKey: String) -> NSMutableDictionary {
        // CHECK FOR EMPTY
        if(self.allKeys.count == 0) {
            return NSMutableDictionary()
        }
        
        // CHECK IF KEY EXIST
        if let val = self.objectForKey(aKey) {
            if(val.isEqual(NSNull())) {
                return NSMutableDictionary()
            }
        } else {
            // KEY NOT FOUND
            return NSMutableDictionary()
        }
        
        // CHECK FOR NIL VALUE
        let aValue : AnyObject = self.objectForKey(aKey)!
        if aValue.isEqual(NSNull()) {
            return NSMutableDictionary()
        }
        else {
            return self.objectForKey(aKey) as! NSMutableDictionary
        }
    }
    
    func dictionaryByReplacingNullsWithBlanks() -> NSMutableDictionary {
        let dictReplaced : NSMutableDictionary = self.mutableCopy() as! NSMutableDictionary
        let null : AnyObject = NSNull()
        let blank : NSString = ""
        for key : AnyObject in self.allKeys {
            let strKey : NSString  = key as! NSString
            let object : AnyObject = self.objectForKey(strKey)!
            if object.isEqual(null) {
                dictReplaced.setObject(blank, forKey: strKey)
                //                dictReplaced.removeObjectForKey(strKey)
            }else if object.isKindOfClass(NSDictionary) {
                dictReplaced.setObject(object.dictionaryByReplacingNullsWithBlanks(), forKey: strKey)
            }else if object.isKindOfClass(NSArray) {
                dictReplaced.setObject(object.arrayByReplacingNullsWithBlanks(), forKey: strKey)
            }
        }
        return dictReplaced
    }
    
    func dictionaryByAppendingKey(value : String) -> NSMutableDictionary {
        let dictReplaced : NSMutableDictionary = self.mutableCopy() as! NSMutableDictionary
        dictReplaced.setObject(value, forKey: "reviewType")
        return dictReplaced
    }
    
}


//MARK: - NSArray EXTENSIONS
//MARK: -
extension NSArray{
    
    func arrayByReplacingNullsWithBlanks () -> NSMutableArray {
        let arrReplaced : NSMutableArray = self.mutableCopy() as! NSMutableArray
        let null : AnyObject = NSNull()
        let blank : NSString = ""
        
        for idx in 0..<arrReplaced.count {
            let object : AnyObject = arrReplaced.objectAtIndex(idx)
            if object.isEqual(null) {
                arrReplaced.setValue(blank, forKey: object.key!!)
                //                arrReplaced.removeObjectAtIndex(idx)
            }else if object.isKindOfClass(NSDictionary) {
                arrReplaced.replaceObjectAtIndex(idx, withObject: object.dictionaryByReplacingNullsWithBlanks())
            }else if object.isKindOfClass(NSArray) {
                arrReplaced.replaceObjectAtIndex(idx, withObject: object.arrayByReplacingNullsWithBlanks())
            }
        }
        
        return arrReplaced
    }
    
    func arrayByAppendingKey(value : String) -> NSMutableArray {
        let arrReplaced : NSMutableArray = self.mutableCopy() as! NSMutableArray
        
        for idx in 0..<arrReplaced.count {
            let object : AnyObject = arrReplaced.objectAtIndex(idx)
            if object.isKindOfClass(NSDictionary) {
                arrReplaced.replaceObjectAtIndex(idx, withObject: object.dictionaryByAppendingKey(value))
            }
        }
        return arrReplaced
    }
}






