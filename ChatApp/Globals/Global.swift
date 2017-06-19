
//  Global.swift
//  ChatApp
//
//  Created by admin on 14/12/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import Foundation
import Contacts
import ContactsUI
import Firebase
import FirebaseDatabase


//MARK:- Fetch and compare contacts
//MARK:-
var arrContacts : NSMutableArray = NSMutableArray()
var arrFilteredContacts : NSMutableArray = NSMutableArray()
var arrFilteredInviteContacts : NSMutableArray = NSMutableArray()
private var _refHandle: FIRDatabaseHandle!                                               //Firebase database reference handle
var cntryCode : String = String()                                                                   //Country Codes
var ref = FIRDatabase.database().reference() as FIRDatabaseReference    //Firebase database reference


@available(iOS 9.0, *)

//MARK:- Fetch Contacts from device
//MARK:-
func fetchContacts(completion: (result: NSMutableArray) -> Void  )
{
    let contactStore = CNContactStore()
    let finalArrayForContacts = NSMutableArray()
    let contactsArray = NSMutableArray()
    let requestForContacts = CNContactFetchRequest(keysToFetch: [CNContactIdentifierKey, CNContactFormatter.descriptorForRequiredKeysForStyle(CNContactFormatterStyle.FullName), CNContactPhoneNumbersKey ,CNContactThumbnailImageDataKey])
    do{
        try contactStore.enumerateContactsWithFetchRequest(requestForContacts) { (contactStore : CNContact, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            contactsArray.addObject(contactStore)
        }
    }
    catch {
        
    }
    if contactsArray.count > 0 {
        let formatter = CNContactFormatter()
        for contactTemp  in contactsArray
        {
            let contactNew = contactTemp as! CNContact
            //Contact Name
            var stringFromContact = formatter.stringFromContact(contactNew)
            if stringFromContact == nil {
                stringFromContact = "Unnamed"
            }
            
            var imageData = NSData?()
            if contactNew.thumbnailImageData != nil{
                imageData = contactNew.thumbnailImageData!
            }else{
                //imageData = nil
            }
            var tempArray : NSArray = NSArray()
            if (contactNew.phoneNumbers).count > 0 {
                tempArray = ((contactNew.phoneNumbers as? NSArray)?.valueForKey("value").valueForKey("digits")) as! NSArray
                for i in 0  ..< tempArray.count
                {
                    let newDict = NSMutableDictionary()
                    let phoneNumber : String = (tempArray.objectAtIndex(i)) as! String
                    
                    if phoneNumber.characters.count > 0 {
                        var test = false
                        
                        if phoneNumber.hasPrefix("+")
                        {
                            test = true
                        }
                        var resultString : String = (phoneNumber.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) as NSArray).componentsJoinedByString("")
                        
                        if test == true
                        {
                            resultString = "\(resultString)"
                        }
                        else
                        {
                            cntryCode = UserDefaults.sharedInstance.GetNSUserDefaultValue(countryCode)
                            resultString = "\(cntryCode)\(resultString)"
                        }
                        
                        newDict.setValue(resultString, forKey: "contact_phone")
                        newDict.setValue(stringFromContact, forKey: "contact_name")
                        newDict.setValue("0", forKey: "contact_select")
                        newDict.setValue(imageData, forKey: "contact_image")
                        finalArrayForContacts.addObject(newDict)
                    }
                }
            }else{
                // no number saved
            }
        }
    }else {
        print("No Contacts Found")
    }
    completion(result: finalArrayForContacts)
}


