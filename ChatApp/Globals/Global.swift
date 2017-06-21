
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
func fetchContacts(_ completion: (_ result: NSMutableArray) -> Void  )
{
    let contactStore = CNContactStore()
    let finalArrayForContacts = NSMutableArray()
    let contactsArray = NSMutableArray()
    let requestForContacts = CNContactFetchRequest(keysToFetch: [CNContactIdentifierKey as CNKeyDescriptor, CNContactFormatter.descriptorForRequiredKeys(for: CNContactFormatterStyle.fullName), CNContactPhoneNumbersKey as CNKeyDescriptor ,CNContactThumbnailImageDataKey as CNKeyDescriptor])
    do{
        try contactStore.enumerateContacts(with: requestForContacts) { (contactStore : CNContact, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            contactsArray.add(contactStore)
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
            var stringFromContact = formatter.string(from: contactNew)
            if stringFromContact == nil {
                stringFromContact = "Unnamed"
            }
            
            var imageData = Data()
            if contactNew.thumbnailImageData != nil{
                imageData = contactNew.thumbnailImageData!
            }else{
                //imageData = nil
            }
            var tempArray : NSArray = NSArray()
            if (contactNew.phoneNumbers).count > 0 {
                tempArray = (((contactNew.phoneNumbers as? NSArray)?.value(forKey: "value") as AnyObject).value(forKey: "digits")) as! NSArray
                for i in 0  ..< tempArray.count
                {
                    let newDict = NSMutableDictionary()
                    let phoneNumber : String = (tempArray.object(at: i)) as! String
                    
                    if phoneNumber.characters.count > 0 {
                        var test = false
                        
                        if phoneNumber.hasPrefix("+")
                        {
                            test = true
                        }
                        var resultString : String = (phoneNumber.components(separatedBy: CharacterSet.whitespacesAndNewlines) as NSArray).componentsJoined(by: "")
                        
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
                        finalArrayForContacts.add(newDict)
                    }
                }
            }else{
                // no number saved
            }
        }
    }else {
        print("No Contacts Found")
    }
    completion(finalArrayForContacts)
}


@available(iOS 9.0, *)
//MARK:- Retrieve all firebase user's data (firebase user's that exists from device contact)
//MARK:-
func gettingAllData(_ completionHandler : @escaping (Void) -> Void )
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
          let contactRef = ref.child("users").queryOrdered(byChild: "phoneNo").queryEqual(toValue: (arrContacts.object(at: i) as AnyObject).object(forKey: "contact_phone"))
          contactRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if(snapshot.exists())
            {
              //Storing snapshot in dictionary
              let dicttemp1 = snapshot.valueInExportFormat() as! NSMutableDictionary
               for strchildrenid in dicttemp1.allKeys {
                let dict: NSMutableDictionary = NSMutableDictionary()
                let dicttemp = dicttemp1.value(forKey: strchildrenid as! String) as! NSMutableDictionary
                dict.setObject(strchildrenid as! String, forKey: "userId" as NSCopying)
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("email"), forKey: "email" as NSCopying)
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("firstName"), forKey: "firstName" as NSCopying)
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("lastName"), forKey: "lastName" as NSCopying)
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("gender"), forKey: "gender" as NSCopying)
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("phoneNo"), forKey: "phoneNo" as NSCopying)
                dict.setObject((arrContacts.object(at: i) as AnyObject).value(forKey: "contact_name")!, forKey: "contactName" as NSCopying)
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("profilePic"), forKey: "profilePic" as NSCopying)
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("deviceToken"), forKey: "deviceToken" as NSCopying)
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("status"), forKey: "status" as NSCopying)
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("date"), forKey: "date" as NSCopying)
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("month"), forKey: "month" as NSCopying)
                dict.setObject(dicttemp.object_forKeyWithValidationForClass_String("year"), forKey: "year" as NSCopying)
                
                 //if mobile contact is firebase user
                 if(dict.object(forKey: "phoneNo") as! String != Foundation.UserDefaults.standard.object(forKey: mobileKey) as! String)
                 {
                    arrFilteredContacts.add(dict)
                 }
            }
         }
         else
         {
           let newDict : NSMutableDictionary = NSMutableDictionary()
           newDict.setObject("", forKey: "userId" as NSCopying)
           newDict.setObject("", forKey: "date" as NSCopying)
           newDict.setObject("", forKey: "deviceToken" as NSCopying)
           newDict.setObject("", forKey: "email" as NSCopying)
           newDict.setObject((arrContacts.object(at: i) as AnyObject).value(forKey: "contact_name")!, forKey: "contactName" as NSCopying)
           newDict.setObject((arrContacts.object(at: i) as AnyObject).value(forKey: "contact_phone")!, forKey: "phoneNo" as NSCopying)
           newDict.setObject("", forKey: "firstName" as NSCopying)
           newDict.setObject("", forKey: "lastName" as NSCopying)
           newDict.setObject("", forKey: "gender" as NSCopying)
           newDict.setObject("", forKey: "email" as NSCopying)
           newDict.setObject("", forKey: "profilePic" as NSCopying)
           newDict.setObject("", forKey: "month" as NSCopying)
           newDict.setObject("", forKey: "year" as NSCopying)
           newDict.setObject((arrContacts.object(at: i) as AnyObject).value(forKey: "contact_phone")!, forKey: "status" as NSCopying)
           arrFilteredInviteContacts.add(newDict)
        }
         if i == arrContacts.count-1{
           let arrTemp : NSMutableArray = NSMutableArray()
                        
            ///ARRAY FOR EXISTING CONTACTS
            arrFilteredContacts = NSMutableArray(array:  arrFilteredContacts.sortedArray(using: [NSSortDescriptor(key: "contactName", ascending: true)]) as! [[String:AnyObject]])
            arrTemp.addObjects(from: arrFilteredContacts as [AnyObject])
            UserDefaults.sharedInstance.SetArrayInUserDefault(arrFilteredContacts, key: phoneContacts)
           
            ///// ARRAY FOR INVITE CONTACTS /////
            arrFilteredInviteContacts = NSMutableArray(array:  arrFilteredInviteContacts.sortedArray(using: [NSSortDescriptor(key: "contactName", ascending: true)]) as! [[String:AnyObject]])
            arrTemp.addObjects(from: arrFilteredInviteContacts as [AnyObject])
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
func getCurrentUser(_ phoneNo : String, completionHandler : @escaping ((_ status : Bool)-> Void) )
{
    
 
    //Getting User name for recent chats
    let dbRef = FIRDatabase.database().reference()             //Database reference
    let userRef = dbRef.child("users")                                  //User reference
    let queryRef = userRef.queryOrdered(byChild: "phoneNo").queryEqual(toValue: phoneNo) //User matching phone no. reference
    
               //Fetching snaphot of current User
    
       queryRef.observeSingleEvent(of: .value, with: { (snapshot) in         //Observe single event will fetch data at once
        
        if(snapshot.exists()) //Checks snapsht exists or not
        {
             let dicttempUser = snapshot.valueInExportFormat() as! NSMutableDictionary
             for strchildrenid in dicttempUser.allKeys{
                
                var dicttemp = dicttempUser.value(forKey: strchildrenid as! String)
                
                Constants.loginFields.userId = strchildrenid as! String //Storing current user's id to constant so can be user throughout app
                UserDefaults.sharedInstance.RemoveKeyUserFefault(currentUserId) //Removing old reference from user default of crrent userid
                UserDefaults.sharedInstance.SetNSUserDefaultValues(currentUserId, value: Constants.loginFields.userId) //Storing current user's id to User Default
                
                //Storing current user's details to constant so can be user throughout app
                Constants.loginFields.name = ((dicttemp! as AnyObject).value(forKey: "firstName"))! as! String
                Constants.loginFields.lastName = ((dicttemp! as AnyObject).value(forKey: "lastName"))! as! String
                Constants.loginFields.phoneNo = ((dicttemp! as AnyObject).value(forKey: "phoneNo"))! as! String
                Constants.loginFields.email = ((dicttemp! as AnyObject).value(forKey: "email"))! as! String
                Constants.loginFields.imageUrl = ((dicttemp! as AnyObject).value(forKey: "profilePic"))! as! String
                Constants.loginFields.deviceToken = ((dicttemp! as AnyObject).value(forKey: "deviceToken"))! as! String
                Constants.loginFields.status = ((dicttemp! as AnyObject).value(forKey: "status"))! as! String
                Constants.loginFields.day = ((dicttemp! as AnyObject).value(forKey: "date"))! as! String
                Constants.loginFields.month = ((dicttemp! as AnyObject).value(forKey: "month"))! as! String
                Constants.loginFields.year = ((dicttemp! as AnyObject).value(forKey: "year"))! as! String
                Constants.loginFields.gender = ((dicttemp! as AnyObject).value(forKey: "gender"))! as! String
                
                 //Storing current user's detail to User Default
                UserDefaults.sharedInstance.SetNSUserDefaultValues(fName, value: Constants.loginFields.name)
                UserDefaults.sharedInstance.SetNSUserDefaultValues(lName, value: Constants.loginFields.lastName)
                UserDefaults.sharedInstance.SetNSUserDefaultValues(mobileKey, value: Constants.loginFields.phoneNo)
                UserDefaults.sharedInstance.SetNSUserDefaultValues(email, value: Constants.loginFields.email)
                UserDefaults.sharedInstance.SetNSUserDefaultValues(profilePic, value: Constants.loginFields.imageUrl)
                Foundation.UserDefaults.standard.set(Constants.loginFields.deviceToken, forKey: "device_key")
                UserDefaults.sharedInstance.SetNSUserDefaultValues(status, value: Constants.loginFields.status)
                UserDefaults.sharedInstance.SetNSUserDefaultValues(date, value: Constants.loginFields.day)
                UserDefaults.sharedInstance.SetNSUserDefaultValues(month, value: Constants.loginFields.month)
                UserDefaults.sharedInstance.SetNSUserDefaultValues(year, value: Constants.loginFields.year)
                UserDefaults.sharedInstance.SetNSUserDefaultValues(gender, value: Constants.loginFields.gender)
                
                
                dicttemp = nil
                userRef.child("phoneNo").removeAllObservers() //removing observer
                completionHandler(true)
            }
        }
    })
}


//MARK:- Update Status
//MARK:-
func changeStatus(_ data: [String: String], data1 : String)
{
    //Change staus of current user
    var mdata = data
    
    let statusRef = ref.child("statuses")
    let queryRef = statusRef.queryOrdered(byChild: "status").queryEqual(toValue: data1)
    
     queryRef.observe(.value, with: { (snapshot) in
        ShowLoader()
      if(UserDefaults.sharedInstance.GetNSUserDefaultValue(currentUserId) != "" && UserDefaults.sharedInstance.GetNSUserDefaultValue(currentUserId) != "userId" )
      {
            if(snapshot.exists())
            {
                //snapshot exists it will update in users detail
               Constants.loginFields.status = data1
               ref.child("users").child(Constants.loginFields.userId).updateChildValues(data)
               ref.child("statuses").queryOrdered(byChild: "status").queryEqual(toValue: data1).removeAllObservers()
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
func getOnlineStatus(_ userId : String, completionHandler : @escaping (_ str : String) -> Void) -> Void
{
    var str : String = String()
    _refHandle = ref.child("activeStatus").child(userId).observe(.value, with: { (snapshot) in

        if(snapshot.exists())
        {
            str = ((snapshot.value as AnyObject).value(forKey: "isOnline"))! as! String
            completionHandler(str)
        }
        else
        {
            print("nothing")
        }
    })
}


//MARK:- Get Image User
//MARK:-
func getProfileImage(_ userId : String, completionHandler : @escaping (_ str : String) -> Void) -> String
{
    var str : String = String()
    ref.child("users").child(userId).observe(.value, with: { (snapshot) in
        
        if(snapshot.exists())
        {
            str = ((snapshot.value as AnyObject).value(forKey: "profilePic"))! as! String
            completionHandler(str)
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
func onDisconnect(_ userId : String)  {
    
    let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
  _refHandle =  connectedRef.observe(.value, with: { snapshot in
        
        if let connected = snapshot.value as? Bool, connected {
            
            let presenceRef = FIRDatabase.database().reference(withPath: "activeStatus").child(userId)
            presenceRef.updateChildValues(["isOnline" : "true"])
        }
        else {
            let presenceRef = FIRDatabase.database().reference(withPath: "activeStatus").child(userId).child("isOnline");
            presenceRef.onDisconnectSetValue("false")
            connectedRef.removeObserver(withHandle: _refHandle)
        }
    })
    //This method defines what to do, in case app is disconnected(i.e. crash/net disable..)
    //for now it sets current user's value to offline and online when user gets online
}


//MARK:- Alert View
//MARK:-
func displayAlert(_ message : String, presentVC : UIViewController)
{
    let alert : UIAlertController = UIAlertController(title: appName, message: message, preferredStyle:.alert)
    let Ok : UIAlertAction = UIAlertAction(title: "Ok", style: . default, handler: nil)
    alert.addAction(Ok)
    presentVC.present(alert, animated: true, completion: nil)
}

