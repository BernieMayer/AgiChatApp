//
//  ContactViewController.swift
//  ChatApp
//
//  Created by Anis Mansuri on 02/07/16.
//  Copyright © 2016 Agile. All rights reserved.
//


import UIKit
import Firebase
import Contacts
import ContactsUI
import FirebaseStorage
import MessageUI


@available(iOS 9.0, *)
class ContactViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    @IBOutlet var barView: UIView!
    @IBOutlet var tblContact: UITableView!
    @IBOutlet var myCollection : UICollectionView!
    @IBOutlet weak var txtGroupName: UITextField!
    @IBOutlet weak var btnGroupIcon: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var tblContactTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    
    
    //getting User Variables
    var arrFilteredContacts : NSMutableArray = NSMutableArray()
    var imageProPic : UIImageView = UIImageView()
    
    //Creating Group Chat Variables
    var isComingFrom : String = String()                                                       // Store viewcontroller it navigated from
    var arrSelectedContacts : NSMutableArray = NSMutableArray()           // Stores Selected contact
    var isSelected : Bool = Bool()
    var groupName : String = String()                                                            //Stores name of group
    var groupId : String = String()                                                                  //Stores Group Id
    var userPhoto : UIImage?                                                                       //Stores User's photo / group icon
    var existingContacts : NSMutableArray = NSMutableArray()                 // stores contacts exists in firebase
    var arrAddUser : NSMutableArray = NSMutableArray()                         //stores users that are to be Added in group
    var arrAddGroupContacts : NSMutableArray = NSMutableArray()       //stores Contacts that are to be Added in group
    var arrGroupContacts : NSMutableArray = NSMutableArray()             //Stores array of group contacts
    
    //FIREBASE STORAGE VARIBLES
    var storageRef: FIRStorageReference!
    var imageURL : String = String()                                                        //Stores group icon URL
    var groupNewId : String = String()                                                      //Stores newly created Group Id
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Registering Nib
        tblContact.registerNib(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "contactCell")
        
        txtGroupName.delegate = self
        isSelected = false
        
        if(isComingFrom == "Group") //When it navigates from Create Group
        {
            tblContact.allowsMultipleSelection = true
            lblTitle.text = "Create Group"
            btnDone.setImage(UIImage(named: "done"), forState: .Normal)
            
        }
        else if(isComingFrom == "GroupA") // When it navigates from Add group User
        {
            tblContact.allowsMultipleSelection = true
            lblTitle.text = "Add User"
            btnDone.setImage(UIImage(named: "done"), forState: .Normal)
            
            btnGroupIcon.hidden = true
            txtGroupName.hidden = true
            tblContactTopConstraint.constant = 0
            updateViewConstraints()
            
        }
        else if(isComingFrom == "Settings") //When it navigates from the Contacts in settings
        {
            btnGroupIcon.hidden = true
            txtGroupName.hidden = true
            tblContactTopConstraint.constant = 0
            self.view.updateConstraints()
            
            lblTitle.text = "Contacts"
            tblContact.allowsMultipleSelection = false
            btnDone.hidden = true
            tblContact.reloadData()
        }
        else
        {
            tblContact.allowsMultipleSelection = false
            btnDone.setImage(UIImage(named: "search"), forState: .Normal)
        }
        configureStorage()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
       
    }
    
    //MARK:- TextField Delegate
    //MARK:-
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }

    
    //MARK:- Image storage configuration
    //MARK:-
    func configureStorage() {
        storageRef = FIRStorage.storage().referenceForURL("\(FIREBASE_STORAGE_URL)")
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        isSelected = false
        
        if(isComingFrom == "Group")              //When it navigates from Create Group
        {
            tblContact.allowsMultipleSelection = true
            btnDone.setImage(UIImage(named: "done"), forState: .Normal)
        }
        else if(isComingFrom == "GroupA")      // When it navigates from Add group User
        {
            tblContact.allowsMultipleSelection = true
            btnDone.setImage(UIImage(named: "done"), forState: .Normal)
            
            btnGroupIcon.hidden = true
            txtGroupName.hidden = true
            tblContactTopConstraint.constant = 0
            updateViewConstraints()
        }
        else if(isComingFrom == "Settings")    // When it navigates from the Contacts in settings

        {
            btnGroupIcon.hidden = true
            txtGroupName.hidden = true
            tblContactTopConstraint.constant = 0
            self.view.updateConstraints()
            
            tblContact.allowsMultipleSelection = false
            btnDone.setImage(UIImage(named: "search"), forState: .Normal)
        }
        else
        {
            tblContact.allowsMultipleSelection = false
            btnDone.setImage(UIImage(named: "search"), forState: .Normal)
        }
        configureStorage() //Configures storage for storing in Storage in database
    }
    
    @IBAction func btnBack(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    //MARK:- BUTTON SEARCH CLICK EVENT
    //MARK:-
    
    @IBAction func btnSearch(sender: AnyObject) {
        
        if(AIReachability.sharedManager.isAavailable())
        {
            if(isComingFrom == "Group") //Filters the selected contacts for Creating Group
            {
                let data = [Constants.GroupFields.groupName: txtGroupName.text! as String]
                if(txtGroupName.text?.length > 0)
                {
                    
                var indexPathArray : NSArray!
                indexPathArray = self.tblContact.indexPathsForSelectedRows
             if(self.tblContact.indexPathsForSelectedRows?.count > 0 )
              {
                for i in 0..<indexPathArray.count
                 {
                     let index = indexPathArray.objectAtIndex(i).row
                     let dict : NSMutableDictionary = NSMutableDictionary()
                    dict.setObject((arrGroupContacts.objectAtIndex(index).objectForKey("userId") as? String)!, forKey: "userId")
                    dict.setObject((arrGroupContacts.objectAtIndex(index).objectForKey("firstName") as? String)!, forKey: "userName")
                    dict.setObject((arrGroupContacts.objectAtIndex(index).objectForKey("profilePic") as? String)!, forKey: "profilePic")
                    dict.setObject((arrGroupContacts.objectAtIndex(index).objectForKey("deviceToken") as? String)!, forKey: "deviceToken")
                    
                     dict.setObject("", forKey: "userType")
                     arrSelectedContacts.addObject(dict)
                   }
                
                     ////////
                     let dict1 : NSMutableDictionary = NSMutableDictionary()
                     dict1.setObject(Constants.loginFields.userId, forKey: "userId")
                     dict1.setObject(Constants.loginFields.name, forKey: "userName")
                     dict1.setObject(Constants.loginFields.imageUrl, forKey: "profilePic")
                     dict1.setObject(Constants.loginFields.deviceToken, forKey: "deviceToken")
                    arrSelectedContacts.addObject(dict1)
                
                        
                   if(AIReachability.sharedManager.isAavailable())
                    {
                        self.createGroup(data, arr: arrSelectedContacts)
                     }
                    }
                    else
                    {
                        displayAlert("Atleast one contact must be selected", presentVC: self)
                    }
                }
                else
                {
                    displayAlert("Please enter group name", presentVC: self)
                }
            }
            else if(isComingFrom == "GroupA") //Filters the selected contacts for Adding User to Group
            {
                let data = [Constants.GroupFields.groupId: groupId]
                var indexPathArray : NSArray!
                indexPathArray = self.tblContact.indexPathsForSelectedRows
                
                if(self.tblContact.indexPathsForSelectedRows?.count > 0 )
                {
                    
                    for i in 0..<indexPathArray.count
                    {
                        
                        let dict : NSMutableDictionary = NSMutableDictionary()
                        let index = indexPathArray.objectAtIndex(i).row
                        dict.setObject((arrAddUser.objectAtIndex(index).objectForKey("userId") as? String)!, forKey: "userId")
                        dict.setObject((arrAddUser.objectAtIndex(index).objectForKey("firstName") as? String)!, forKey: "userName")
                        dict.setObject((arrAddUser.objectAtIndex(index).objectForKey("profilePic") as?  String)!, forKey: "profilePic")
                       dict.setObject((arrAddUser.objectAtIndex(index).objectForKey("deviceToken") as?  String)!, forKey: "deviceToken")
                        dict.setObject("", forKey: "userType")
                        dict.setObject(groupId, forKey: "groupId")
                        
                        let regextest:NSPredicate = NSPredicate(format: "( userId CONTAINS[C] %@ )", argumentArray: [dict["userId"]!])
                        let arrTemp:NSMutableArray = arrSelectedContacts.mutableCopy() as! NSMutableArray
                        arrTemp.filterUsingPredicate(regextest)
                        if(arrTemp.firstObject != nil)
                        {
                            
                        }
                        else
                        {
                            arrSelectedContacts.addObject(dict)
                        }
                    }
                }
                self.addUser(data, arr: arrSelectedContacts)
            }
        }
    }
    
    
    @IBAction func btnGroupIcon(sender: UIButton) { //Sets group icon
        
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            picker.sourceType = .PhotoLibrary
        } else {
            picker.sourceType = .PhotoLibrary
        }
        presentViewController(picker, animated: true, completion:nil)
    }
    
    //MARK:- View Will Appear
    //MARK:-
    override func viewWillAppear(animated: Bool) {
        barView.backgroundColor = navigationColor
        hideNavigationBar()
        
        txtGroupName.autocorrectionType = UITextAutocorrectionType.No
        isSelected = false
        
        if(isComingFrom == "Group")
        {
            tblContact.allowsMultipleSelection = true
            lblTitle.text = "Create Group"
            btnDone.setImage(UIImage(named: "done"), forState: .Normal)
            arrGroupContacts = UserDefaults.sharedInstance.GetArrayFromUserDefault(phoneContacts) // Storing Contacts to arrGroupContact
        }
        else if(isComingFrom == "GroupA")
        {
            btnGroupIcon.hidden = false
            txtGroupName.hidden = false
            
            tblContact.allowsMultipleSelection = true
            btnDone.setImage(UIImage(named: "done"), forState: .Normal)
            lblTitle.text = "Add User"
            NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector:  #selector(ContactViewController.methodToBeCalled), userInfo: nil, repeats: false)
            
            btnGroupIcon.hidden = true                        //hidding group icon button
            txtGroupName.hidden = true                      //hiding group name text field
            tblContactTopConstraint.constant = 0       // Setting table top contraint
        
            arrAddGroupContacts.removeAllObjects()
            arrAddGroupContacts = UserDefaults.sharedInstance.GetArrayFromUserDefault(phoneContacts) //Stores all fetched contacts from device
            
            updateViewConstraints()
        }
            
        else if(isComingFrom == "Settings")
        {
            tblContactTopConstraint.constant = 0
            self.view.updateConstraints()
            
            lblTitle.text = "Contacts"
            tblContact.allowsMultipleSelection = false
            btnDone.setImage(UIImage(named: "search"), forState: .Normal)
        }

        else
        {
            tblContact.allowsMultipleSelection = false
            btnDone.setImage(UIImage(named: "search"), forState: .Normal)
            arrFilteredContacts.removeAllObjects()
            arrFilteredContacts = UserDefaults.sharedInstance.GetArrayFromUserDefault(allContacts)
        }
    }
    
    // MARK:- TableView DATASOURCE & DELEGATES
    // MARK:-
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if(isComingFrom == "GroupA") //When navigates from Add User returns arrAdduser Count
        {
            return arrAddUser.count
        }
        if(isComingFrom == "Group")  //When navigates from Create Group returns arrGroupContacts Count
        {
            return arrGroupContacts.count
        }
        else
        {
            return arrFilteredContacts.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        if(isComingFrom == "GroupA")  //When navigates from Add User
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath) as! ContactCell
            cell.selectionStyle = UITableViewCellSelectionStyle.Gray
            cell.lblUserName.text = arrAddUser.objectAtIndex(indexPath.row).objectForKey("contactName") as? String
            
            if(arrAddUser.objectAtIndex(indexPath.row).objectForKey("profilePic") as? String != "null")
            {
                let img = arrAddUser.objectAtIndex(indexPath.row).objectForKey("profilePic") as? String
                cell.imgViewProfile.sd_setImageWithURL(NSURL(string: img!), placeholderImage: UIImage(named: "default_profile"))
            }
            else
            {
                cell.imgViewProfile.image = UIImage(named: "default_profile")
            }
            
            return cell
        }
        else if(isComingFrom == "Group") //When navigates from Create Group
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath) as! ContactCell
            
                cell.lblUserName.text = arrGroupContacts.objectAtIndex(indexPath.row).objectForKey("contactName") as? String
                cell.btnInvite.hidden = true
                if(arrGroupContacts.objectAtIndex(indexPath.row).objectForKey("profilePic") as? String != "null")
                {
                    let img = arrGroupContacts.objectAtIndex(indexPath.row).objectForKey("profilePic") as? String
                    cell.imgViewProfile.sd_setImageWithURL(NSURL(string: img!), placeholderImage: UIImage(named: "default_profile"))
                }
                else
                {
                    cell.imgViewProfile.image = UIImage(named: "default_profile")
                }

            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath) as! ContactCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            if(arrFilteredContacts.count > 0)
            {
                if(arrFilteredContacts.objectAtIndex(indexPath.row).valueForKey("userId") as! String != "")
                {
                    cell.btnInvite.hidden = true
                    cell.lblUserName.text = arrFilteredContacts.objectAtIndex(indexPath.row).objectForKey("contactName") as? String
                    cell.lblStatus.text = arrFilteredContacts.objectAtIndex(indexPath.row).objectForKey("status") as? String
                    if(arrFilteredContacts.objectAtIndex(indexPath.row).objectForKey("profilePic") as? String != "null")
                    {
                        let img = arrFilteredContacts.objectAtIndex(indexPath.row).objectForKey("profilePic") as? String
                        cell.imgViewProfile.sd_setImageWithURL(NSURL(string: img!),placeholderImage: UIImage(named: "default_profile"))
                    }
                    else
                    {
                        cell.imgViewProfile.image = UIImage(named: "default_profile")
                    }
                    return cell
                }
                else
                {
                    cell.lblUserName.text = arrFilteredContacts.objectAtIndex(indexPath.row).objectForKey("contactName") as? String
                    cell.imgViewProfile.image = UIImage(named: "default_profile")
                    cell.lblTime.hidden = true
                    cell.lblStatus.text = arrFilteredContacts.objectAtIndex(indexPath.row).valueForKey("phoneNo") as? String
                    cell.btnInvite.hidden = true
                    //cell.btnInvite.addTarget(self, action: #selector(onInviteButtonClick(_:)), forControlEvents: .TouchUpInside)
                    return cell
                }
            }
            else
            {
                return UITableViewCell()
            }
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //Managing contact selection for CREATE GROUP and ADD USER
        if(isComingFrom == "Group" && isSelected == false)
        {
            tblContact.allowsMultipleSelection = true //Multiple selection enabled
            
        }
        else if(isComingFrom == "GroupA")
        {
            tblContact.allowsMultipleSelection = true //Multiple selection enabled
        }
        else
        {
            
        }
    }
    
    //MARK:- Height For Row
    //MARK:-
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    
    //MARK:- image picker delegate
    //MARK:-
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?)  {
        userPhoto = image
        dismissViewControllerAnimated(true, completion: nil)
        btnGroupIcon.setImage(userPhoto, forState: .Normal)
        btnGroupIcon.imageView?.contentMode = .ScaleAspectFit
    }
    
    
    //MARK:- Add User Contacts
    //MARK:-
    func methodToBeCalled(){ //this method will display the contacts that is to be added
        
        var arrTemp : NSMutableArray = NSMutableArray()
        arrTemp = self.arrAddGroupContacts.mutableCopy() as! NSMutableArray
        ShowLoader()
        
        arrAddUser.removeAllObjects()
        
        //filtering contacts to display only contacts that are not in the group
        for i in 0..<self.arrAddGroupContacts.count
        {
            if(arrAddGroupContacts.objectAtIndex(i).objectForKey("userId") as! String != "")
            {
                let dict : NSDictionary = self.arrAddGroupContacts.objectAtIndex(i) as! NSDictionary
                
                for j in 0..<self.existingContacts.count  {
                    let dictChild : NSDictionary = self.existingContacts.objectAtIndex(j) as! NSDictionary
                    if dict.valueForKey("userId") as! String == dictChild.valueForKey("userId") as! String {
                        
                        arrTemp.removeObject(dict)
                    }
                    else{
                        
                    }
                }
            }
        }
        self.arrAddUser = arrTemp.mutableCopy() as! NSMutableArray
        self.arrAddUser.sortedArrayUsingDescriptors([NSSortDescriptor(key: "contactName", ascending: false)]) as! [[String:AnyObject]]
        HideLoader()
        tblContact.reloadData()
    }
    
    
    //MARK:- ADD GROUP USER
    //MARK:-
    func addUser(data: [String: String], arr : NSMutableArray)
    {

        subscribeUser(arr, groupId: groupId) //Subscribe new added user/users
        if(AIReachability.sharedManager.isAavailable()) //Check for Internet Connnection
        {
            //ADD GROUP USERS
            if arr.count > 0
            {
                for i in 0..<arr.count {
                    
                    if(arr.objectAtIndex(i).valueForKey("userId") as! String != Constants.loginFields.userId)
                    {
                        let dict1 : NSMutableDictionary = NSMutableDictionary()
                        dict1.setObject(arr.objectAtIndex(i).valueForKey("userId")!, forKey: "userId")
                        dict1.setObject(arr.objectAtIndex(i).valueForKey("userName")!, forKey: "userName")
                        dict1.setObject(arr.objectAtIndex(i).valueForKey("profilePic")!, forKey: "profilePic")
                        dict1.setObject(arr.objectAtIndex(i).valueForKey("userType")!, forKey: "userType")
                        dict1.setObject(arr.objectAtIndex(i).valueForKey("groupId")!, forKey: "groupId")
                        ref.child("groupUsers").childByAutoId().setValue(dict1) // Store added user to database
                    }
                }
                
                //Navigate to tab view controller after Storing new added user to group users
                let tabVC : TabViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TabViewController") as! TabViewController
                tabVC.btnGrp = false
                tabVC.btnChat = true
                tabVC.btnContact = false
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: btnGroup)
                NSUserDefaults.standardUserDefaults().synchronize()
                self.navigationController?.pushViewController(tabVC, animated: true)
            }
        }
    }
    
    
    //MARK:- CREATE GROUP
    //MARK:-
    func createGroup(data: [String: String], arr : NSMutableArray)
    {
        ShowLoader()
        var mdata = data
        let date = NSDateFormatter()
        
        let formatString: NSString = NSDateFormatter.dateFormatFromTemplate("j", options: 0, locale: NSLocale.currentLocale())!
        let hasAMPM = formatString.containsString("a")
        
        if(hasAMPM == true)
        {
            date.dateFormat = "MMM d, yyyy hh:mm:ss a"
        }
        else
        {
             date.dateFormat = "MMM d, yyyy HH:mm:ss a"
        }
       
        var newDate = date.stringFromDate(NSDate())
        newDate = newDate.stringByReplacingOccurrencesOfString("AM", withString: "am")
        newDate = newDate.stringByReplacingOccurrencesOfString("PM", withString: "pm")
        
        mdata[Constants.GroupFields.groupName] = txtGroupName.text
        mdata[Constants.GroupFields.adminId] = Constants.loginFields.userId
        mdata[Constants.GroupFields.adminName] = Constants.loginFields.name
        mdata[Constants.GroupFields.timeStamp] = newDate
        
        if(self.imageURL == "")
        {
            mdata[Constants.GroupFields.groupIcon] = ""
        }
        else
        {
            mdata[Constants.GroupFields.groupIcon] = self.imageURL
        }
        mdata[Constants.GroupFields.lastMessage] = ""
        
        //getting key directly as soon as it is created using childByAutoId
        let postGroupRef = ref.child("group")
        let postGroup1Ref = postGroupRef.childByAutoId()
        postGroup1Ref.setValue(mdata)

        let newGroupId = postGroup1Ref.key
        if(AIReachability.sharedManager.isAavailable())
        {
            subscribeUser(arr, groupId: newGroupId)
            self.createGroupUsers(arr,newGroupId: newGroupId)
        }
      
                    // Upload Group icon  //
                   ////////////////////////////////
        
        if(AIReachability.sharedManager.isAavailable()) //Checking for Internet Connection
        {
            var data = NSData()
            if(self.userPhoto != nil) //if group icon photo is not nil
            {
                
                data = UIImageJPEGRepresentation(self.userPhoto!, 0.8)!
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/jpg"
                
                //Storing image to database storage and then string downloaded URL to variable
                self.storageRef.child(newGroupId).putData(data, metadata: metaData){(metaData,error) in
                    if let error = error { //error
                        return
                    }else{
                        //store downloadURL
                        let downloadURL = metaData!.downloadURL()!.absoluteString
                        self.imageURL = downloadURL!
                        //SwiftLoader.hide()
                        HideLoader()
                        //Storing downloaded URL in database
                        ref.child("group").child(newGroupId).updateChildValues(["groupIcon" : self.imageURL])
                        
                        self.groupId = newGroupId //storing group ID
                        FIRMessaging.messaging().subscribeToTopic(self.groupId) //Subscribing to topic for notification
                        
                        //Navigating to Tab View Controller
                        let tabVC : TabViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TabViewController") as! TabViewController
                        tabVC.groupId = self.groupId
                        tabVC.btnGrp = true
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: btnGroup)
                        NSUserDefaults.standardUserDefaults().synchronize()
                        HideLoader()
                        self.navigationController?.pushViewController(tabVC, animated: true)
                    }
                }
            }
            else
            {
                //When has no group icon
                if(AIReachability.sharedManager.isAavailable())
                {
                    let tabVC : TabViewController = storyboard?.instantiateViewControllerWithIdentifier("TabViewController") as! TabViewController
                    tabVC.groupId = self.groupId
                    tabVC.btnGrp = true
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: btnGroup)
                    NSUserDefaults.standardUserDefaults().synchronize()
                    self.navigationController?.pushViewController(tabVC, animated: true)
                }
            }
        }
    }
    
    
    //MARK:- Subscribe Group Users
    //MARK:-
    func subscribeUser(arrGroupUsers : NSMutableArray, groupId : String)
    {
      
        //Subscribing group users
        for i in 0..<arrGroupUsers.count
        {
            let dict1 : NSMutableDictionary = NSMutableDictionary()
            
            dict1.setObject(groupId, forKey: "topic_key")
            
            if(arrGroupUsers.objectAtIndex(i).valueForKey("userId") as! String == Constants.loginFields.userId)
            {
                dict1.setObject(Constants.loginFields.deviceToken, forKey: "device_token")
            }
            else
            {
                dict1.setObject(arrGroupUsers.objectAtIndex(i).valueForKey("deviceToken")!, forKey: "device_token")
            }
            
            //Calling API for Subscribing Users
            HttpManager.sharedInstance.subscribeGroupDevice("", loaderShow: false, dict: dict1, SuccessCompletion: { (result) in
                
                     print("Subscribed") ///When Successfully Subscribed
                
                }, FailureCompletion: { (result) in
                    
                    print("Not Subscribed")  //When Failed to Subscribe
            })
        }
    }
    
    
    //MARK:- Create Group Users
    //MARK:-
    func createGroupUsers(arr : NSMutableArray, newGroupId : String)
    {
        //CREATE GROUP USERS
        let arrAdd : NSMutableArray = NSMutableArray()
      
        for i in 0..<arr.count {
            
            if(arr.objectAtIndex(i).objectForKey("userId") as! String == Constants.loginFields.userId) //getting current user detail for storing in group users
            {
                let dict : NSMutableDictionary = NSMutableDictionary()
                dict.setObject(Constants.loginFields.userId, forKey: "userId")
                dict.setObject(Constants.loginFields.name, forKey: "userName")
                dict.setObject(Constants.loginFields.imageUrl, forKey: "profilePic")
                dict.setObject("Admin", forKey: "userType")
                dict.setObject(newGroupId, forKey: "groupId")
                arr.insertObject(dict, atIndex: i)
                arrAdd.addObject(dict)
            }
            //Storing group users
            let dict1 : NSMutableDictionary = NSMutableDictionary()
            dict1.setObject(arr.objectAtIndex(i).valueForKey("userId")!, forKey: "userId")
            dict1.setObject(arr.objectAtIndex(i).valueForKey("userName")!, forKey: "userName")
            dict1.setObject(arr.objectAtIndex(i).valueForKey("profilePic")!, forKey: "profilePic")
            dict1.setObject(arr.objectAtIndex(i).valueForKey("userType")!, forKey: "userType")
            dict1.setObject(newGroupId, forKey: "groupId")
            arrAdd.addObject(dict1)
            ref.child("groupUsers").childByAutoId().setValue(arrAdd.objectAtIndex(i))
        }
    }
}


extension String{
    
    func whiteSpaceTrimmedString() -> String {
        // remove whitespace character set
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
}