@available(iOS 9.0, *)
//MARK:- Retrieve all firebase user's data (firebase user's that exists from device contact)
//MARK:-
func gettingAllData(completionHandler : (Void) -> Void )
{
    
    if(AIReachability.sharedManager.isAavailable())
    {
        arrFilteredContacts.removeAllObjects()
        arrFilteredInviteContacts.removeAllObjects()
        arrContacts.removeAllObjects()
        
        fetchContacts { (result) in
            arrContacts = result
            
        for i in 0..<arrContacts.count
        {
          let contactRef = ref.child("users").queryOrderedByChild("phoneNo").queryEqualToValue(arrContacts.objectAtIndex(i).objectForKey("contact_phone"))
          contactRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if(snapshot.exists())
            {
              //Storing snapshot in dictionary
              let dicttemp1 = snapshot.valueInExportFormat() as! NSMutableDictionary
               for strchildrenid in dicttemp1.allKeys {
                let dict: NSMutableDictionary = NSMutableDictionary()
                let dicttemp = dicttemp1.valueForKey(strchildrenid as! String) as! NSMutableDictionary
                dict.setObject(strchildrenid as! String, forKey: "userId")
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("email"), forKey: "email")
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("firstName"), forKey: "firstName")
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("lastName"), forKey: "lastName")
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("gender"), forKey: "gender")
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("phoneNo"), forKey: "phoneNo")
                dict.setObject(arrContacts.objectAtIndex(i).valueForKey("contact_name")!, forKey: "contactName")
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("profilePic"), forKey: "profilePic")
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("deviceToken"), forKey: "deviceToken")
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("status"), forKey: "status")
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("date"), forKey: "date")
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("month"), forKey: "month")
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("year"), forKey: "year")
                
                 //if mobile contact is firebase user
                 if(dict.objectForKey("phoneNo") as! String != NSUserDefaults.standardUserDefaults().objectForKey(mobileKey) as! String)
                 {
                    arrFilteredContacts.addObject(dict)
                 }
            }
         }
         else
         {
           let newDict : NSMutableDictionary = NSMutableDictionary()
           newDict.setObject("", forKey: "userId")
           newDict.setObject("", forKey: "date")
           newDict.setObject("", forKey: "deviceToken")
           newDict.setObject("", forKey: "email")
           newDict.setObject(arrContacts.objectAtIndex(i).valueForKey("contact_name")!, forKey: "contactName")
           newDict.setObject(arrContacts.objectAtIndex(i).valueForKey("contact_phone")!, forKey: "phoneNo")
           newDict.setObject("", forKey: "firstName")
           newDict.setObject("", forKey: "lastName")
           newDict.setObject("", forKey: "gender")
           newDict.setObject("", forKey: "email")
           newDict.setObject("", forKey: "profilePic")
           newDict.setObject("", forKey: "month")
           newDict.setObject("", forKey: "year")
           newDict.setObject(arrContacts.objectAtIndex(i).valueForKey("contact_phone")!, forKey: "status")
           arrFilteredInviteContacts.addObject(newDict)
        }
         if i == arrContacts.count-1{
           let arrTemp : NSMutableArray = NSMutableArray()
                        
            ///ARRAY FOR EXISTING CONTACTS
            arrFilteredContacts = NSMutableArray(array:  arrFilteredContacts.sortedArrayUsingDescriptors([NSSortDescriptor(key: "contactName", ascending: true)]) as! [[String:AnyObject]])
            arrTemp.addObjectsFromArray(arrFilteredContacts as [AnyObject])
            UserDefaults.sharedInstance.SetArrayInUserDefault(arrFilteredContacts, key: phoneContacts)
           
            ///// ARRAY FOR INVITE CONTACTS /////
            arrFilteredInviteContacts = NSMutableArray(array:  arrFilteredInviteContacts.sortedArrayUsingDescriptors([NSSortDescriptor(key: "contactName", ascending: true)]) as! [[String:AnyObject]])
            arrTemp.addObjectsFromArray(arrFilteredInviteContacts as [AnyObject])
            UserDefaults.sharedInstance.SetArrayInUserDefault(arrTemp, key:allContacts)
           // HideLoader()
             completionHandler()
          }

        })
           
      }
    }
  }
}


//MARK:- GET USERS CURRENT USER DETAILS(Logged In User)
//MARK:-
func getCurrentUser(phoneNo : String, completionHandler : ((status : Bool)-> Void) )
{
    
 
    //Getting User name for recent chats
    let dbRef = FIRDatabase.database().reference()             //Database reference
    let userRef = dbRef.child("users")                                  //User reference
    let queryRef = userRef.queryOrderedByChild("phoneNo").queryEqualToValue(phoneNo) //User matching phone no. reference
    
               //Fetching snaphot of current User
    
       queryRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in         //Observe single event will fetch data at once
        
        if(snapshot.exists()) //Checks snapsht exists or not
        {
             let dicttempUser = snapshot.valueInExportFormat() as! NSMutableDictionary
             for strchildrenid in dicttempUser.allKeys{
                
                var dicttemp = dicttempUser.valueForKey(strchildrenid as! String)
                
                Constants.loginFields.userId = strchildrenid as! String //Storing current user's id to constant so can be user throughout app
                UserDefaults.sharedInstance.RemoveKeyUserFefault(currentUserId) //Removing old reference from user default of crrent userid
                UserDefaults.sharedInstance.SetNSUserDefaultValues(currentUserId, value: Constants.loginFields.userId) //Storing current user's id to User Default
                
                //Storing current user's details to constant so can be user throughout app
                Constants.loginFields.name = (dicttemp!.valueForKey("firstName"))! as! String
                Constants.loginFields.lastName = (dicttemp!.valueForKey("lastName"))! as! String
                Constants.loginFields.phoneNo = (dicttemp!.valueForKey("phoneNo"))! as! String
                Constants.loginFields.email = (dicttemp!.valueForKey("email"))! as! String
                Constants.loginFields.imageUrl = (dicttemp!.valueForKey("profilePic"))! as! String
                Constants.loginFields.deviceToken = (dicttemp!.valueForKey("deviceToken"))! as! String
                Constants.loginFields.status = (dicttemp!.valueForKey("status"))! as! String
                Constants.loginFields.day = (dicttemp!.valueForKey("date"))! as! String
                Constants.loginFields.month = (dicttemp!.valueForKey("month"))! as! String
                Constants.loginFields.year = (dicttemp!.valueForKey("year"))! as! String
                Constants.loginFields.gender = (dicttemp!.valueForKey("gender"))! as! String
                
                 //Storing current user's detail to User Default
                UserDefaults.sharedInstance.SetNSUserDefaultValues(fName, value: Constants.loginFields.name)
                UserDefaults.sharedInstance.SetNSUserDefaultValues(lName, value: Constants.loginFields.lastName)
                UserDefaults.sharedInstance.SetNSUserDefaultValues(mobileKey, value: Constants.loginFields.phoneNo)
                UserDefaults.sharedInstance.SetNSUserDefaultValues(email, value: Constants.loginFields.email)
                UserDefaults.sharedInstance.SetNSUserDefaultValues(profilePic, value: Constants.loginFields.imageUrl)
                NSUserDefaults.standardUserDefaults().setObject(Constants.loginFields.deviceToken, forKey: "device_key")
                UserDefaults.sharedInstance.SetNSUserDefaultValues(status, value: Constants.loginFields.status)
                UserDefaults.sharedInstance.SetNSUserDefaultValues(date, value: Constants.loginFields.day)
                UserDefaults.sharedInstance.SetNSUserDefaultValues(month, value: Constants.loginFields.month)
                UserDefaults.sharedInstance.SetNSUserDefaultValues(year, value: Constants.loginFields.year)
                UserDefaults.sharedInstance.SetNSUserDefaultValues(gender, value: Constants.loginFields.gender)
                
                
                dicttemp = nil
                userRef.child("phoneNo").removeAllObservers() //removing observer
                completionHandler(status: true)
            }
        }
    })
}


