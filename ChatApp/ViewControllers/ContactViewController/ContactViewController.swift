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
        tblContact.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "contactCell")
        
        txtGroupName.delegate = self
        isSelected = false
        
        if(isComingFrom == "Group") //When it navigates from Create Group
        {
            tblContact.allowsMultipleSelection = true
            lblTitle.text = "Create Group"
            btnDone.setImage(UIImage(named: "done"), for: UIControlState())
            
        }
        else if(isComingFrom == "GroupA") // When it navigates from Add group User
        {
            tblContact.allowsMultipleSelection = true
            lblTitle.text = "Add User"
            btnDone.setImage(UIImage(named: "done"), for: UIControlState())
            
            btnGroupIcon.isHidden = true
            txtGroupName.isHidden = true
            tblContactTopConstraint.constant = 0
            updateViewConstraints()
            
        }
        else if(isComingFrom == "Settings") //When it navigates from the Contacts in settings
        {
            btnGroupIcon.isHidden = true
            txtGroupName.isHidden = true
            tblContactTopConstraint.constant = 0
            self.view.updateConstraints()
            
            lblTitle.text = "Contacts"
            tblContact.allowsMultipleSelection = false
            btnDone.isHidden = true
            tblContact.reloadData()
        }
        else
        {
            tblContact.allowsMultipleSelection = false
            btnDone.setImage(UIImage(named: "search"), for: UIControlState())
        }
        configureStorage()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
       
    }
    
    //MARK:- TextField Delegate
    //MARK:-
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }

    
    //MARK:- Image storage configuration
    //MARK:-
    func configureStorage() {
        storageRef = FIRStorage.storage().reference(forURL: "\(FIREBASE_STORAGE_URL)")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        isSelected = false
        
        if(isComingFrom == "Group")              //When it navigates from Create Group
        {
            tblContact.allowsMultipleSelection = true
            btnDone.setImage(UIImage(named: "done"), for: UIControlState())
        }
        else if(isComingFrom == "GroupA")      // When it navigates from Add group User
        {
            tblContact.allowsMultipleSelection = true
            btnDone.setImage(UIImage(named: "done"), for: UIControlState())
            
            btnGroupIcon.isHidden = true
            txtGroupName.isHidden = true
            tblContactTopConstraint.constant = 0
            updateViewConstraints()
        }
        else if(isComingFrom == "Settings")    // When it navigates from the Contacts in settings

        {
            btnGroupIcon.isHidden = true
            txtGroupName.isHidden = true
            tblContactTopConstraint.constant = 0
            self.view.updateConstraints()
            
            tblContact.allowsMultipleSelection = false
            btnDone.setImage(UIImage(named: "search"), for: UIControlState())
        }
        else
        {
            tblContact.allowsMultipleSelection = false
            btnDone.setImage(UIImage(named: "search"), for: UIControlState())
        }
        configureStorage() //Configures storage for storing in Storage in database
    }
    
    @IBAction func btnBack(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    //MARK:- BUTTON SEARCH CLICK EVENT
    //MARK:-
    
    @IBAction func btnSearch(_ sender: AnyObject) {
        
        if(AIReachability.sharedManager.isAavailable())
        {
            if(isComingFrom == "Group") //Filters the selected contacts for Creating Group
            {
                let data = [Constants.GroupFields.groupName: txtGroupName.text! as String]
                if(txtGroupName.text?.length > 0)
                {
                    
                var indexPathArray : NSArray!
                indexPathArray = self.tblContact.indexPathsForSelectedRows as! NSArray
             if(self.tblContact.indexPathsForSelectedRows?.count > 0 )
              {
                for i in 0..<indexPathArray.count
                 {
                     let index = (indexPathArray.object(at: i) as AnyObject).row
                     let dict : NSMutableDictionary = NSMutableDictionary()
                    dict.setObject(((arrGroupContacts.object(at: index!) as AnyObject).object(forKey: "userId") as? String)!, forKey: "userId" as NSCopying)
                    dict.setObject(((arrGroupContacts.object(at: index!) as AnyObject).object(forKey: "firstName") as? String)!, forKey: "userName" as NSCopying)
                    dict.setObject(((arrGroupContacts.object(at: index!) as AnyObject).object(forKey: "profilePic") as? String)!, forKey: "profilePic" as NSCopying)
                    dict.setObject(((arrGroupContacts.object(at: index!) as AnyObject).object(forKey: "deviceToken") as? String)!, forKey: "deviceToken" as NSCopying)
                    
                     dict.setObject("", forKey: "userType" as NSCopying)
                     arrSelectedContacts.add(dict)
                   }
                
                     ////////
                     let dict1 : NSMutableDictionary = NSMutableDictionary()
                     dict1.setObject(Constants.loginFields.userId, forKey: "userId" as NSCopying)
                     dict1.setObject(Constants.loginFields.name, forKey: "userName" as NSCopying)
                     dict1.setObject(Constants.loginFields.imageUrl, forKey: "profilePic" as NSCopying)
                     dict1.setObject(Constants.loginFields.deviceToken, forKey: "deviceToken" as NSCopying)
                    arrSelectedContacts.add(dict1)
                
                        
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
                indexPathArray = self.tblContact.indexPathsForSelectedRows as! NSArray
                
                if(self.tblContact.indexPathsForSelectedRows?.count > 0 )
                {
                    
                    for i in 0..<indexPathArray.count
                    {
                        
                        let dict : NSMutableDictionary = NSMutableDictionary()
                        let index = (indexPathArray.object(at: i) as AnyObject).row
                        dict.setObject(((arrAddUser.object(at: index!) as AnyObject).object(forKey: "userId") as? String)!, forKey: "userId" as NSCopying)
                        dict.setObject(((arrAddUser.object(at: index!) as AnyObject).object(forKey: "firstName") as? String)!, forKey: "userName" as NSCopying)
                        dict.setObject(((arrAddUser.object(at: index!) as AnyObject).object(forKey: "profilePic") as?  String)!, forKey: "profilePic" as NSCopying)
                       dict.setObject(((arrAddUser.object(at: index!) as AnyObject).object(forKey: "deviceToken") as?  String)!, forKey: "deviceToken" as NSCopying)
                        dict.setObject("", forKey: "userType" as NSCopying)
                        dict.setObject(groupId, forKey: "groupId" as NSCopying)
                        
                        let regextest:NSPredicate = NSPredicate(format: "( userId CONTAINS[C] %@ )", argumentArray: [dict["userId"]!])
                        let arrTemp:NSMutableArray = arrSelectedContacts.mutableCopy() as! NSMutableArray
                        arrTemp.filter(using: regextest)
                        if(arrTemp.firstObject != nil)
                        {
                            
                        }
                        else
                        {
                            arrSelectedContacts.add(dict)
                        }
                    }
                }
                self.addUser(data, arr: arrSelectedContacts)
            }
        }
    }
    
    
    @IBAction func btnGroupIcon(_ sender: UIButton) { //Sets group icon
        
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = .photoLibrary
        } else {
            picker.sourceType = .photoLibrary
        }
        present(picker, animated: true, completion:nil)
    }
    
    //MARK:- View Will Appear
    //MARK:-
    override func viewWillAppear(_ animated: Bool) {
        barView.backgroundColor = navigationColor
        hideNavigationBar()
        
        txtGroupName.autocorrectionType = UITextAutocorrectionType.no
        isSelected = false
        
        if(isComingFrom == "Group")
        {
            tblContact.allowsMultipleSelection = true
            lblTitle.text = "Create Group"
            btnDone.setImage(UIImage(named: "done"), for: UIControlState())
            arrGroupContacts = UserDefaults.sharedInstance.GetArrayFromUserDefault(phoneContacts) // Storing Contacts to arrGroupContact
        }
        else if(isComingFrom == "GroupA")
        {
            btnGroupIcon.isHidden = false
            txtGroupName.isHidden = false
            
            tblContact.allowsMultipleSelection = true
            btnDone.setImage(UIImage(named: "done"), for: UIControlState())
            lblTitle.text = "Add User"
            Timer.scheduledTimer(timeInterval: 0.3, target: self, selector:  #selector(ContactViewController.methodToBeCalled), userInfo: nil, repeats: false)
            
            btnGroupIcon.isHidden = true                        //hidding group icon button
            txtGroupName.isHidden = true                      //hiding group name text field
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
            btnDone.setImage(UIImage(named: "search"), for: UIControlState())
        }

        else
        {
            tblContact.allowsMultipleSelection = false
            btnDone.setImage(UIImage(named: "search"), for: UIControlState())
            arrFilteredContacts.removeAllObjects()
            arrFilteredContacts = UserDefaults.sharedInstance.GetArrayFromUserDefault(allContacts)
        }
    }
    
    // MARK:- TableView DATASOURCE & DELEGATES
    // MARK:-
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
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
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if(isComingFrom == "GroupA")  //When navigates from Add User
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactCell
            cell.selectionStyle = UITableViewCellSelectionStyle.gray
            cell.lblUserName.text = (arrAddUser.object(at: indexPath.row) as AnyObject).object(forKey: "contactName") as? String
            
            if((arrAddUser.object(at: indexPath.row) as AnyObject).object(forKey: "profilePic") as? String != "null")
            {
                let img = (arrAddUser.object(at: indexPath.row) as AnyObject).object(forKey: "profilePic") as? String
                cell.imgViewProfile.sd_setImage(with: URL(string: img!), placeholderImage: UIImage(named: "default_profile"))
            }
            else
            {
                cell.imgViewProfile.image = UIImage(named: "default_profile")
            }
            
            return cell
        }
        else if(isComingFrom == "Group") //When navigates from Create Group
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactCell
            
                cell.lblUserName.text = (arrGroupContacts.object(at: indexPath.row) as AnyObject).object(forKey: "contactName") as? String
                cell.btnInvite.isHidden = true
                if((arrGroupContacts.object(at: indexPath.row) as AnyObject).object(forKey: "profilePic") as? String != "null")
                {
                    let img = (arrGroupContacts.object(at: indexPath.row) as AnyObject).object(forKey: "profilePic") as? String
                    cell.imgViewProfile.sd_setImage(with: URL(string: img!), placeholderImage: UIImage(named: "default_profile"))
                }
                else
                {
                    cell.imgViewProfile.image = UIImage(named: "default_profile")
                }

            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            if(arrFilteredContacts.count > 0)
            {
                if((arrFilteredContacts.object(at: indexPath.row) as AnyObject).value(forKey: "userId") as! String != "")
                {
                    cell.btnInvite.isHidden = true
                    cell.lblUserName.text = (arrFilteredContacts.object(at: indexPath.row) as AnyObject).object(forKey: "contactName") as? String
                    cell.lblStatus.text = (arrFilteredContacts.object(at: indexPath.row) as AnyObject).object(forKey: "status") as? String
                    if((arrFilteredContacts.object(at: indexPath.row) as AnyObject).object(forKey: "profilePic") as? String != "null")
                    {
                        let img = (arrFilteredContacts.object(at: indexPath.row) as AnyObject).object(forKey: "profilePic") as? String
                        cell.imgViewProfile.sd_setImage(with: URL(string: img!),placeholderImage: UIImage(named: "default_profile"))
                    }
                    else
                    {
                        cell.imgViewProfile.image = UIImage(named: "default_profile")
                    }
                    return cell
                }
                else
                {
                    cell.lblUserName.text = (arrFilteredContacts.object(at: indexPath.row) as AnyObject).object(forKey: "contactName") as? String
                    cell.imgViewProfile.image = UIImage(named: "default_profile")
                    cell.lblTime.isHidden = true
                    cell.lblStatus.text = (arrFilteredContacts.object(at: indexPath.row) as AnyObject).value(forKey: "phoneNo") as? String
                    cell.btnInvite.isHidden = true
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    //MARK:- image picker delegate
    //MARK:-
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?)  {
        userPhoto = image
        dismiss(animated: true, completion: nil)
        btnGroupIcon.setImage(userPhoto, for: UIControlState())
        btnGroupIcon.imageView?.contentMode = .scaleAspectFit
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
            if((arrAddGroupContacts.object(at: i) as AnyObject).object(forKey: "userId") as! String != "")
            {
                let dict : NSDictionary = self.arrAddGroupContacts.object(at: i) as! NSDictionary
                
                for j in 0..<self.existingContacts.count  {
                    let dictChild : NSDictionary = self.existingContacts.object(at: j) as! NSDictionary
                    if dict.value(forKey: "userId") as! String == dictChild.value(forKey: "userId") as! String {
                        
                        arrTemp.remove(dict)
                    }
                    else{
                        
                    }
                }
            }
        }
        self.arrAddUser = arrTemp.mutableCopy() as! NSMutableArray
        self.arrAddUser.sortedArray(using: [NSSortDescriptor(key: "contactName", ascending: false)]) as! [[String:AnyObject]]
        HideLoader()
        tblContact.reloadData()
    }
    
    
    //MARK:- ADD GROUP USER
    //MARK:-
    func addUser(_ data: [String: String], arr : NSMutableArray)
    {

        subscribeUser(arr, groupId: groupId) //Subscribe new added user/users
        if(AIReachability.sharedManager.isAavailable()) //Check for Internet Connnection
        {
            //ADD GROUP USERS
            if arr.count > 0
            {
                for i in 0..<arr.count {
                    
                    if((arr.object(at: i) as AnyObject).value(forKey: "userId") as! String != Constants.loginFields.userId)
                    {
                        let dict1 : NSMutableDictionary = NSMutableDictionary()
                        dict1.setObject((arr.object(at: i) as AnyObject).value(forKey: "userId")!, forKey: "userId" as NSCopying)
                        dict1.setObject((arr.object(at: i) as AnyObject).value(forKey: "userName")!, forKey: "userName" as NSCopying)
                        dict1.setObject((arr.object(at: i) as AnyObject).value(forKey: "profilePic")!, forKey: "profilePic" as NSCopying)
                        dict1.setObject((arr.object(at: i) as AnyObject).value(forKey: "userType")!, forKey: "userType" as NSCopying)
                        dict1.setObject((arr.object(at: i) as AnyObject).value(forKey: "groupId")!, forKey: "groupId" as NSCopying)
                        ref.child("groupUsers").childByAutoId().setValue(dict1) // Store added user to database
                    }
                }
                
                //Navigate to tab view controller after Storing new added user to group users
                let tabVC : TabViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabViewController") as! TabViewController
                tabVC.btnGrp = false
                tabVC.btnChat = true
                tabVC.btnContact = false
                Foundation.UserDefaults.standard.set(true, forKey: btnGroup)
                Foundation.UserDefaults.standard.synchronize()
                self.navigationController?.pushViewController(tabVC, animated: true)
            }
        }
    }
    
    
    //MARK:- CREATE GROUP
    //MARK:-
    func createGroup(_ data: [String: String], arr : NSMutableArray)
    {
        ShowLoader()
        var mdata = data
        let date = DateFormatter()
        
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
       
        var newDate = date.string(from: Date())
        newDate = newDate.replacingOccurrences(of: "AM", with: "am")
        newDate = newDate.replacingOccurrences(of: "PM", with: "pm")
        
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
            var data = Data()
            if(self.userPhoto != nil) //if group icon photo is not nil
            {
                
                data = UIImageJPEGRepresentation(self.userPhoto!, 0.8)!
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/jpg"
                
                //Storing image to database storage and then string downloaded URL to variable
                self.storageRef.child(newGroupId).put(data, metadata: metaData){(metaData,error) in
                    if let error = error { //error
                        return
                    }else{
                        //store downloadURL
                        let downloadURL = metaData!.downloadURL()!.absoluteString
                        self.imageURL = downloadURL
                        //SwiftLoader.hide()
                        HideLoader()
                        //Storing downloaded URL in database
                        ref.child("group").child(newGroupId).updateChildValues(["groupIcon" : self.imageURL])
                        
                        self.groupId = newGroupId //storing group ID
                        FIRMessaging.messaging().subscribe(toTopic: self.groupId) //Subscribing to topic for notification
                        
                        //Navigating to Tab View Controller
                        let tabVC : TabViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabViewController") as! TabViewController
                        tabVC.groupId = self.groupId
                        tabVC.btnGrp = true
                        Foundation.UserDefaults.standard.set(true, forKey: btnGroup)
                        Foundation.UserDefaults.standard.synchronize()
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
                    let tabVC : TabViewController = storyboard?.instantiateViewController(withIdentifier: "TabViewController") as! TabViewController
                    tabVC.groupId = self.groupId
                    tabVC.btnGrp = true
                    Foundation.UserDefaults.standard.set(true, forKey: btnGroup)
                    Foundation.UserDefaults.standard.synchronize()
                    self.navigationController?.pushViewController(tabVC, animated: true)
                }
            }
        }
    }
    
    
    //MARK:- Subscribe Group Users
    //MARK:-
    func subscribeUser(_ arrGroupUsers : NSMutableArray, groupId : String)
    {
      
        //Subscribing group users
        for i in 0..<arrGroupUsers.count
        {
            let dict1 : NSMutableDictionary = NSMutableDictionary()
            
            dict1.setObject(groupId, forKey: "topic_key" as NSCopying)
            
            if((arrGroupUsers.object(at: i) as AnyObject).value(forKey: "userId") as! String == Constants.loginFields.userId)
            {
                dict1.setObject(Constants.loginFields.deviceToken, forKey: "device_token" as NSCopying)
            }
            else
            {
                dict1.setObject((arrGroupUsers.object(at: i) as AnyObject).value(forKey: "deviceToken")!, forKey: "device_token" as NSCopying)
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
    func createGroupUsers(_ arr : NSMutableArray, newGroupId : String)
    {
        //CREATE GROUP USERS
        let arrAdd : NSMutableArray = NSMutableArray()
      
        for i in 0..<arr.count {
            
            if((arr.object(at: i) as AnyObject).object(forKey: "userId") as! String == Constants.loginFields.userId) //getting current user detail for storing in group users
            {
                let dict : NSMutableDictionary = NSMutableDictionary()
                dict.setObject(Constants.loginFields.userId, forKey: "userId" as NSCopying)
                dict.setObject(Constants.loginFields.name, forKey: "userName" as NSCopying)
                dict.setObject(Constants.loginFields.imageUrl, forKey: "profilePic" as NSCopying)
                dict.setObject("Admin", forKey: "userType" as NSCopying)
                dict.setObject(newGroupId, forKey: "groupId" as NSCopying)
                arr.insert(dict, at: i)
                arrAdd.add(dict)
            }
            //Storing group users
            let dict1 : NSMutableDictionary = NSMutableDictionary()
            dict1.setObject((arr.object(at: i) as AnyObject).value(forKey: "userId")!, forKey: "userId" as NSCopying)
            dict1.setObject((arr.object(at: i) as AnyObject).value(forKey: "userName")!, forKey: "userName" as NSCopying)
            dict1.setObject((arr.object(at: i) as AnyObject).value(forKey: "profilePic")!, forKey: "profilePic" as NSCopying)
            dict1.setObject((arr.object(at: i) as AnyObject).value(forKey: "userType")!, forKey: "userType" as NSCopying)
            dict1.setObject(newGroupId, forKey: "groupId" as NSCopying)
            arrAdd.add(dict1)
            ref.child("groupUsers").childByAutoId().setValue(arrAdd.object(at: i))
        }
    }
}


extension String{
    
    func whiteSpaceTrimmedString() -> String {
        // remove whitespace character set
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
}
