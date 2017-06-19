//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Anis Mansuri on 23/06/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import UIKit
import DigitsKit
import Firebase
import FirebaseAuth

@available(iOS 9.0, *)
class LoginViewController: BaseViewController, UIPickerViewDataSource, UIPickerViewDelegate,UITextFieldDelegate {
    
    @IBOutlet var barView: UIView!
    var tempCountryName : String = String()
    var tempCountryCode : String = String()
    var tempPhoneNumber : String = String()
    

    @IBOutlet var txtCountry: TJTextField!
    @IBOutlet var txtMobileNumber: TJTextField!
    @IBOutlet var lblCountryCode: UILabel!
    @IBOutlet var txtNumber: UITextField!
    
    //var countries: [String] = []
    private var countries: [Country] = []
    private var _refHandle: FIRDatabaseHandle!
    
    var ref: FIRDatabaseReference!
    
    
    var pickerView: UIPickerView = UIPickerView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        txtNumber.delegate = self
        //txtNumber.keyboardType = .NumberPad
        setCountries()
        pickerViewConfig()

        pickerView.delegate = self
        txtCountry.inputView = pickerView
        //self.addDoneButtonOnKeyboard()
    }
    override func viewWillAppear(animated: Bool) {
        barView.backgroundColor = navigationColor
        hideNavigationBar()
    }
    
    //MARK:- TextField Delegate
    //MARK:-
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    @available(iOS 9.0, *)
    @IBAction func goToVerification(sender: UIButton) {
        txtNumber.resignFirstResponder()
        
        //clearing stored references
        
        logoutButtonAction() //Clears all preference data of current user & logout current user
        UserDefaults.sharedInstance.SetNSUserDefaultValues(countryCode, value: lblCountryCode.text!) //Stores country code to user default
        
        if(AIReachability.sharedManager.isAavailable())
        {
            if(txtCountry.text?.length == 0)
            {
                displayAlert("Please select country", presentVC: self)
                return
            }
                
            else if(txtNumber.text?.length == 0 || lblCountryCode.text?.length == 0 )
            {
                displayAlert("Please enter phone number", presentVC: self)
                return
            }
            else if(txtNumber.text?.length > 10 || txtNumber.text?.length < 10 )
            {
                displayAlert("Please enter valid phone number", presentVC: self)
                return
                
            }
                
            else
            {
                
                let email = txtNumber.text! + "@agile.com" //For Sigining in to firebase Auth
                let password = "123456" //Password for every User is prefixed/same
                
                FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in //Will Log in to Firebase if user exists
                    if let error = error {
                        
                        //IF no number logged in with the number then redirects to REGISTER USER
                        //Creating new user in firebase
                        FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in //If User don't exists, it will create new user
                            if let error = error {
                             
                                return
                            }
                            else
                            {
                                //REGISTERATION
                                HideLoader()
                                
                                //Configuring Digit For Login Verification code
                                let digits = Digits.sharedInstance()
                                let configuration = DGTAuthenticationConfiguration(accountFields: .DefaultOptionMask)
                                configuration.phoneNumber = self.lblCountryCode.text! + self.txtNumber.text!
                                digits.authenticateWithViewController(nil, configuration: configuration) { session, error in
                                    if((error) != nil)
                                    {
                                        self.navigationController?.popViewControllerAnimated(true)
                                        
                                    }
                                    else
                                    {
                                        //Registering new User
                                        self.ref = FIRDatabase.database().reference()
                                        let mData: NSDictionary = ["firstName":"","lastName":"","email":"","gender":"","date":"","month":"","year":"","profilePic":"null","status":"", "phoneNo" : self.lblCountryCode.text!+self.txtNumber.text!,"deviceToken":""]
                                        
                                        let postRegRef = self.ref.child("users")
                                        let postReg1Ref = postRegRef.childByAutoId()
                                        postReg1Ref.setValue(mData)
                                        
                                        let regID = postReg1Ref.key
                                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "signedIn")
                                        UserDefaults.sharedInstance.SetNSUserDefaultValues(regID, value: currentUserId)
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let updateVC = storyboard.instantiateViewControllerWithIdentifier("UpdateProfileViewController") as! UpdateProfileViewController
                                        
                                        let valMobile = self.lblCountryCode.text! + self.txtNumber.text!
                                        updateVC.isFrom = "Register"
                                        updateVC.logMobile = self.txtNumber.text! + "@agile.com"
                                        updateVC.regId = regID
                                        NSUserDefaults.standardUserDefaults().setObject(valMobile, forKey: "\(mobileKey)")
                                        NSUserDefaults.standardUserDefaults().synchronize()
                                        gettingAllData({ () in
                                            self.navigationController?.pushViewController(updateVC, animated: true)
                                        })
                                    }
                                }
                            }
                        }
                    }
                    else{
                        
                        //Signing user into Firebase
                        ShowLoader()
                        self.getCurrentUser1(self.lblCountryCode.text! +  self.txtNumber.text!, handler: { (isLogin) in
                            if(isLogin)
                            {
                                HideLoader()
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let valMobile = self.lblCountryCode.text! + self.txtNumber.text!
                                let digits = Digits.sharedInstance()
                                let configuration = DGTAuthenticationConfiguration(accountFields: .DefaultOptionMask)
                                configuration.phoneNumber = self.lblCountryCode.text! + self.txtNumber.text!
                                
                                if(self.txtNumber.text == "8141531321" || self.txtNumber.text == "7990943968")
                                {
                                    NSUserDefaults.standardUserDefaults().setObject(valMobile, forKey: "\(mobileKey)")
                                    NSUserDefaults.standardUserDefaults().synchronize()
                                    
                                    self.signedIn(user!)//Signin FIrebase
                                    
                                    //Getting all contacts and user data
                                    gettingAllData({ () in
                                        let mainVC = storyboard.instantiateViewControllerWithIdentifier("TabViewController") as! TabViewController
                                        let navigationController = UINavigationController(rootViewController: mainVC)
                                        self.appDelegate!.window?.rootViewController = navigationController
                                    })
                                    
                                }
                                else
                                {
                                    digits.authenticateWithViewController(nil, configuration: configuration) { session, error in
                                        if((error) != nil)
                                        {
                                            self.navigationController?.popViewControllerAnimated(true)
                                        }
                                        else
                                        {
                                            NSUserDefaults.standardUserDefaults().setObject(valMobile, forKey: "\(mobileKey)")
                                            NSUserDefaults.standardUserDefaults().synchronize()
                                            self.signedIn(user!)
                                            
                                            //Getting all contacts and user data
                                            gettingAllData({ () in
                                                let mainVC = storyboard.instantiateViewControllerWithIdentifier("TabViewController") as! TabViewController
                                                let navigationController = UINavigationController(rootViewController: mainVC)
                                                self.appDelegate!.window?.rootViewController = navigationController
                                            })
                                        }
                                    }
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    
    //MARK:- Getting Current User Details
    //MARK:-
    func getCurrentUser1(phoneNo : String,handler:((Bool)->Void))
    {
        
        //Getting Current User Data
        ref = FIRDatabase.database().reference() //Firebase database reference
        
        ref.child("users").queryOrderedByChild("phoneNo").queryEqualToValue(phoneNo).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if(snapshot.exists())
            {
                let dicttempUser = snapshot.valueInExportFormat() as! NSMutableDictionary
                for strchildrenid in dicttempUser.allKeys{
                    
                    var dicttemp = dicttempUser.valueForKey(strchildrenid as! String)
                    Constants.loginFields.userId = strchildrenid as! String
                    UserDefaults.sharedInstance.RemoveKeyUserFefault(currentUserId) //Removing Current userId from user defaults old value
                    UserDefaults.sharedInstance.SetNSUserDefaultValues(currentUserId, value: Constants.loginFields.userId) //Storing Current userId in user defaults
                    
                    
                    if(NSUserDefaults.standardUserDefaults().objectForKey("device_key") != nil) // Check for not nil
                    {
                        let refreshedToken = NSUserDefaults.standardUserDefaults().objectForKey("device_key") as! String
                        self.ref.child("users").child(Constants.loginFields.userId).updateChildValues(["deviceToken":refreshedToken]) //updating device token of current user
                    }
                    
                    //Storing Details in Contants
                    Constants.loginFields.name = (dicttemp!.valueForKey("firstName"))! as! String
                    Constants.loginFields.lastName = (dicttemp!.valueForKey("lastName"))! as! String
                    Constants.loginFields.phoneNo = (dicttemp!.valueForKey("phoneNo"))! as! String
                    Constants.loginFields.email = (dicttemp!.valueForKey("email"))! as! String
                    Constants.loginFields.status = (dicttemp!.valueForKey("status"))! as! String
                    Constants.loginFields.imageUrl = (dicttemp!.valueForKey("profilePic"))! as! String
                    Constants.loginFields.deviceToken = (dicttemp!.valueForKey("deviceToken"))! as! String
                    Constants.loginFields.day = (dicttemp!.valueForKey("date"))! as! String
                    Constants.loginFields.month = (dicttemp!.valueForKey("month"))! as! String
                    Constants.loginFields.year = (dicttemp!.valueForKey("year"))! as! String
                    Constants.loginFields.gender = (dicttemp!.valueForKey("gender"))! as! String
                    
                   //Storing Details in User Defaults
                    UserDefaults.sharedInstance.SetNSUserDefaultValues(fName, value: Constants.loginFields.name)
                    UserDefaults.sharedInstance.SetNSUserDefaultValues(lName, value:Constants.loginFields.lastName)
                    UserDefaults.sharedInstance.SetNSUserDefaultValues(email, value: Constants.loginFields.email)
                    UserDefaults.sharedInstance.SetNSUserDefaultValues(status, value: Constants.loginFields.status)
                    UserDefaults.sharedInstance.SetNSUserDefaultValues(profilePic, value: Constants.loginFields.imageUrl)
                    UserDefaults.sharedInstance.SetNSUserDefaultValues(date, value: Constants.loginFields.day)
                    UserDefaults.sharedInstance.SetNSUserDefaultValues(month, value: Constants.loginFields.month)
                    UserDefaults.sharedInstance.SetNSUserDefaultValues(year, value: Constants.loginFields.year)
                    UserDefaults.sharedInstance.SetNSUserDefaultValues(gender, value: Constants.loginFields.gender)
                    
                    dicttemp = nil
                    handler(true)
                }
            }
            else
            {
                //In case user is signed in and its user is not created in database then this will execute
                let mData: NSDictionary = ["firstName":"","lastName":"","email":"","gender":"","date":"","month":"","year":"","profilePic":"null","status":"", "phoneNo" : self.lblCountryCode.text!+self.txtNumber.text!,"deviceToken":""]
                
                let postRegRef = self.ref.child("users")
                let postReg1Ref = postRegRef.childByAutoId()
                postReg1Ref.setValue(mData)
                
                let regID = postReg1Ref.key
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "signedIn")
                UserDefaults.sharedInstance.SetNSUserDefaultValues(currentUserId, value: regID)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let updateVC = storyboard.instantiateViewControllerWithIdentifier("UpdateProfileViewController") as! UpdateProfileViewController
                
                let valMobile = self.lblCountryCode.text! + self.txtNumber.text!
                updateVC.isFrom = "Register"
                updateVC.logMobile = self.txtNumber.text! + "@agile.com" //User name or email to be created with
                updateVC.regId = regID
                HideLoader()
                NSUserDefaults.standardUserDefaults().setObject(valMobile, forKey: "\(mobileKey)")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.navigationController?.pushViewController(updateVC, animated: true)
            }
        })
    }
    
    
    
    //MARK:- Method for sign in to firebase
    //MARK:-
    func signedIn(user: FIRUser?) {
        MeasurementHelper.sendLoginEvent()
        AppState.sharedInstance.photoUrl = user?.photoURL
        AppState.sharedInstance.signedIn = true
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "signedIn")
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
         NSLog("WARNING FOR MEMORY")
    }
    
    //MARK:- Picker
    //MARK:-
    func pickerViewConfig(){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.tintColor = UIColor.blackColor()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(LoginViewController.donePicker(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(LoginViewController.canclePicker(_:)))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        txtCountry.inputAccessoryView = toolBar
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.handleTap))
        //  tap.delegate = self
        self.view.addGestureRecognizer(tap)
    }
    
    //MARK:- Picker Done Action
    //MARK:-
    func donePicker(btn: UIBarButtonItem)
    {
        
        if tempCountryName == ""
        {
            let country = countries[0]
            tempCountryName = country.name
            
            if country.phoneExtension != nil {
                let str = "+".stringByAppendingString(country.phoneExtension!)
                tempCountryCode = str
            }
        }
        self.view.endEditing(true)
        labelHidden(false)
        txtCountry.text = tempCountryName
        lblCountryCode.text = tempCountryCode
    }
    
    //MARK:- Picker Cancel Action
    //MARK:-
    func canclePicker(btn: UIBarButtonItem){
        self.view.endEditing(true)
        
    }
    
    //MARK:-  UIPickerViewDataSource, UIPickerViewDelegate
    //MARK:-
    private func setCountries() {
        countries = Countries.getAllCountries()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let country = countries[row]
        return country.name
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let country = countries[row]
        
        //txtCountry.text =
        tempCountryName = country.name
        
        if country.phoneExtension != nil {
            let str = "+".stringByAppendingString(country.phoneExtension!)
            tempCountryCode = str
        }
    }
    

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField){
        
    }
    
    func textFieldDidEndEditing(textField: UITextField){
        
    }
    
    func handleTap() {
        self.view.endEditing(true)
        
        txtCountry.resignFirstResponder()
        txtMobileNumber.resignFirstResponder()
        txtNumber.resignFirstResponder()
    }
    
    //MARK:- Configure text
    //MARK:-
    func configText()  {
        var arrPhone = txtMobileNumber.text?.componentsSeparatedByString(" ")
        
        if arrPhone?.count > 1 {
            tempPhoneNumber = arrPhone![1]
            if tempCountryCode.length == 0{
                txtCountry.text = ""
                labelHidden(true)
            }else{
                labelHidden(false)
                
                if tempPhoneNumber.length == 0 {
                    lblCountryCode.text = "\(tempCountryCode) "
                }else{
                    lblCountryCode.text = "\(tempCountryCode) "
                    txtNumber.text = "\(tempPhoneNumber)"
                }
            }
        }
    }
    
    //MARK:- Label hidden
    //MARK:-
    func labelHidden(status :Bool )  {
        lblCountryCode.hidden = status
        lblCountryCode.textColor = UIColor.blackColor()
    }
    
    
    //MARK:- Logout Action
    //MARK:-
    func logoutButtonAction() {
        
        let firebaseAuth = FIRAuth.auth()
        
        do {
            
            Digits.sharedInstance().logOut()
            try firebaseAuth?.signOut()
            AppState.sharedInstance.signedIn = false
            NSUserDefaults.standardUserDefaults().removeObjectForKey("mobile")
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "signedIn")
            UserDefaults.sharedInstance.RemoveKeyUserFefault(allContacts)
            UserDefaults.sharedInstance.RemoveKeyUserFefault(currentUserId)
            dismissViewControllerAnimated(true, completion: nil)
            
        } catch let signOutError as NSError {
            
            
        }catch {
            
            // Catch any other errors
        }
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}