//MARK:- Update Status
//MARK:-
func changeStatus(data: [String: String], data1 : String)
{
    //Change staus of current user
    var mdata = data
    
    let statusRef = ref.child("statuses")
    let queryRef = statusRef.queryOrderedByChild("status").queryEqualToValue(data1)
    
     queryRef.observeEventType(.Value, withBlock: { (snapshot) in
        ShowLoader()
      if(UserDefaults.sharedInstance.GetNSUserDefaultValue(currentUserId) != "" && UserDefaults.sharedInstance.GetNSUserDefaultValue(currentUserId) != "userId" )
      {
            if(snapshot.exists())
            {
                //snapshot exists it will update in users detail
               Constants.loginFields.status = data1
               ref.child("users").child(Constants.loginFields.userId).updateChildValues(data)
               ref.child("statuses").queryOrderedByChild("status").queryEqualToValue(data1).removeAllObservers()
               queryRef.removeAllObservers()
            }
            else
            {
                //snapshot not exists it will add in users detail
                mdata[Constants.statusField.userId] = Constants.loginFields.userId
                let postRef = ref.child("statuses")
                let postRef1 =  postRef.childByAutoId()
                postRef1.setValue(mdata)
                ref.child("users").child(Constants.loginFields.userId).updateChildValues(data)
                queryRef.removeAllObservers()
            }
        }
        HideLoader()
    })
}


//MARK:- Get Active Status (user is online/offline)
//MARK:-
func getOnlineStatus(userId : String, completionHandler : (str : String) -> Void) -> Void
{
    var str : String = String()
    _refHandle = ref.child("activeStatus").child(userId).observeEventType(.Value, withBlock: { (snapshot) in

        if(snapshot.exists())
        {
            str = (snapshot.value?.valueForKey("isOnline"))! as! String
            completionHandler(str: str)
        }
        else
        {
            print("nothing")
        }
    })
}


//MARK:- Get Image User
//MARK:-
func getProfileImage(userId : String, completionHandler : (str : String) -> Void) -> String
{
    var str : String = String()
    ref.child("users").child(userId).observeEventType(.Value, withBlock: { (snapshot) in
        
        if(snapshot.exists())
        {
            str = (snapshot.value?.valueForKey("profilePic"))! as! String
            completionHandler(str: str)
        }
        else
        {
            print("nothing")
        }
        
    })
    return  str
}


 //MARK:- OnDisconnect Method
 //MARK:-
func onDisconnect(userId : String)  {
    
    let connectedRef = FIRDatabase.database().referenceWithPath(".info/connected")
  _refHandle =  connectedRef.observeEventType(.Value, withBlock: { snapshot in
        
        if let connected = snapshot.value as? Bool where connected {
            
            let presenceRef = FIRDatabase.database().referenceWithPath("activeStatus").child(userId)
            presenceRef.updateChildValues(["isOnline" : "true"])
        }
        else {
            let presenceRef = FIRDatabase.database().referenceWithPath("activeStatus").child(userId).child("isOnline");
            presenceRef.onDisconnectSetValue("false")
            connectedRef.removeObserverWithHandle(_refHandle)
        }
    })
    //This method defines what to do, in case app is disconnected(i.e. crash/net disable..)
    //for now it sets current user's value to offline and online when user gets online
}


//MARK:- Alert View
//MARK:-
func displayAlert(message : String, presentVC : UIViewController)
{
    let alert : UIAlertController = UIAlertController(title: appName, message: message, preferredStyle:.Alert)
    let Ok : UIAlertAction = UIAlertAction(title: "Ok", style: . Default, handler: nil)
    alert.addAction(Ok)
    presentVC.presentViewController(alert, animated: true, completion: nil)
}

