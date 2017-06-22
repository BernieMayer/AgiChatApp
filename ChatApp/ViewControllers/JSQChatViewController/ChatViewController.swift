//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Urvish Patel on 08/11/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import UIKit
import Firebase
import Contacts
import ContactsUI
import Firebase
import FirebaseAuth
import FirebaseDatabase

@available(iOS 9.0, *)
class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    
    var senderImageUrl: String!
    var batchMessages = true
    //Setting bubbles color
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.white)
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor(red: 29/255, green: 103/255, blue: 241/255, alpha: 1.0))
    //var navigationColor:UIColor = UIColor(customColor: 29, green: 103, blue: 241, alpha: 1.0);
    var messages = [Message]()
    
    //VARIABLE FOR FIREBASE
    fileprivate var _refHandle: FIRDatabaseHandle! //database handler
    var user : FIRAuth!
    
    var userId : String = String() //Stores others user ID whom to chat with
    //For current user
    var getID : String = String() //Stores logged in users Id
    var deviceToken : String = String()
    
    //User Variables set
    var userName : String = String()
    var status :  String = String()
    var proPic : UIImageView = UIImageView()
    
    /*Dot Menu*/
    var menuItems: [AnyObject] = ["View Contact" as AnyObject, "Media" as AnyObject, "Search" as AnyObject,"Wapllpaper" as AnyObject,"More" as AnyObject]
    @IBOutlet var dotMenuView: UIView!
    @IBOutlet var tblDotMenu: UITableView!
    
    /*Navigation Bar*/
    let imagePicker = UIImagePickerController()
    
    //topicChatVariables
    var mobile : String = String()
    var newTopicChatID : String = String()
    var newTopicChatID2 : String = String()
    
    //RECENT CHAT VARIABLES
    var childKey : String = String()                //Stores recently generated key of current user in Recent Chat
    var otherChildKey : String = String()       //Stores recently generated key of other user in Recent Chat
    var getCurrentObject : String = String() //Stores Current User's recent data
    var getOtherObject : String = String()    //Stores Other User's recent data
    
    //GROUP CHAT VARIABLES
    var groupName : String = String()
    var groupUsers : String = String()
    var arrGroupUsers : NSMutableArray = NSMutableArray()
    var arrFilteredContacts : NSMutableArray!
    var arrFilteredUsers : NSMutableArray = NSMutableArray()
    var groupId : String = String()
    var groupIcon : UIImageView  = UIImageView()
    var newGroupId : String = String()
    var isGroupChat : Bool = Bool()
    
    var isExistingGroup : Bool = Bool()   // Determins group exists or not
    var data : Data = Data()          // Stores image in data format
    var isFirstTimeLoad : Bool = Bool() // Determines whether data loaded first time or not
    
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }
    
    func setup() {
        
        if(isGroupChat == true)
        {
            // when redirect from group chat
            //below variables sets current user name to manage the incoming and outgoing bubble
            self.senderId = Constants.loginFields.name
            self.senderDisplayName = Constants.loginFields.name
        }
        else
        {
            // when redirect from chat
            //below variables sets current user name to manage the incoming and outgoing bubble
            self.senderId = Constants.loginFields.userId
            self.senderDisplayName = Constants.loginFields.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        arrFilteredContacts = NSMutableArray()
        self.inputToolbar.contentView.textView.autocorrectionType = .no
        self.setup()
        arrFilteredContacts = UserDefaults.sharedInstance.GetArrayFromUserDefault(allContacts)
        if(isExistingGroup == true)
        {
            //Sets Display name
            senderDisplayName = Constants.loginFields.name
            isFirstTimeLoad = true
        }
        else
        {
            //Check whether topic exists
            self.checkTopicChatExist({ (isTrue) in
                self.senderId = Constants.loginFields.userId
                self.configureDatabase()
            })
        }
    }
    
    //MARK:- View will Appear
    //MARK-
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
        collectionView.collectionViewLayout.springinessEnabled = false
        lblStatus.text = ""
        
        if(isExistingGroup == true) //Navigates from Group Chat
        {
            self.lblName.text = self.groupName
            self.imgGroupIcon.image = self.groupIcon.image
            
            getGroupsUsers(true, Id: groupId, completionHandler: { //Fetches Group Users
                
                var string  = "You"
                for i in 0..<self.arrGroupUsers.count
                {
                    if((self.arrGroupUsers.object(at: i) as AnyObject).value(forKey: "userId") as! String != Constants.loginFields.userId)
                    {
                        string = string + " ," + ((self.arrGroupUsers.object(at: i) as AnyObject).value(forKey: "contactName") as! String)
                        
                        self.lblStatus.text = string //Sets Group Users
                    }
                }
                
                //for checking if database is configured once or not
                if self.isFirstTimeLoad
                {
                    self.isFirstTimeLoad = false
                    self.configureDatabase() //Configures Database
                }
                
            })
            
        }
        else
        {
            lblName.text = self.userName
            imgGroupIcon.image = self.proPic.image
            isGroupChat = false
            
            //getting online status
            getOnlineStatus(userId, completionHandler: { (str) in
                
                if(str == "true")
                {
                    self.lblStatus.text = "online"
                }
                else
                {
                    self.lblStatus.text = ""
                }
            })
        }
    }
    
    //MARK:- View will disappear
    //MARK:-
    override func viewWillDisappear(_ animated: Bool) {
        
        if(isExistingGroup == true)
        {
            if AIReachability.sharedManager.isAavailable()
            {
                ref.child("groupUsers").removeAllObservers()
                
            }
        }
        else
        {
            if AIReachability.sharedManager.isAavailable()
            {
                ref.child("chat").removeAllObservers()
            }
        }
    }
    
    //MARK:- Confiugring Data Base
    //MARK:-
    func configureDatabase()
    {
        //will connect to firebase database
        
        if(isGroupChat == true)
        {
            //when redirects from group chat
            if(groupId == "")
            {
                //when groupId is empty nothing will happen
            }
            else
            {
                //when groupId is not empty will load chats if any exists
                var previousMessageDay:Int = 0;
                let groupChatRef = ref.child("groupChat").child(groupId).queryLimited(toLast: 10)
                _refHandle =  groupChatRef.observe(.childAdded, with:
                    { (snapshot) in
                        if(snapshot.exists())
                        {
                            var uName : String = String()
                            
                            //found user is a flag maintaining if userId exists in arrGroupusers
                            var foundUser : Bool = false
                            
                            for i in 0..<self.arrGroupUsers.count
                            {
                                //if the snapshot userId is equal to userId of snapshot
                                if((self.arrGroupUsers.object(at: i) as AnyObject).value(forKey: "userId") as! String == (snapshot.value! as AnyObject).value(forKey: "userId") as! String)
                                {
                                    uName = (self.arrGroupUsers.object(at: i) as AnyObject).value(forKey: "contactName") as! String
                                    foundUser = true
                                    break
                                }
                            }
                            
                            //if user not found then it check for the userId in arrFiltered contacts (arrFilteredcontacts contains all details of the number existing in device (chatApp users and non-chatApp users))
                            if(!foundUser)
                            {
                                self.arrFilteredContacts = UserDefaults.sharedInstance.GetArrayFromUserDefault(allContacts)
                                let regextest:NSPredicate = NSPredicate(format: "( userId CONTAINS[C] %@ )", argumentArray: [((snapshot.value as AnyObject).value(forKey: "userId"))!])
                                let arrTemp:NSMutableArray = self.arrFilteredContacts.mutableCopy() as! NSMutableArray
                                arrTemp.filter(using: regextest)
                                
                                if(arrTemp.firstObject != nil)
                                {
                                    uName = (arrTemp.firstObject! as AnyObject).value(forKey: "contactName") as! String
                                }
                                else
                                {
                                    uName = (snapshot.value! as AnyObject).value(forKey: "userName")! as! String
                                }
                            }
                            
                            var senderName = uName //sets the sender name
                            var sender = uName
                            let text = (snapshot.value! as AnyObject).value(forKey: "message") as! String //sets the text/messages
                            
                            //matches if the snapshot userId is equal to current userId
                            if((snapshot.value as AnyObject).value(forKey: "userId") as! String == Constants.loginFields.userId)
                            {
                                //when equal to user Id sender name sets to the current username
                                senderName = Constants.loginFields.name
                                sender = Constants.loginFields.name
                            }
                            else
                            {
                                //when not equal to user Id sender name sets to the name stored in uname
                                senderName = uName
                                sender = uName
                            }
                            
                            let strDate = (snapshot.value! as AnyObject).value(forKey: "timeStamp") as! String
                            
                            let date:Date = self.getDate(fromString: strDate, withDateFormat: "MMM dd, yyyy hh:mm:ss a")
                            var textBody:String = String()
                            
                            let dateFormat:DateFormatter = DateFormatter()
                            dateFormat.dateFormat = "MMM dd, yyyy";
                            let convertedSectionTitle:String = dateFormat.string(from: date)
                            
                            if(Constants.loginFields.name == senderName)
                            {
                                senderName = ""
                                textBody  = String.init(format: "\(senderName)%@", text)
                            }
                            else
                            {
                                textBody = String.init(format: "\(senderName):\n%@", text)
                            }
                            
                            let message = Message(text: textBody, sender: sender,imageUrl: nil,withSenderDisplayName:self.senderDisplayName ,withMedia:false   ,withMessageHase:0,withDate: date)
                            let currentMessageDay:Int = self.getDayFromDate(withDate: message.date_)
                            
                            if currentMessageDay != previousMessageDay
                            {
                                message.sectionName_ = convertedSectionTitle;
                            }
                            previousMessageDay  = currentMessageDay
                            
                            self.messages.append(message)
                            self.finishReceivingMessage(animated: false)
                            self.scrollToBottom(animated: false)
                        }
                })
            }
        }
        else
        {
            if(newTopicChatID == "")
            {
                
            }
            else
            {
                // Listen for new messages in the Firebase database
                //when any new child is added
                var previousMessageDay:Int = 0;
                let refChat = ref.child("chat").child(newTopicChatID)
                _refHandle = refChat.observe(.childAdded, with: { (snapshot) in
                    
                    if(snapshot.exists())
                    {
                        let text = (snapshot.value! as AnyObject).value(forKey: "message") as! String
                        let sender = (snapshot.value! as AnyObject).value(forKey: "userId") as! String
                        let strDate = (snapshot.value! as AnyObject).value(forKey: "timeStamp") as! String
                        let date:Date = self.getDate(fromString: strDate, withDateFormat: "MMM dd, yyyy hh:mm:ss a")
                        
                        let dateFormat:DateFormatter = DateFormatter()
                        dateFormat.dateFormat = "MMM dd, yyyy";
                        let convertedSectionTitle:String = dateFormat.string(from: date)
                        
                        let message = Message(text: text, sender: sender,imageUrl: nil,withSenderDisplayName:self.senderDisplayName ,withMedia:false   ,withMessageHase:0,withDate: date)
                        let currentMessageDay:Int =
                            self.getDayFromDate(withDate: message.date_)
                        if currentMessageDay != previousMessageDay
                        {
                            message.sectionName_ = convertedSectionTitle;
                        }
                        previousMessageDay  = currentMessageDay
                        self.messages.append(message)
                        self.finishReceivingMessage(animated: false)
                        self.scrollToBottom(animated: false)
                    }
                })
            }
        }
    }
    
    
    //MARK:- On Back Button Click
    //MARK:-
    override func onBackButtonClick(){
        
        let tabVC : TabViewController = storyboard?.instantiateViewController(withIdentifier: "TabViewController") as! TabViewController
        tabVC.btnChat = true
        tabVC.btnContact = false
        Foundation.UserDefaults.standard.set(false, forKey: btnGroup)
        Foundation.UserDefaults.standard.synchronize()
        self.navigationController?.popToViewController(tabVC, animated: true)
    }
    
    
    //MARK:- On Dot Menu Click
    //MARK:-
    override func onDotMenuClick() {
        openMenu()
    }
    
    
    //MARK:- View Profile
    //MARK:-
    override func onButtonProfileClick() {
        
        if(isExistingGroup == true)
        {
            let groupProfileVC : GroupProfileViewController = storyboard?.instantiateViewController(withIdentifier: "GroupProfileViewController") as! GroupProfileViewController
            groupProfileVC.lblGroupName.text = groupName
            groupProfileVC.groupId = groupId
            if(imgGroupIcon.image == UIImage(named: "grp_icon"))
            {
                groupProfileVC.imgGroupIcon!.image = UIImage(named: "")
            }
            else
            {
                groupProfileVC.imgGroupIcon!.image = groupIcon.image
            }
            groupProfileVC.arrGroupUsers = arrGroupUsers
            self.navigationController?.pushViewController(groupProfileVC, animated: true)
        }
        else
        {
            let displayProfileVC : DisplayProfileViewController = storyboard?.instantiateViewController(withIdentifier: "DisplayProfileViewController") as! DisplayProfileViewController
            
            displayProfileVC.userId = userId
            displayProfileVC.userName = self.userName
            displayProfileVC.isNavigateFrom = "Chat"
            
            self.navigationController?.pushViewController(displayProfileVC, animated: true)
        }
        
    }
    
    
