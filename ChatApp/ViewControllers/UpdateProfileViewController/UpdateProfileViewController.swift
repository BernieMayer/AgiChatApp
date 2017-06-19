         
//
//  UpdateProfileViewController.swift
//  ChatApp
//
//  Created by Anis Mansuri on 24/06/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import UIKit
import Photos
import Firebase
import FirebaseAuth
import FirebaseStorage
import SDWebImage

@available(iOS 9.0, *)
class UpdateProfileViewController: BaseViewController,UIPickerViewDelegate ,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    var userFir : FIRUser!
    
    //editprofile variable
    var userId : String = String()
    var fName : String = String()
    var lName : String = String()
    var email : String = String()
    var status : String = String()
    var gender : String = String()
    var mobile : String = String()
    var imageURL : String = String()
    var day : String = String()
    var month : String = String()
    var year : String = String()
    var isError : Bool = Bool()
    var isErrorFname : Bool = Bool()
    var isErrorLname : Bool = Bool()
    var isErrorEmail : Bool = Bool()
    var isErrorDate : Bool = Bool()
    var isErrorMonth : Bool = Bool()
    var isErrorYear : Bool = Bool()
    var errorMessage : String = String()
    
    
    //Table Header Outlet
    @IBOutlet var tblHeader: UIView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var imageHeight: NSLayoutConstraint!
    @IBOutlet var btnEditProfile: UIButton!
    @IBOutlet var barView: UIView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var btnBack: UIButton!
    
    var datePicker : UIDatePicker = UIDatePicker()

    //FIREBASE STORAGE VARIBLES
    var storageRef: FIRStorageReference!
    
    var arrPlaceHolder : NSMutableArray = NSMutableArray()
    var arrImageName : NSMutableArray = NSMutableArray()
    var isFrom : String = String()
    var logMobile : String = String()
    var regId : String = String()
    var isImageFrom : String = String()
    @IBOutlet var tblUpdateProfile: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        tblHeader.frame.size.height = IMAGE_HEIGHT
        imageHeight.constant = IMAGE_HEIGHT

        configureStorage()
        
        tblUpdateProfile.tableHeaderView = tblHeader
        
        isErrorFname = false
        isErrorLname = false
        isErrorEmail = false
        isErrorDate = false
        isErrorMonth = false
        isErrorYear = false
        isError = false
        
        arrPlaceHolder = NSMutableArray(objects: "First Name","Last Name","E-mail","Status")
        arrImageName = NSMutableArray(objects: "name","name","email","status_Edit")
        
        tblUpdateProfile.registerNib(UINib(nibName: "TableViewCell1", bundle: nil), forCellReuseIdentifier: "cell1")
        tblUpdateProfile.registerNib(UINib(nibName: "TableViewCell2", bundle: nil), forCellReuseIdentifier: "cell2")
        tblUpdateProfile.registerNib(UINib(nibName: "TableViewCell3", bundle: nil), forCellReuseIdentifier: "cell3")
        
        if(isFrom == "Register")
        {
            profileImage.image = UIImage(named: "place_Holder")
        }
        else if (isFrom == "Profile")
        {
            profileImage.sd_setImageWithURL(NSURL(string: imageURL), placeholderImage: UIImage(named: "place_Holder"))
        }
        else
        {
            profileImage.sd_setImageWithURL(NSURL(string: imageURL), placeholderImage: UIImage(named: "place_Holder"))
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
         NSLog("WARNING FOR MEMORY")
    }
    
    
    //MARK:- Image storage configuration
    //MARK:-
    func configureStorage() {
         storageRef = FIRStorage.storage().referenceForURL("\(FIREBASE_STORAGE_URL)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(true)
        mobile = NSUserDefaults.standardUserDefaults().objectForKey(mobileKey) as! String

        if(isFrom == "Profile")
        {
           // btnDone = UIButton()
            self.btnDone.userInteractionEnabled = false
            self.btnDone.hidden = true
            //btnEditProfile = UIButton()
            self.btnEditProfile.userInteractionEnabled = false
            self.btnEditProfile.hidden = true
            self.lblTitle.text = ""
        }
    }
    
    
    //MARK:- TextField Delegate
    //MARK:-
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: - Table View Delegate & DataSource
    //MARK:-
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        tableView.separatorStyle = .None
        let cell : UITableViewCell = UITableViewCell()
        
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 {
            
            let cell1 = tableView.dequeueReusableCellWithIdentifier("cell1") as! TableViewCell1
            cell1.txtUser.placeholder = arrPlaceHolder.objectAtIndex(indexPath.row) as? String
            let imgNmae = arrImageName.objectAtIndex(indexPath.row) as? String
            let img = UIImage(named: imgNmae!)
            cell1.txtUser.txtImage = img
            cell1.txtUser.autocorrectionType = .No
            cell1.txtUser.imageWidth = 20
            cell1.txtUser.leftTextPedding = 10
            cell1.txtUser.tag = indexPath.row
            cell1.txtUser.delegate = self
            if(isFrom == "Profile")
            {
                cell1.txtUser.enabled = false
            }
            
            if indexPath.row == 0{ //First Name
                cell1.txtUser.text = fName
            }else if indexPath.row == 1{ //Last Name
                cell1.txtUser.text = lName
            }else if indexPath.row == 2{ //Email Address
                cell1.txtUser.keyboardType = .EmailAddress
                cell1.txtUser.text = email
            }
            else if indexPath.row == 3{ //Status
                cell1.txtUser.text = status
            }
            
            cell1.txtUser.addTarget(self, action: #selector(UpdateProfileViewController.myTargetEditingDidBeginFunction(_:)), forControlEvents: UIControlEvents.EditingDidBegin)
            cell1.txtUser.addTarget(self, action: #selector(UpdateProfileViewController.myTargetEditingDidEndFunction(_:)), forControlEvents: UIControlEvents.EditingDidEnd)
            
            return cell1
        }
        else if indexPath.row == 4{ //Birth Date
            let cellBday = tableView.dequeueReusableCellWithIdentifier("cell2")! as! TableViewCell2
            cellBday.txtDate.textAlignment = .Justified
            cellBday.txtDate.text = "\(day)/\(month)/\(year)"
            
            if(isFrom == "Register")
            {
                cellBday.txtDate.text = ""
            }
            
            if(isFrom == "Profile")
            {
                cellBday.txtDate.enabled = false
            }
            else
            {
                cellBday.txtDate.tintColor = UIColor.clearColor()
                cellBday.txtDate.autocorrectionType = .No
                cellBday.txtDate.addTarget(self, action: #selector(UpdateProfileViewController.myTargetEditingDidEndFunction(_:)), forControlEvents: UIControlEvents.EditingDidEnd)
                cellBday.txtDate.addTarget(self, action: #selector(UpdateProfileViewController.myTargetEditingDidBeginFunction(_:)), forControlEvents: UIControlEvents.EditingDidBegin)
                cellBday.txtDate.tag = 011
                datePicker.datePickerMode = .Date
                
            }
            
            return cellBday
        }
        else if indexPath.row == 5{ //Gender
            let cell3 = tableView.dequeueReusableCellWithIdentifier("cell3")! as! TableViewCell3
            
            if(isFrom == "Profile")
            {
                cell3.radioMale.userInteractionEnabled = false
                cell3.radioFemale.userInteractionEnabled = false
            }
            
            if(gender.length > 0)
            {
                
                if(gender.lowercaseString == "Male".lowercaseString)
                {
                    cell3.radioMale.selected = true
                    cell3.radioFemale.selected = false
                }
                else
                {
                    cell3.radioFemale.selected = true
                    cell3.radioMale.selected = false
                }
            }else{
                cell3.radioMale.selected = true
                cell3.radioFemale.selected = false
            }
            
            cell3.radioMale.addTarget(self, action: #selector(UpdateProfileViewController.clickGender(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell3.radioFemale.addTarget(self, action: #selector(UpdateProfileViewController.clickGender(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            return cell3
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        switch textField.tag
        {
        case 0:
            
            return (string.componentsSeparatedByCharactersInSet(ACCEPTED_ALPHABATS).count <= 1)
            
        case 1:
            return (string.componentsSeparatedByCharactersInSet(ACCEPTED_ALPHABATS).count <= 1)
            
        case 2:
            email = textField.text!
            return (string.componentsSeparatedByCharactersInSet(ACCEPTED_EMAIL).count <= 1)
            
        case 3:
            status = textField.text!
            
            if range.location == 0 && (string == " ") {
                return false
            }
            
            if range.location >= 255 {
                return false
            }
            
            return true
            
        default: break
            
        }
        return true
    }
    
    
    // MARK: - Navigation
    //MARK:-
    @IBAction func btnBack(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    //MARK:- On Done Click
    //MARK:-
    @IBAction func btnDone(sender: UIButton) {
        self.view.endEditing(true)
      // SwiftLoader.show(title: "Loading...", animated: true)
        //will create new/ recently registered user profile and will log in
        if(AIReachability.sharedManager.isAavailable())
        {
            ShowLoader()
            if(isFrom == "Register")
            {
                if isValidEmail(email) {
                    let password = "123456"         //by default all users password will be 123456 while registering for firebase
                    FIRAuth.auth()?.signInWithEmail(logMobile, password: password) { (user, error) in
                        
                        if user == nil
                        {
                            print(error.debugDescription)
                        }
                        else
                        {
                            self.userFir = user
                            self.updateUserProfile()
                            
                        }
                    }
                }
                else {
                    
                    let alert = UIAlertController(title: "\(appName)", message: "Please enter valid email", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    HideLoader()
                }
            }
             else
            {
                //will update user profile
                if(isValidEmail(email))
                {
                    if(isError == false)
                    {
                        updateUserProfile()
                    }
                    else
                    {
                       let alert = UIAlertController(title: "\(appName)", message: errorMessage   , preferredStyle: UIAlertControllerStyle.Alert)
                       alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                       self.presentViewController(alert, animated: true, completion: nil)
                       HideLoader()
                        
                    }
                }
                else
                {
                    let alert = UIAlertController(title: "\(appName)", message: "Please enter valid email", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    HideLoader()
                }
            }
         }
    }
    
    
    //MARK:-Set Display/User Name
    //MArk:-
    func setDisplayName(user: FIRUser) {
       
        if(AIReachability.sharedManager.isAavailable())
        {
            let changeRequest = user.profileChangeRequest()
            changeRequest.displayName = user.email!.componentsSeparatedByString("@")[0]
            changeRequest.commitChangesWithCompletion(){ (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                self.signedIn(FIRAuth.auth()?.currentUser)
                // Push data to Firebase Database
                let rootRef = FIRDatabase.database().reference()
                
                //will allocate the email to this ID that is just created
                //push data
                if(self.fName.length == 0 || self.lName.length == 0 || self.email.length == 0 || self.day.length == 0 || self.month.length == 0 && self.year.length == 0 || self.gender.length == 0)
                {
                    
                    if(self.gender.length == 0)
                    {
                        self.gender = "Male"
                    }
                    else
                    {
                        let alert : UIAlertController = UIAlertController(title: "\(appName)", message: "Please fill all the details", preferredStyle: UIAlertControllerStyle.Alert)
                        let ok : UIAlertAction = UIAlertAction(title:
                            "Ok", style: .Default, handler: nil)
                        alert.addAction(ok)
                        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
                        
                       HideLoader()
                    }
                }
               
               else if(self.isErrorFname == false && self.isErrorLname == false && self.isErrorEmail == false && self.isErrorDate == false && self.isErrorMonth == false && self.isErrorYear == false)
                {

                    var refreshedToken = ""
                    if let check = NSUserDefaults.standardUserDefaults().objectForKey("device_key"){
                        refreshedToken = check as! String //Stores device token
                  }
                
                    let user: NSDictionary = ["firstName":self.fName,"lastName":self.lName,"email":self.email,"gender":self.gender,"date":self.day,"month":self.month,"year":self.year,"profilePic":self.imageURL,"status":self.status, "phoneNo" : self.mobile, "deviceToken": refreshedToken]
                    
                    
                 rootRef.child("users").child(self.regId).updateChildValues(user as [NSObject : AnyObject])
                    if(self.regId != "" && self.regId != "userId")
                    {
                       let data = ["status":self.status, "userId" : self.regId]
                       ref.child("statuses").childByAutoId().setValue(data)
                    }
                    
                HideLoader()
                getCurrentUser(NSUserDefaults.standardUserDefaults().valueForKey("mobile") as! String, completionHandler: { (isLogin) in
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "signedIn")
                        
                    let tabVC = self.storyboard!.instantiateViewControllerWithIdentifier("TabViewController") as! TabViewController
                        tabVC.mobile = self.mobile
                    let navigationController = UINavigationController(rootViewController: tabVC)
                    self.appDelegate!.window?.rootViewController = navigationController
                    })
                }
                else
                {
                    displayAlert(self.errorMessage, presentVC: self)
                    HideLoader()
                }
            }
        }
    }
    
    //MARK:- Method for sign in
    //MARK:-
    func signedIn(user: FIRUser?) {
        MeasurementHelper.sendLoginEvent()
        
        AppState.sharedInstance.displayName = self.fName //user?.displayName ?? user?.email
        AppState.sharedInstance.photoUrl = user?.photoURL
        AppState.sharedInstance.signedIn = true
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
        //Storing current registered user's Login Details
    }
    
    //MARK:- Did End Editing performs Validation
    //MARK:-
     func myTargetEditingDidEndFunction(textField: TJTextField) {
        
        isError = false
        
        switch textField.tag
        {
        case 0:
            fName = textField.text!
            
            if(fName.length==0)
            {
                textField.errorEntry = true
                textField.errorMessage = "Please Enter First Name."
            }
            else if(fName.length<=3 && fName.length>0)
            {
                textField.errorEntry = true
                textField.errorMessage = "Please Enter atleast 3 character in First Name."
            }
            else
            {
                textField.errorEntry = false
                isErrorFname = false
            }
            break
        case 1:
            lName = textField.text!
            if(lName.length<=0)
            {
                textField.errorEntry = true
                textField.errorMessage = "Please Enter Last Name"
            }
            else if(lName.length<=3 && lName.length>0)
            {
                textField.errorEntry = true
                textField.errorMessage = "Please Enter atleast 3 character in Last Name"
            }
            else
            {
                textField.errorEntry = false
                isErrorLname = false
            }
            break
        case 2:
            email = textField.text!
            if(email.length < 1)
            {
                textField.errorEntry = true
                textField.errorMessage = "Please Enter Email"
                isErrorEmail = true
                errorMessage = textField.errorMessage!
            }
            else if isGivenEmailValidForString(email)
            {
                textField.errorEntry = false
                isErrorEmail = false
            }
            else
            {
                email = ""
                textField.errorEntry = true
                textField.errorMessage = "Please Enter Valid Email"
                isErrorEmail = true
                errorMessage = textField.errorMessage!
                break
            }
            
        case 3:
            status = textField.text!
            if(status.length <= 0)
            {
                textField.errorEntry = true
            }
            else
            {
                textField.errorEntry = false
                isErrorEmail = false
                return
            }
            break
        case 011 :
            break
        default: break
            
        }
    }
    
    //MARK:- On Gender Click 
    //MARK:-
    func clickGender(sender: UIButton)  {
        if sender.tag == 0{               //Male
            gender = "Male"
        }else{                                  //Female
            gender = "Female"
        }
        tblUpdateProfile.reloadRowsAtIndexPaths([NSIndexPath(forRow: 5, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    
    // MARK : TextField Delegate
    //Begin
    func myTargetEditingDidBeginFunction(textField: UITextField) {
        
        switch textField.tag
        {
        case 011 :
          
            self.pickUpDate(textField)
             default: break
        }
    }
    
    
    //MARK:-UIDATEPICKERVIEW METHODS
    //MARK:-
    func pickUpDate(textField : UITextField){
        
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRectMake(0, 0, self.view.frame.size.width, 216))
        self.datePicker.backgroundColor = UIColor.whiteColor()
        self.datePicker.datePickerMode = UIDatePickerMode.Date
        
        
        textField.inputView = self.datePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .Default
        toolBar.barTintColor = navigationColor
        toolBar.translucent = true
        toolBar.tintColor = UIColor.blackColor()//(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(UpdateProfileViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(UpdateProfileViewController.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
    
    
    //MARK:- On Done Click
    //MARK:-
    func doneClick()
    {
        let cellBday: TableViewCell2 = tblUpdateProfile.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0)) as! TableViewCell2
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let date1 = dateFormatter.stringFromDate(datePicker.date)
        let components = NSCalendar.currentCalendar().components([.Day, .Month, .Year], fromDate: dateFormatter.dateFromString(date1)!)
        let day1 = components.day
        let month1 = components.month
        let year1 = components.year
        
        day = String(day1)
        month = String(month1)
        year = String(year1)
        cellBday.txtDate.text = "\(day)/\(month)/\(year)"
        cellBday.txtDate.resignFirstResponder()
    }
    
    
    //MARK:- On Cancel Click
    //MARK:-
    func cancelClick()
    {
        let cellBday: TableViewCell2 = tblUpdateProfile.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0)) as! TableViewCell2
        cellBday.txtDate.resignFirstResponder()
    }
    
    //MARK:- Date Picker Value Changed Date
    //MARK:-
    func datePickerValueChangedDate()
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let cellBday: TableViewCell2 = tblUpdateProfile.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0)) as! TableViewCell2
        cellBday.txtDate.text = ""
        cellBday.txtDate.text = day
    }
    
    //MARK:- Adding button to the picker
    //MARK:-
    func addDoneButtonToPicker()
    {
        let doneButton = UIButton(frame: CGRectMake((self.view.frame.size.width/2) - (100/2), 0, 100, 50))
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.setTitle("Done", forState: UIControlState.Highlighted)
        doneButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        doneButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        
        tblUpdateProfile.addSubview(doneButton) // add Button to UIView
        doneButton.addTarget(self, action: #selector(UpdateProfileViewController.doneClick), forControlEvents: UIControlEvents.TouchUpInside) //
    }
    
    
    @IBAction func editProfile(sender: UIButton) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        // 2
        let viewCon = UIAlertAction(title:"Capture" , style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.openCamera()
            
        })
        let media = UIAlertAction(title: "Pick images", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.openGallery()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        
        // 4
        optionMenu.addAction(viewCon)
        optionMenu.addAction(media)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    //MARK:- Open Camera
    //MARK:-
    func openCamera()
    {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            picker.sourceType = .Camera
        } else {
            picker.sourceType = .PhotoLibrary
        }
        presentViewController(picker, animated: true, completion:nil)

    }
    
    //MARK:- Open Gallery
    //MARK:-
    func openGallery()
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion:nil)
 
    }
    
    
    //MARK:- image picker delegate
    //MARK:-
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?)  {
        
        let userPhoto : UIImageView = UIImageView()
        userPhoto.image = image
        profileImage.image = image
        dismissViewControllerAnimated(true, completion: nil)
        var data = NSData()
        data = UIImageJPEGRepresentation(userPhoto.image!, 0.8)!
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        
        let random0 = arc4random()%10
        let randomcode0 = String(random0)
        
        let random1 = arc4random()%100
        let randomcode1 = String(random1)
        
        let random2 = arc4random()%10
        let randomcode2 = String(random2)
        
        // Upload file and metadata to the object 'images/mountains.jpg'
        ShowLoader()
        let imageRef =  self.storageRef.child(("\(randomcode0)\(randomcode1)\(randomcode2)"))
        imageRef.putData(data, metadata: metaData){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                //SwiftLoader.hide()
                HideLoader()
                return
            }else{
                //store downloadURL
                let downloadURL = metaData!.downloadURL()!.absoluteString
                
                //store downloadURL at database
                self.imageURL = downloadURL!
                Constants.loginFields.imageUrl = self.imageURL
                HideLoader()
            }
        }
    }
    
    //MARK:- UPDATE USER PROFILE
    //MARK:-
    func updateUserProfile()
    {
        HideLoader()
        var errMsg: String = String()
        if(AIReachability.sharedManager.isAavailable())
        {
            isErrorFname = false
            isErrorLname = false
            isErrorEmail = false
            isErrorDate = false
            isErrorMonth = false
            isErrorYear = false
            
            if(fName.length==0)
            {
                errMsg = "Please Enter First Name."
                displayAlert(errMsg, presentVC: self)
                isErrorFname = true
                return
            }
            else if(fName.length<=3 && fName.length>0)
            {
                errMsg = "Please Enter atleast 3 character in First Name."
                displayAlert(errMsg, presentVC: self)
                isErrorFname = true
                return
            }
            else if(lName.length<=0)
            {
                errMsg = "Please Enter Last Name"
                isErrorLname = true
                displayAlert(errMsg, presentVC: self)
                isErrorLname = true
                return
            }
            else if(lName.length<=3 && lName.length>0)
            {
                errMsg = "Please Enter atleast 3 character in Last Name"
                displayAlert(errMsg, presentVC: self)
                isErrorFname = true
                return
            }
            else if(status.length <= 0)
            {
                errMsg = "Please Enter Status"
                displayAlert(errMsg, presentVC: self)
                isErrorFname = true
                return
            }
            else if(day.length<=0)
            {
                isErrorDate = true
                errMsg = "Please Enter Date"
                displayAlert(errMsg, presentVC: self)
                return
            }
            if(month.length <= 0)
            {
                isErrorMonth = true
                errMsg = "Please Enter Month."
                displayAlert(errMsg, presentVC: self)
                return
                
            }
            let valYear : Int = getCurrentYear() - Int(year)!

            if(year.length<=0)
            {
                errMsg = "Please Enter Year."
                isErrorYear = true
                displayAlert(errMsg, presentVC: self)
                return
            }
                
            else if(year.length > 4 || valYear > 100 || Int(year) > getCurrentYear() || year == "0"){
                errMsg = "Please Enter Valid Year."
                displayAlert(errMsg, presentVC: self)
                isErrorYear = true
                return
            }
            else if(valYear < 14 )
            {
                errMsg = "You should atleast 14 years old to use this app."
                displayAlert(errMsg, presentVC: self)
                isErrorYear = true
                return
                
            }
            else
            {
                if(isFrom == "Register")
                {
                    setDisplayName(userFir)
                }
                else
                {
                    self.updateProfile(userId)
                }
            }
        }
    }
    
    
    func updateProfile(userId : String)
    {
        if(self.fName.length == 0 || self.lName.length == 0 || self.email.length == 0 || self.day.length == 0 || self.status.length == 0 || self.month.length == 0 && self.year.length == 0 || self.gender.length == 0)
        {
            if(self.gender.length == 0)
            {
                self.gender = "Male"
                return
            }
            return
        }
        else if(self.isErrorFname == false && self.isErrorLname == false && self.isErrorEmail == false && self.isErrorDate == false && self.isErrorMonth == false && self.isErrorYear == false)
        {
            let userRef = ref.child("users").child(userId)
            if (imageURL.length <= 0)
            {
                imageURL = "null"
            }
            
            let user: NSDictionary = ["firstName":self.fName,"lastName":self.lName,"email":self.email,"profilePic":imageURL,"gender":self.gender,"date":day,"month":month,"year":year,"status":status,"phoneNo" : self.mobile]
            
            userRef.updateChildValues(user as [NSObject : AnyObject])
            Constants.loginFields.name = self.fName
            Constants.loginFields.lastName = self.lName
            Constants.loginFields.email = self.email
            Constants.loginFields.imageUrl = self.imageURL
            Constants.loginFields.gender = self.gender
            Constants.loginFields.day = self.day
            Constants.loginFields.month = self.month
            Constants.loginFields.year = self.year
            Constants.loginFields.status = self.status
            Constants.loginFields.phoneNo = self.mobile
            
            let trimmedString = status.stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            let data = ["status":trimmedString]
            changeStatus(data, data1: trimmedString)
          
            let tabVC : TabViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TabViewController") as! TabViewController
            tabVC.mobile = self.mobile
           HideLoader()
            self.navigationController?.pushViewController(tabVC, animated: true)
        }
        else
        {
            let alert : UIAlertController = UIAlertController(title: appName, message: self.errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
            let ok : UIAlertAction = UIAlertAction(title:
                "Ok", style: .Default, handler: nil)
            alert.addAction(ok)
            self.navigationController?.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}
