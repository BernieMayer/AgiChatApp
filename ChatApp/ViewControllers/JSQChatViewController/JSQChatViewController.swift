//
//  JSQChatViewController.swift
//  ChatApp
//
//  Created by admin on 28/10/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

@available(iOS 9.0, *)
class JSQChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{

    //Outgoing UIColor.jsq_messageBubbleLightGrayColor()
    //Incoming UIColor.jsq_messageBubbleGreenColor()
    var messages = [Message]()
    var avatars = Dictionary<String, UIImage>()
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubblePinkColor())
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleWhiteColor())
    var senderImageUrl: String!
    var batchMessages = true
    
    //VARIABLE FOR FIREBASE
    private var _refHandle: FIRDatabaseHandle!
    var ref: FIRDatabaseReference!
    var user : FIRAuth!
    
    //for other user
    var userId : String = String()
    var getUser : String = String()
    
    //for snap
    var snapUserId : NSMutableDictionary = NSMutableDictionary()
    
    //For current user
    var getID : String = String()
    var myDisplayName : String = String()
    var arrId : NSMutableArray = NSMutableArray()
    var arrUser : NSMutableArray = NSMutableArray()
    
    var isFrom : Bool = Bool()
    
    //User Variables set
    var userName : String = String()
    var status :  String = String()
    var getId : String = String()
    var proPic : UIImageView = UIImageView()

    
    
    
    /*Dot Menu*/
    var menuItems: [AnyObject] = ["View Contact", "Media", "Search","Wapllpaper","More"]
    @IBOutlet var dotMenuView: UIView!
    @IBOutlet var tblDotMenu: UITableView!
    
    /*Navigation Bar*/
    let imagePicker = UIImagePickerController()
    
    //topicChatVariables
    //var myId = ""
    var mobile : String = String()
    var newTopicChatID : String = String()
    var newTopicChatID2 : String = String()
    var otherID = ""
    var otherEmail = ""
    let arrData : NSMutableArray = NSMutableArray()
    var arrTopicData : NSMutableArray = NSMutableArray()
        
    //RECENT CHAT VARIABLES
    var childKey : String = String()
    var otherChildKey : String = String()
    var getCurrentObject : String = String()
    var getOtherObject : String = String()
    
    //GROUP CHAT VARIABLES
    var arrUserGroupDetails : NSMutableArray = NSMutableArray()
    var groupName : String = String()
    var groupUsers : String = String()
    var arrGroupUsers : NSMutableArray = NSMutableArray()
    var groupId : String = String()
    var groupIcon : UIImageView  = UIImageView()
    var newGroupId : String = String()
    var isGroupChat : Bool = Bool()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputToolbar.contentView.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        navigationController?.navigationBar.topItem?.title = "Logout"
        
        sender = Constants.loginFields.name //(sender != nil) ? sender : "Anonymous"
        
        //AVATAR REMAINING
        
        //   let profileImageUrl = Constants.loginFields.imageUrl
        /*  if let urlString =  Constants.loginFields.imageUrl  {
         setupAvatarImage(sender, imageUrl: urlString as String, incoming: false)
         senderImageUrl = urlString as String
         } else {
         setupAvatarColor(sender, incoming: false)
         senderImageUrl = ""
         }*/
        
       // setupFirebase()
        //configureDatabase()

    }

    //MARK:- Setup Firebase
    //MARK:-
    
    func setupFirebase() {
        // *** STEP 2: SETUP FIREBASE
        ref = FIRDatabase.database().reference()
        
        // *** STEP 4: RECEIVE MESSAGES FROM FIREBASE (limited to latest 25 messages)
           ref.child("Test").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let text = snapshot.value!.valueForKey("text") as! String
            
          //  let text = snapshot.value!["text"] as? String
            let sender = snapshot.value!.valueForKey("sender") as! String
           // let imageUrl = snapshot.value!["imageUrl"] as? String
            
            let message = Message(text: text, sender: sender)
            self.messages.append(message)
            print(self.messages.count)
            self.finishReceivingMessage()
        })
    }

    //MARK:- Confiugring Data Base
    //MARK:-
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        //will connect to firebase database
        if(isGroupChat == true)
        {
            if(groupId == "")
            {
                
            }
            else
            {
                // Listen for new messages in the Firebase database
                //when any new child is added
                SwiftLoader.show(title: "Loading chats...", animated: true)
                
                ref.child("groupChat").child(groupId).observeEventType(.ChildAdded, withBlock: { (snapshot) in
                    
                    let text = snapshot.value!.valueForKey("message") as! String
                    let sender = snapshot.value!.valueForKey("userName") as! String
                    //let imageUrl = snapshot.value!.valueForKey("groupIcon") as! String
                    let message = Message(text: text, sender: sender)
                    self.messages.append(message)
                    print(self.messages.count)
                    self.finishReceivingMessage()
                })
                
            }
            SwiftLoader.hide()
        }
        else
        {
            // Listen for new messages in the Firebase database
            //when any new child is added
            ref.child("chat").observeEventType(.ChildAdded, withBlock: { (snapshot) in
                
                let text = snapshot.value!.valueForKey("message") as! String
                let sender = snapshot.value!.valueForKey("userId") as! String
                let message = Message(text: text, sender: sender)
                self.messages.append(message)
                print(self.messages.count)
                self.finishReceivingMessage()
            })
            
        }
        
    }
    
    //MARK:- Send Message
    //MARK:-
    
    func sendMessage(text: String!, sender: String!) {
        // *** STEP 3: ADD A MESSAGE TO FIREBASE
       // ref = FIRDatabase.database().reference()
        ref.child("Test").childByAutoId().setValue(
            ["text":text,"sender":sender])
    }

    func tempSendMessage(text: String!, sender: String!) {
        let message = Message(text: text, sender: Constants.loginFields.name, imageUrl: "")
        messages.append(message)
    }
    
    //MARK:- Avatar setup
    //MARK:-
    
    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool) {
        if let stringUrl = imageUrl {
            if let url = NSURL(string: stringUrl) {
                if let data = NSData(contentsOfURL: url) {
                    let image = UIImage(data: data)
                    let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
                    let avatarImage = JSQMessagesAvatarFactory.avatarWithImage(image, diameter: diameter)
                    avatars[name] = avatarImage
                    return
                }
            }
        }
        
        // At some point, we failed at getting the image (probably broken URL), so default to avatarColor
        setupAvatarColor(name, incoming: incoming)
    }
    
    //MARK:- SetUp Avatar Color
    //MARK:-
    
    func setupAvatarColor(name: String, incoming: Bool) {
        let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
        
        let rgbValue = name.hash
        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
        
        let nameLength = name.characters.count
        let initials : String? = name.substringToIndex(sender.startIndex.advancedBy(min(3, nameLength)))
        let userImage = JSQMessagesAvatarFactory.avatarWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
        
        avatars[name] = userImage
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- ACTIONS
    //MARK:-
    func receivedMessagePressed(sender: UIBarButtonItem) {
        // Simulate reciving message
        showTypingIndicator = !showTypingIndicator
        scrollToBottomAnimated(true)
    }

    override func didPressSendButton(button: UIButton!, withMessageText text: String!, sender: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
    let date = NSDateFormatter()
        date.dateFormat = "MMM d, yyyy hh:mm:ss a"
        var newDate = date.stringFromDate(NSDate())
        newDate = newDate.stringByReplacingOccurrencesOfString("AM", withString: "am")
        newDate = newDate.stringByReplacingOccurrencesOfString("PM", withString: "pm")
       
        
        let dict : NSMutableDictionary = NSMutableDictionary()
        let arrGrpData : NSMutableArray = NSMutableArray()
        dict.setObject(groupId, forKey: "groupId")
        dict.setObject(text, forKey:  "message")
        dict.setObject("false", forKey: "stared")
        dict.setObject(newDate, forKey: "timeStamp")
        dict.setObject(Constants.loginFields.userId, forKey: "userId")
        dict.setObject(Constants.loginFields.name, forKey: "userName")
        arrGrpData.addObject(dict)
        let data = [Constants.GroupFields.lastMessage: text as String]
        sendGroupChatMessage(data, arrGrpData: arrGrpData)
        
        //sendMessage(text, sender: Constants.loginFields.userId)
      //  finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("Camera pressed!")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, bubbleImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        let message = messages[indexPath.item]
        
        if message.sender() == Constants.loginFields.name {
            return UIImageView(image: outgoingBubbleImageView.image, highlightedImage: outgoingBubbleImageView.highlightedImage)
        }
        
        return UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        let message = messages[indexPath.item]
        if let avatar = avatars[message.sender()] {
            return UIImageView(image: avatar)
        } else {
            setupAvatarImage(message.sender(), imageUrl: message.imageUrl(), incoming: true)
            return UIImageView(image:avatars[message.sender()])
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        if message.sender() != Constants.loginFields.name
         {
            cell.textView.textColor = UIColor.blackColor()
         }
         else
         {
            cell.textView.textColor = UIColor.whiteColor()
         }
        
        let attributes : [String:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor!, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes
        
        //cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView.textColor,
        //NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle]
        return cell
    }

    
    // View  usernames above bubbles
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item];
        
        // Sent by me, skip
        if message.sender() == Constants.loginFields.name {
            return nil;
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sender() == message.sender() {
                return nil;
            }
        }
        
        return NSAttributedString(string:message.sender())
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat
    {
        let message = messages[indexPath.item]
        
        // Sent by me, skip
        if message.sender() == Constants.loginFields.userId {
            return CGFloat(0.0);
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sender() == message.sender() {
                return CGFloat(0.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
        configureDatabase()
        collectionView.collectionViewLayout.springinessEnabled = true
        lblName.text = groupName
        var string  = "You"
        for i in 0..<arrGroupUsers.count
        {
            if(arrGroupUsers.objectAtIndex(i).valueForKey("userId") as! String != Constants.loginFields.userId)
            {
                print(arrGroupUsers.objectAtIndex(i))
                string = string + " ,".stringByAppendingString(arrGroupUsers.objectAtIndex(i).valueForKey("userName") as! String)
                self.lblStatus.text = string
            }
        }
        imgGroupIcon.image = groupIcon.image
    }
    //MARK:- On Dot Menu Click
    //MARK:-
    override func onDotMenuClick() {
        openMenu()
    }
    //MARK:- View Profile
    //MARK:-
    override func onButtonProfileClick() {
        
        if #available(iOS 9.0, *) {
            let groupProfileVC : GroupProfileViewController = storyboard?.instantiateViewControllerWithIdentifier("GroupProfileViewController") as! GroupProfileViewController
            groupProfileVC.lblGroupName.text = groupName
            groupProfileVC.groupId = groupId
            groupProfileVC.imgGroupIcon.image = groupIcon.image
            groupProfileVC.arrGroupUsers = arrGroupUsers
            
             self.navigationController?.pushViewController(groupProfileVC, animated: true)
        } else {
            // Fallback on earlier versions
        }
       
    }

    //MARK:- Updating existing group Chatting
    //MARK:-
    func sendGroupChatMessage(data: [String: String], arrGrpData : NSMutableArray)
    {
        var mdata = data
        let date = NSDateFormatter()
        date.dateFormat = "MMM d, yyyy hh:mm:ss a"
        var newDate = date.stringFromDate(NSDate())
        newDate = newDate.stringByReplacingOccurrencesOfString("AM", withString: "am")
        newDate = newDate.stringByReplacingOccurrencesOfString("PM", withString: "pm")
        
        // mdata[Constants.GroupFields.groupId] = groupId
        //mdata[Constants.GroupFields.groupName] = groupName
        mdata[Constants.GroupFields.adminId] = self.getID
        mdata[Constants.GroupFields.adminName] = Constants.loginFields.name
        mdata[Constants.GroupFields.timeStamp] = newDate
        
        if(groupId == "")
        {
            groupId = newGroupId
        }
        
        //Adding Chat to current group
        
        for i in 0..<arrGrpData.count
        {
            
            self.ref.child("groupChat").child(self.groupId).childByAutoId().setValue(arrGrpData.objectAtIndex(i) as! [NSObject : AnyObject])
        }
        
        ref.child("group").child(groupId).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if snapshot.exists()
            {
                for i in 0..<arrGrpData.count
                {
                    self.ref.child("group").child(self.groupId).updateChildValues(mdata)
                }
            }
            else
            {
                
            }
        })
    }
    
    
    //MARK:- Open Dot Menu
    //MARK:-
    func openMenu()  {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        // 2
        let viewCon = UIAlertAction(title:"View Contact" , style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("View Contact")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainVC = storyboard.instantiateViewControllerWithIdentifier("ContactViewController") as! ContactViewController
            
            self.navigationController?.pushViewController(mainVC, animated: true)
            
        })
        let media = UIAlertAction(title: "Media", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Media")
            
        })
        let search = UIAlertAction(title: "Search", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Search")
        })
        let wallpaper = UIAlertAction(title: "Wallpaper", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Wallpaper")
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
            
            
        })
        let more = UIAlertAction(title: "More", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("More")
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
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
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }

}