/*
 
 
 
 
 public static void sendNotificationToUser(String user, final String message) {
 Firebase ref = new Firebase(FIREBASE_URL);
 final Firebase notifications = ref.child("notificationRequests");
 
 Map notification = new HashMap<>();
 notification.put("username", user);
 notification.put("message", message);
 
 notifications.push().setValue(notification);
 }
 
 
 */
    //Note: This code is based on the above snipped and has been updated for iOS
    //since it was made for android
    func sendNotifactionToUser( user:String, message:String)
    {
        
        
        let ref:FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        
        let notifacations = ref.child("notificationRequests")
        
        
     
        let notifacation: NSDictionary = [
            "username" : user,
            "message"  : message,
        ]
        
    
        
        notifacations.childByAutoId().setValue(notifacation)
        //notifacations.setValue(notifacation) //might need to be changed
        
    }
 
 
    //MARK:- On Attachment button Click
    //MARK:-
    override func onAttachmentButtonClick() {
        
        displayAlert("This feature will be available in next version", presentVC: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        NSLog("WARNING FOR MEMORY")
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
        let data = self.messages[indexPath.row]
        
        
        return data
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        
        self.messages.remove(at: indexPath.row)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        let data = messages[indexPath.row]
        if data.senderId() == self.senderId
        {
            return self.outgoingBubble
        }
        else
        {
            return self.incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        if(isExistingGroup == true)
        {
            let date = DateFormatter()
            date.dateFormat = "MMM d, yyyy hh:mm:ss a"
            
            let formatString: NSString = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)! as NSString
            let hasAMPM = formatString.contains("a")
            
            
            if(hasAMPM == true)
            {
                date.dateFormat = "MMM d, yyyy hh:mm:ss a"
            }
            else
            {
                date.dateFormat = "MMM d, yyyy HH:mm:ss a"
            }

            
            let newDate = date.string(from: Date())
//            newDate = newDate.stringByReplacingOccurrencesOfString("AM", withString: "am")
//            newDate = newDate.stringByReplacingOccurrencesOfString("PM", withString: "pm")
            
            let dict : NSMutableDictionary = NSMutableDictionary()
            let arrGrpData : NSMutableArray = NSMutableArray()
            dict.setObject(text, forKey:  "message" as NSCopying)
            dict.setObject("false", forKey: "stared" as NSCopying)
            dict.setObject(newDate, forKey: "timeStamp" as NSCopying)
            dict.setObject(Constants.loginFields.userId, forKey: "userId" as NSCopying)
            dict.setObject(Constants.loginFields.name, forKey: "userName" as NSCopying)
            arrGrpData.add(dict)
            if(text.length>0)
            {
                let data = [Constants.GroupFields.lastMessage: text as String]
                let str = text
                sendGroupChatMessage(data, arrGrpData: arrGrpData,text: str!)
                finishSendingMessage(animated: false)
            }
        }
        else
        {
            sendNotifactionToUser(user: userId, message: "New Message!!")
            let data = [Constants.MessageFields.text: text as String]
            self.sendMessage(data,text: text)
            self.finishSendingMessage(animated: false)
            
            //**** FOR RECENT CHAT STORING ****
            if(text.length>0)
            {
                let data1 = [Constants.recentMessageField.lastMessage: text as String]
                self.sendLastMessage(data1)
            }
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!)
    {
        
    }
    
    //MARK:- Updating existing group Chatting
    //MARK:-
    func sendGroupChatMessage(_ data: [String: String], arrGrpData : NSMutableArray, text : String)
    {
        var mdata = data
        let date = DateFormatter()
        date.dateFormat = "MMM d, yyyy hh:mm:ss a"
        
        let formatString: NSString = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)! as NSString
        let hasAMPM = formatString.contains("a")
        
        if(hasAMPM == true)
        {
            date.dateFormat = "MMM d, yyyy hh:mm:ss a"
        }
        else
        {
            date.dateFormat = "MMM d, yyyy HH:mm:ss a"
        }
        
        let newDate = date.string(from: Date())
        mdata[Constants.GroupFields.adminId] = self.getID
        mdata[Constants.GroupFields.adminName] = Constants.loginFields.name
        mdata[Constants.GroupFields.timeStamp] = String(newDate)
        
        if(groupId == "")
        {
            groupId = newGroupId
        }
        
        //Adding Chat to current group
        
        for i in 0..<arrGrpData.count
        {
            ref.child("groupChat").child(self.groupId).childByAutoId().setValue(arrGrpData.object(at: i) as! [AnyHashable: Any])
        }
        ref.child("group").child(groupId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.exists()
            {
                for i in 0..<arrGrpData.count
                {
                    ref.child("group").child(self.groupId).updateChildValues(mdata)
                }
            }
            else
            {
                
            }
            let dict : NSMutableDictionary = NSMutableDictionary()
            dict.setObject(self.groupName, forKey: "title" as NSCopying)
            dict.setObject(text, forKey: "body" as NSCopying)
            dict.setObject(self.groupId, forKey: "topic_key" as NSCopying)
            
            HttpManager.sharedInstance.postGroup("", loaderShow: false, dict: dict, SuccessCompletion: { (result) in
                
                }, FailureCompletion: { (result) in
                    
            })
            
        })
    }
    
    //MARK:- will send message data
    //MARK:-
    func sendMessage(_ data: [String: String], text : String) {
        
        var mdata = data
        let date = DateFormatter()
        date.dateFormat = "MMM d, yyyy hh:mm:ss aa"
        
        let formatString: NSString = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)! as NSString
        let hasAMPM = formatString.contains("a")

        
        if(hasAMPM == true)
        {
            date.dateFormat = "MMM d, yyyy hh:mm:ss a"
        }
        else
        {
            date.dateFormat = "MMM d, yyyy HH:mm:ss a"
        }

        let newDate = date.string(from: Date())
      //  newDate = newDate.stringByReplacingOccurrencesOfString("AM", withString: "am")
      //  newDate = newDate.stringByReplacingOccurrencesOfString("PM", withString: "pm")
        if(AppState.sharedInstance.displayName?.length == 0)
        {
            displayAlert("No UserName Found", presentVC: self)
            
        }
        mdata[Constants.MessageFields.userId] = getID
        mdata[Constants.MessageFields.timeStamp] = String(newDate)
        if let photoUrl = AppState.sharedInstance.photoUrl {
            mdata[Constants.MessageFields.photoUrl] = photoUrl.absoluteString
        }
        
        //create new topic chat
        if(getID.length == 0 || userId.length == 0)
        {
            newTopicChatID = getID + userId
            ref.child("chat").child(newTopicChatID).childByAutoId().setValue(mdata)
        }
        else
        {
            sendNotifactionToUser  (user: "test", message: "New Message!!")
            ref.child("chat").child(newTopicChatID).childByAutoId().setValue(mdata)
            let dict : NSMutableDictionary = NSMutableDictionary()
            dict.setObject(userName, forKey: "title" as NSCopying)
            dict.setObject(text, forKey: "body" as NSCopying)
            dict.setObject(deviceToken, forKey: "device_key" as NSCopying)
            
            
            //Let the user know they have a new message
            
            
            HttpManager.sharedInstance.postResponse("", loaderShow: false, dict: dict, SuccessCompletion: { (result) in
                NSLog("true")
                
                }, FailureCompletion: { (result) in
                    
                    NSLog("False")
            })
        }
        
    }
    
    //MARK:- SEND LAST MESSAGE
    //MARK:-
    func sendLastMessage(_ data: [String: String]) {
        var mdata = data
        var arrkeys : NSMutableArray!
        let date = DateFormatter()
        date.dateFormat = "MMM d, yyyy hh:mm:ss a"
        
        let formatString: NSString = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)! as NSString
        let hasAMPM = formatString.contains("a")
        
        if(hasAMPM == true)
        {
            date.dateFormat = "MMM d, yyyy hh:mm:ss a"
        }
        else
        {
            date.dateFormat = "MMM d, yyyy HH:mm:ss a"
        }
        
        let refRecentChat = ref.child("recentChat").child(getID)
        
        refRecentChat.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.exists()
            {
                let dicttemp1 = snapshot.valueInExportFormat() as! NSMutableDictionary
                arrkeys = NSMutableArray(array: dicttemp1.allKeys)
                for i in 0..<arrkeys.count
                {
                    let object =  arrkeys.filter({ (obj) -> Bool in
                        let dict = snapshot.childSnapshot(forPath: obj as! String).valueInExportFormat() as! NSDictionary
                        return dict.object(forKey: "recentUserId") as! String == self.userId
                    })
                    if(object.first != nil)
                    {
                        self.getCurrentObject = object.first as! String
                    }
                }
                if(self.getCurrentObject != "")
                {
                    self.childKey = self.getCurrentObject
                    mdata[Constants.recentMessageField.recentUserId] = self.userId
                    mdata[Constants.MessageFields.timeStamp] = String(date.string(from: Date()))
                    ref.child("recentChat").child(self.getID).child(self.childKey).updateChildValues(mdata)
                    
                }
                else
                {
                    mdata[Constants.recentMessageField.recentUserId] = self.userId
                    mdata[Constants.MessageFields.timeStamp] = String(date.string(from: Date()))
                    let postRecentRef = ref.child("recentChat").child(self.getID)
                    let postRecentRef1 = postRecentRef.childByAutoId()
                    postRecentRef1.setValue(mdata)
                    self.childKey = postRecentRef1.key
                }
            }
            else
            {
                mdata[Constants.recentMessageField.recentUserId] = self.userId
                mdata[Constants.MessageFields.timeStamp] = String(date.string(from: Date()))
                let postRecentRef = ref.child("recentChat").child(self.getID)
                let postRecentRef1 = postRecentRef.childByAutoId()
                postRecentRef1.setValue(mdata)
                self.childKey = postRecentRef1.key
            }
        })
        
        let refOtherChat = ref.child("recentChat").child(userId)
        
        refOtherChat.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if(snapshot.exists())
            {
                let dicttemp1 = snapshot.valueInExportFormat() as! NSMutableDictionary
                arrkeys = NSMutableArray(array: dicttemp1.allKeys)
                for i in 0..<arrkeys.count
                {
                    let object =  arrkeys.filter({ (obj) -> Bool in
                        let dict = snapshot.childSnapshot(forPath: obj as! String).valueInExportFormat() as! NSDictionary
                        return dict.object(forKey: "recentUserId") as! String == self.getID
                    })
                    if(object.first != nil)
                    {
                        self.getOtherObject = object.first as! String
                    }
                }
                
                if(self.getOtherObject != "")
                {
                    self.otherChildKey = self.getOtherObject
                    
                    mdata[Constants.recentMessageField.recentUserId] = self.getID
                    mdata[Constants.MessageFields.timeStamp] = String(date.string(from: Date()))
                    ref.child("recentChat").child(self.userId).child(self.otherChildKey).updateChildValues(mdata)
                    
                }
                else
                {
                    mdata[Constants.recentMessageField.recentUserId] = self.getID
                    mdata[Constants.MessageFields.timeStamp] = String(date.string(from: Date()))
                    let postRecentRef = ref.child("recentChat").child(self.userId)
                    let postRecentRef1 = postRecentRef.childByAutoId()
                    postRecentRef1.setValue(mdata)
                    self.otherChildKey = postRecentRef1.key
                    
                }
            }
            else
            {
                mdata[Constants.recentMessageField.recentUserId] = self.getID
                mdata[Constants.MessageFields.timeStamp] = String(date.string(from: Date()))
                let postRecentRef = ref.child("recentChat").child(self.userId)
                let postRecentRef1 = postRecentRef.childByAutoId()
                postRecentRef1.setValue(mdata)
                self.otherChildKey = postRecentRef1.key
            }
        })
    }
    
    //MARK:- Check whether chat topic exists or not
    //MARK:-
    
    func checkTopicChatExist(_ handler:@escaping ((Bool)->Void))
    {
        let refChatExists = ref.child("chat")
        refChatExists.observeSingleEvent(of: .value, with: { (snapshot) in
            
            
            self.newTopicChatID = "\(self.getID)to" + self.userId
            self.newTopicChatID2 = "\(self.userId)to" + self.getID
            
            if(snapshot.hasChild(self.newTopicChatID))
            {
                self.newTopicChatID = "\(self.getID)to" + self.userId
                handler(true)
                return
            }
            else if(snapshot.hasChild(self.newTopicChatID2))
            {
                self.newTopicChatID = self.newTopicChatID2
                handler(true)
                return
            }
            else
            {
                if(self.getID.length > 0 && self.userId.length>0)
                {
                    self.newTopicChatID = "\(self.getID)to" + self.userId
                    let date = DateFormatter()
                    date.dateFormat = "MMM d, yyyy hh:mm:ss a"
                    var newDate = date.string(from: Date())
                    newDate = newDate.replacingOccurrences(of: "AM", with: "am")
                    newDate = newDate.replacingOccurrences(of: "PM", with: "pm")
                    handler(true)
                    return
                }
            }
        })
    }
    
    
    //MARK:- Get Group Users
    //MARK:-
    func getGroupUsers(_ groupId : String, handler:@escaping ((Bool)->Void))
    {
        self.arrFilteredContacts.removeAllObjects()
        self.arrFilteredContacts = UserDefaults.sharedInstance.GetArrayFromUserDefault(allContacts)
        arrGroupUsers.removeAllObjects()
        let getGroupRef = ref.child("groupUsers").queryOrdered(byChild: "groupId").queryEqual(toValue: "\(groupId)")
        getGroupRef.observe(.value, with: { (snapshot) in
            if(snapshot.exists())
            {
                let dicttempUser = snapshot.valueInExportFormat() as! NSMutableDictionary
                for strchildrenid in dicttempUser.allKeys{
                    
                    let dict: NSMutableDictionary = NSMutableDictionary()
                    let dicttemp = dicttempUser.value(forKey: strchildrenid as! String)
                    dict.setObject(((dicttemp as AnyObject).value(forKey: "groupId"))!, forKey: "groupId" as NSCopying)
                    dict.setObject(((dicttemp as AnyObject).value(forKey: "profilePic"))!, forKey: "profilePic" as NSCopying)
                    dict.setObject(((dicttemp as AnyObject).value(forKey: "groupId"))!, forKey: "groupId" as NSCopying)
                    dict.setObject(((dicttemp as AnyObject).value(forKey: "userId"))!, forKey: "userId" as NSCopying)
                    dict.setObject(((dicttemp as AnyObject).value(forKey: "userName"))!, forKey: "contactName" as NSCopying)
                    dict.setObject(((dicttemp as AnyObject).value(forKey: "userType"))!, forKey: "userType" as NSCopying)
                    
                    let regextest:NSPredicate = NSPredicate(format: "( userId CONTAINS[C] %@ )", argumentArray: [dict["userId"]!])
                    let arrTemp:NSMutableArray = self.arrFilteredContacts.mutableCopy() as! NSMutableArray
                    arrTemp.filter(using: regextest)
                    if(arrTemp.firstObject != nil)
                    {
                        let tempDict : NSMutableDictionary = NSMutableDictionary()
                        tempDict.setObject(((arrTemp.firstObject! as AnyObject).value(forKey: "phoneNo"))!, forKey:"contactNumber" as NSCopying)
                        tempDict.setObject(((arrTemp.firstObject! as AnyObject).value(forKey: "contactName"))!, forKey:"contactName" as NSCopying)
                        tempDict.setObject(dict.object(forKey: "userId")!, forKey:"userId" as NSCopying)
                        tempDict.setObject(dict.object(forKey: "groupId")!, forKey:"groupId" as NSCopying)
                        tempDict.setObject(dict.object(forKey: "contactName")!, forKey:"userName" as NSCopying)
                        tempDict.setObject(dict.object(forKey: "profilePic")!, forKey:"profilePic" as NSCopying)
                        tempDict.setObject(dict.object(forKey: "userType")!, forKey:"userType" as NSCopying)
                        self.arrGroupUsers.add(tempDict)
                        
                    }
                    else
                    {
                        let strKey = dict.value(forKey: "userId") as!String
                        let userRef = ref.child("users").child(strKey)
                        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                            if(snapshot.exists())
                            {
                                let tempDict : NSMutableDictionary = NSMutableDictionary()
                                tempDict.setObject((snapshot.value! as AnyObject).value(forKey: "phoneNo")!, forKey:"contactName" as NSCopying)
                                tempDict.setObject(strKey, forKey:"userId" as NSCopying)
                                tempDict.setObject((snapshot.value! as AnyObject).value(forKey: "profilePic")!, forKey:"profilePic" as NSCopying)
                                tempDict.setObject((snapshot.value! as AnyObject).value(forKey: "status")!, forKey:"status" as NSCopying)
                                tempDict.setObject(dict.object(forKey: "groupId")!, forKey:"groupId" as NSCopying)
                                tempDict.setObject(dict.object(forKey: "contactName")!, forKey:"userName" as NSCopying)
                                tempDict.setObject(dict.object(forKey: "profilePic")!, forKey:"profilePic" as NSCopying)
                                tempDict.setObject(dict.object(forKey: "userType")!, forKey:"userType" as NSCopying)
                                self.arrGroupUsers.add(tempDict)
                                
                            }
                        })
                    }
                }
            }
            getGroupRef.removeAllObservers()
            handler(true)
        })
    }
    
    
    //MARK:- Open Dot Menu
    //MARK:-
    func openMenu()  {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // 2
        let viewCon = UIAlertAction(title:"View Contact" , style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if self.isExistingGroup == true
            {
                let groupProfileVC : GroupProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "GroupProfileViewController") as! GroupProfileViewController
                groupProfileVC.lblGroupName.text = self.groupName
                groupProfileVC.groupId = self.groupId
                if(self.imgGroupIcon.image == UIImage(named: "grp_icon"))
                {
                    groupProfileVC.imgGroupIcon!.image = UIImage(named: "")
                }
                else
                {
                    groupProfileVC.imgGroupIcon!.image = self.groupIcon.image
                }
                groupProfileVC.arrGroupUsers = self.arrGroupUsers
                self.navigationController?.pushViewController(groupProfileVC, animated: true)
            }
            else
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let displayProfileVC = storyboard.instantiateViewController(withIdentifier: "DisplayProfileViewController") as! DisplayProfileViewController
                displayProfileVC.isNavigateFrom = "Chat"
                displayProfileVC.userId = self.userId
                
                self.navigationController?.pushViewController(displayProfileVC, animated: true)
            }
        })
        let media = UIAlertAction(title: "Media", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            displayAlert("This feature will be available in next version", presentVC: self)
            
        })
        let search = UIAlertAction(title: "Search", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in

            displayAlert("This feature will be available in next version", presentVC: self)
            
        })
        let wallpaper = UIAlertAction(title: "Wallpaper", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in

            displayAlert("This feature will be available in next version", presentVC: self)
            
        })
        let more = UIAlertAction(title: "More", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in

            displayAlert("This feature will be available in next version", presentVC: self)
            
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        
        // 4
        optionMenu.addAction(viewCon)
        optionMenu.addAction(media)
        optionMenu.addAction(search)
        optionMenu.addAction(wallpaper)
        optionMenu.addAction(more)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    ///Mark:- Date Format
    func getDayFromDate(withDate date:Date) -> Int
    {
        let dateFormat:DateFormatter = DateFormatter()
        dateFormat.dateFormat = "dd";
        let stringDate:String = dateFormat.string(from: date);
        let day:Int = Int(stringDate)!
        return day;
    }
    
    //MARK:- Convert Date / Formatting Date
   //MARK:-
    func getDate(fromString strDate:String, withDateFormat format:String) -> Date
    {
        let dateFormat:DateFormatter = DateFormatter()
        
        dateFormat.dateFormat = format;
        
        if(dateFormat.date(from: strDate) == nil){
            dateFormat.dateFormat = "MMM d, yyyy HH:mm:ss a"
            return dateFormat.date(from: strDate)!
        }else{
            dateFormat.dateFormat = format;
            return dateFormat.date(from: strDate)!
        }
}
    
    //MARK:- Get Group Users
    //MARK:-
    func getGroupsUsers(_ flag : Bool, Id : String,completionHandler :@escaping ()-> Void)
    {
        arrGroupUsers.removeAllObjects()
        ShowLoader()
        
        let getGroupRef = ref.child("groupUsers")
        getGroupRef.queryOrdered(byChild: "groupId").queryEqual(toValue: "\(Id)").observe(.value, with: { (snapshot) in
            
            if(snapshot.exists())
            {
                let dicttempUser = snapshot.valueInExportFormat() as! NSMutableDictionary
                for strchildrenid in dicttempUser.allKeys{
                    let dict: NSMutableDictionary = NSMutableDictionary()
                    let dicttemp = dicttempUser.value(forKey: strchildrenid as! String)
                    dict.setObject(((dicttemp as AnyObject).value(forKey: "groupId"))!, forKey: "groupId" as NSCopying)
                    dict.setObject(((dicttemp as AnyObject).value(forKey: "profilePic"))!, forKey: "profilePic" as NSCopying)
                    dict.setObject(((dicttemp as AnyObject).value(forKey: "groupId"))!, forKey: "groupId" as NSCopying)
                    dict.setObject(((dicttemp as AnyObject).value(forKey: "userId"))!, forKey: "userId" as NSCopying)
                    dict.setObject(((dicttemp as AnyObject).value(forKey: "userName"))!, forKey: "userName" as NSCopying)
                    dict.setObject(((dicttemp as AnyObject).value(forKey: "userType"))!, forKey: "userType" as NSCopying)
                    
                     //Filtering whether user exists in Contacts
                    let regextest:NSPredicate = NSPredicate(format: "( userId CONTAINS[C] %@ )", argumentArray: [dict["userId"]!])
                    let arrTemp:NSMutableArray = self.arrFilteredContacts.mutableCopy() as! NSMutableArray
                    arrTemp.filter(using: regextest)
                    
                    if(arrTemp.firstObject != nil)
                    {
                        let tempDict : NSMutableDictionary = NSMutableDictionary()
                        tempDict.setObject(((arrTemp.firstObject! as AnyObject).value(forKey: "phoneNo"))!, forKey:"contactNumber" as NSCopying)
                        tempDict.setObject(((arrTemp.firstObject! as AnyObject).value(forKey: "contactName"))!, forKey:"contactName" as NSCopying)
                        tempDict.setObject(((arrTemp.firstObject! as AnyObject).value(forKey: "deviceToken"))!,  forKey:"deviceToken" as NSCopying)
                        tempDict.setObject(dict.object(forKey: "userId")!, forKey:"userId" as NSCopying)
                        tempDict.setObject(dict.object(forKey: "groupId")!, forKey:"groupId" as NSCopying)
                        tempDict.setObject(dict.object(forKey: "userName")!, forKey:"userName" as NSCopying)
                        tempDict.setObject(((arrTemp.firstObject! as AnyObject).value(forKey: "profilePic"))!,  forKey:"profilePic" as NSCopying)
                        tempDict.setObject(dict.object(forKey: "userType")!, forKey:"userType" as NSCopying)
                        
                        let regextest:NSPredicate = NSPredicate(format: "( userId CONTAINS[C] %@ )", argumentArray: [(tempDict.value(forKey: "userId"))!])
                        let arrTemp1:NSMutableArray = self.arrGroupUsers.mutableCopy() as! NSMutableArray
                        arrTemp1.filter(using: regextest)
                        
                        if(arrTemp1.firstObject != nil)
                        {
                            
                        }
                        else
                        {
                            self.arrGroupUsers.add(tempDict)
                            
                        }
                    }
                    else
                    {
                        //The user that donot exists in Contacts will retrieve their data from Firebase
                        let strKey = dict.value(forKey: "userId") as!String
                        ref.child("users").child(strKey).observeSingleEvent(of: .value, with: { (snapshot) in
                            if snapshot.exists()
                            {
                                let tempDict : NSMutableDictionary = NSMutableDictionary()
                                tempDict.setObject((snapshot.value! as AnyObject).value(forKey: "phoneNo")!, forKey:"contactName" as NSCopying)
                                tempDict.setObject(strKey, forKey:"userId" as NSCopying)
                                tempDict.setObject((snapshot.value! as AnyObject).value(forKey: "profilePic")!, forKey:"profilePic" as NSCopying)
                                tempDict.setObject((snapshot.value! as AnyObject).value(forKey: "deviceToken")!, forKey:"deviceToken" as NSCopying)
                                tempDict.setObject((snapshot.value! as AnyObject).value(forKey: "status")!, forKey:"status" as NSCopying)
                                tempDict.setObject(dict.object(forKey: "groupId")!, forKey:"groupId" as NSCopying)
                                tempDict.setObject(dict.object(forKey: "userName")!, forKey:"userName" as NSCopying)
                                tempDict.setObject(dict.object(forKey: "profilePic")!, forKey:"profilePic" as NSCopying)
                                tempDict.setObject(dict.object(forKey: "userType")!, forKey:"userType" as NSCopying)
                                
                               
                                let regextest:NSPredicate = NSPredicate(format: "( userId CONTAINS[C] %@ )", argumentArray: [(tempDict.value(forKey: "userId"))!])
                                let arrTemp2:NSMutableArray = self.arrGroupUsers.mutableCopy() as! NSMutableArray
                                arrTemp2.filter(using: regextest)
                                
                                if(arrTemp2.firstObject != nil)
                                {
                                    
                                }
                                else
                                {
                                    self.arrGroupUsers.add(tempDict)
                                }
                            }
                            completionHandler()
                        })
                    }
                }
            }
            HideLoader()
        })
    }
}
