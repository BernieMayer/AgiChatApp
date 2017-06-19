
//
//  TabViewController.swift
//  ChatApp
//
//  Created by admin on 12/10/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import UIKit
import Firebase
import Contacts
import ContactsUI
import FirebaseDatabase
import SDWebImage
import DigitsKit
import MessageUI
import GoogleMobileAds
import NVActivityIndicatorView

@available(iOS 9.0, *)
class TabViewController: BaseViewController, UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate, UICollectionViewDataSource, VKSideMenuDelegate, VKSideMenuDataSource, MFMessageComposeViewControllerDelegate, GADBannerViewDelegate {
    
    //AD Variable
    @IBOutlet weak var adBanner: GADBannerView!
    
    //VARIABLES FOR TAB VIEW & VIEW CONTROLLER
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet var indicatorView : UIView!
    @IBOutlet var tabGrp: UICollectionView!
    @IBOutlet var tabChat: UITableView!
    @IBOutlet var tabContact: UITableView!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var btnMenuLeft: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var heightConstraintForBannerView: NSLayoutConstraint!
    
    var scrollactiondisabled : Bool!
    var menuViewHeight : CGFloat = CGFloat()
    var reuseIdentifier = "list"
    
    //Selected tab variables for refreshing table
    var btnGrp : Bool = Bool()
    var btnChat : Bool = Bool()
    var btnContact : Bool = Bool()
    var count : Bool = Bool()
    
     var isFirsttmeContact: Bool = true
    
    //VARIABLE FOR GROUP
    var arrGetGroups : NSMutableArray!
    var arrGroups : NSMutableArray!
    var arrGroupIds : NSMutableArray!
    var isFirsttmeGroup: Bool = true
    
    //Getting User Contact Variables
    var arrFilteredContacts : NSMutableArray!
    var arrInviteContacts : NSMutableArray!
    var arrRecentFilteredContacts : NSMutableArray!
    
    var mobile : String = String()
    var imageProPic : UIImageView = UIImageView()
    
    //Refresh Control Variable
    //var refreshControl:UIRefreshControl = UIRefreshControl()
    
    //Recent Chat Variables
    var isRecentFirsttme: Bool = true
    var myKey : String = String()
    var key : String = String()
    var arrRecentUser : NSMutableArray!
    var recentUserName : NSMutableArray = NSMutableArray()
    
    //Left Menu Varibles
    var menuItems: [AnyObject] = ["Profile" ,"Settings","About Us"]
    var menuImageNames : [AnyObject] = ["name","setting","about_us"]
    var menuLeft : VKSideMenu = VKSideMenu()
    
    //Group Chat Variables
    var groupId : String = String()
    var flag  : Bool = false
    var arrMemeberGrouplist :[String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //clear notifications and set badge to 0
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        //setting up Ad
        adBanner.adUnitID = unitIdForAd
        adBanner.rootViewController = self
        adBanner.loadRequest(GADRequest())
        adBanner.delegate = self
        
        
        self.arrRecentUser = NSMutableArray()                   //Stores recent users
        arrInviteContacts = NSMutableArray()                     //Stores arrays of Invite Contacts
        arrFilteredContacts = NSMutableArray()                 //Stores Filtered Contacts
        arrRecentFilteredContacts = NSMutableArray()     //Stores Recent Filtered Contacts
        arrGroupIds = NSMutableArray()                            //Stores array of group Ids
        arrGetGroups = NSMutableArray()                         //Stores array of Fetched Groups
        arrGroups = NSMutableArray()                               //Stores Groups
        scrollactiondisabled = Bool()
        
        btnGrp = false
        btnChat = true
        btnContact = false
        isFirsttmeGroup = true
        
        menuLeft = VKSideMenu(width: MAIN_WIDTH/3, andDirection: VKSideMenuDirection.LeftToRight)
        menuLeft.dataSource = self
        menuLeft.delegate  = self
        
        //will store current user mobile number
        mobile = NSUserDefaults.standardUserDefaults().objectForKey(mobileKey) as! String
        
        menuViewHeight = 40
        createTabTables()
        
        isRecentFirsttme = true
        
        btnChat = true
        tabChat.separatorColor = UIColor.clearColor()
        tabContact.separatorColor = UIColor.clearColor()
        
        self.arrFilteredContacts = UserDefaults.sharedInstance.GetArrayFromUserDefault(allContacts)
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        ref = FIRDatabase.database().reference()
        isFirsttmeContact = true
        
        if(NSUserDefaults.standardUserDefaults().boolForKey(btnGroup) == true)
        {
            contentScrollView.setContentOffset(CGPointMake(0, contentScrollView .contentOffset.y), animated: true)
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: btnGroup)
            if self.isFirsttmeGroup {
                arrGroups.removeAllObjects()
                arrGetGroups.removeAllObjects()
                self.isFirsttmeGroup = false
                shwGrp()
            }
        }
        else{
            loadChats()
            if self.isFirsttmeGroup {
                arrGroups.removeAllObjects()
                arrGetGroups.removeAllObjects()
                self.isFirsttmeGroup = false
                shwGrp()
            }
        }
    }
    
    
    //MARK:- Ads DELEGATE METHODS
    //MARK:- ______________________
    
    //MARK:- FAILED TO RECEIVE ADs
    //MARK:-
    func adView(bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        
        print("ERROR IS :- \(error)")
        print(GADErrorCode)
    }
    
    
    //MARK:- RECEIVED ADs
    //MARK:-
    func adViewDidReceiveAd(bannerView: GADBannerView) {
        
        print("______________AD RECEIVED______________")
    }
    
    //MARK:- TOUCHES BEGAN
    //MARK:-
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.menuLeft.hide()
    }
    
    
    //MARK:- ON LEFT MENU CLICK
    //MARK:-
    @IBAction func btnMenuLeftClick(sender: UIButton) {
        
        self.menuLeft.show()
    }
    
    
    //MARK:- CREATE TABLES
    //MARK:-
    func createTabTables()  {
        //Creates tables
        
        let arrBtn = ["Groups","Chat","Contacts"]
        self.createMenuWithButtonTitles(arrBtn)
        contentScrollView.frame = CGRectMake(0, 140,MAIN_WIDTH, MAIN_HEIGHT-64)
        contentScrollView.contentSize = CGSizeMake(3*contentScrollView.frame.size.width, 0)
        contentScrollView.delegate = self
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.pagingEnabled = true
        contentScrollView.scrollsToTop = false
        
        //tabGrp is collection View
        tabGrp = self.createCollectionViewWithFrame(CGRectMake(0, 15, MAIN_WIDTH, contentScrollView.frame.size.height-menuViewHeight-40))
        
        //tabChat frame(tableView)
        tabChat = self.createTableView(withFrame: CGRect(x: MAIN_WIDTH , y: 15, width: MAIN_WIDTH, height: contentScrollView.frame.size.height-70))
        //tabcontact frame(tableview)
        tabContact = self.createTableView(withFrame: CGRect(x: MAIN_WIDTH * 2, y: 15, width: MAIN_WIDTH, height: contentScrollView.frame.size.height-70))
        
        contentScrollView.setContentOffset(CGPointMake(MAIN_WIDTH, contentScrollView .contentOffset.y), animated: true)//Scroll Offset
    }
    
    
    //MARK:- Use for size
    //MARK:-
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if (reuseIdentifier == "list"){
            return CGSizeMake(MAIN_SCREEN.bounds.width, 100)
        }else{
            return CGSizeMake(100, 140)
        }
    }
    
    
    //MARK:- Use for interspacing
    //MARK:-
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    
    func collectionView(collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    
    //MARK:- Function For Create UICollectionView
    //MARK:-
    func createCollectionViewWithFrame(frame: CGRect) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        tabGrp = UICollectionView(frame: frame, collectionViewLayout: layout)
        tabGrp.dataSource = self
        tabGrp.delegate = self
        tabGrp.backgroundColor = UIColor.whiteColor()
        
        contentScrollView.addSubview(tabGrp)
        
        //Register Collectionview cell
        tabGrp.registerNib(UINib(nibName: "ChatRowCustomCell", bundle: nil), forCellWithReuseIdentifier: "list")
        return tabGrp
    }
    
    
    //MARK:- Function For Setting up UITableView
    //MARK:-
    func createTableView(withFrame frame: CGRect) -> UITableView {
        //Setting up Table View
        let tableView : UITableView = UITableView(frame: frame, style: .Plain)
        tableView.dataSource = self
        tableView.delegate = self
        contentScrollView.addSubview(tableView)
        //Register Table Nib
        tableView.registerNib(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "contactCell")
        tableView.registerNib(UINib(nibName: "SingleChatCell", bundle: nil), forCellReuseIdentifier: "SingleChatCell")
        return tableView
    }
    
    
    //MARK:- creating menu with button title
    //MARK:-
    func createMenuWithButtonTitles(arrBtn : NSArray)
    {
        let menuview = UIView(frame:  CGRectMake(0, 64, MAIN_WIDTH, menuViewHeight))
        menuview.backgroundColor = ColorCode(143, green: 68, blue: 173, alpha: 1)
        self.view.addSubview(menuview)
        indicatorView = UIView(frame: CGRectMake(0, menuview.frame.size.height - 2, MAIN_WIDTH / CGFloat(arrBtn.count), 2))
        indicatorView.backgroundColor = UIColor.whiteColor()
        menuview.addSubview(indicatorView)
        
        for i in 0..<arrBtn.count {
            
            var btn: UIButton!
            if i == 0 {
                let valueOfX = (MAIN_WIDTH / CGFloat(arrBtn.count)) * CGFloat(i)
                
                btn = self.createMenuwithTitle(arrBtn[i] as! String, andFrame: CGRect(x: valueOfX, y: 0, width: MAIN_WIDTH / CGFloat(arrBtn.count), height: menuViewHeight), TitleColor: UIColor.whiteColor(), action: #selector(btnAction(_:)), withTag: i)
            }
            if i == 1
            {
                let valueOfX = (MAIN_WIDTH / CGFloat(arrBtn.count)) * CGFloat(i)
                
                btn = self.createMenuwithTitle(arrBtn[i] as! String, andFrame: CGRect(x: valueOfX, y: 0, width: MAIN_WIDTH / CGFloat(arrBtn.count), height: menuViewHeight), TitleColor: UIColor.whiteColor(), action: #selector(btnAction(_:)), withTag: i)
            }
            else {
                let valueOfX = (MAIN_WIDTH / CGFloat(arrBtn.count)) * CGFloat(i)
                
                btn = self.createMenuwithTitle(arrBtn[i] as! String, andFrame: CGRect(x: valueOfX, y: 0, width: MAIN_WIDTH / CGFloat(arrBtn.count), height: menuViewHeight), TitleColor: UIColor.whiteColor(), action: #selector(btnAction(_:)), withTag: i)
            }
            menuview.addSubview(btn)
        }
    }
    
    
    //MARK: - Scrollview delegate
    //MARK:-
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == tabChat || scrollView == tabContact {
            return
        }
        if scrollactiondisabled == true {
            return
        }
        var x: CGFloat = scrollView.contentOffset.x
        x = x / MAIN_WIDTH
        
        for view: UIView in self.view!.subviews {
            for object: AnyObject in view.subviews {
                if (object is UIButton) {
                    let btnOthers = (object as! UIButton)
            
                    if x == CGFloat(btnOthers.tag) {
                        btnOthers.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                        UIView.animateWithDuration(0.25, animations: {() -> Void in
                            self.indicatorView.frame = CGRectMake(btnOthers.frame.size.width * x, self.indicatorView.frame.origin.y, self.indicatorView.frame.size.width, self.indicatorView.frame.size.height)
                            if(x==0)
                            {
                                self.btnGrp = true
                                self.btnContact = false
                                self.btnChat = false
                                self.btnRight.setImage(UIImage(named: "ic_group"), forState: .Normal)
                            }
                            else if(x==1)
                            {
                                self.btnChat = true
                                self.btnGrp = false
                                self.btnContact = false
                                self.btnRight.setImage(UIImage(named: ""), forState: .Normal)
                                self.btnChatClick()
                            }
                            else
                            {
                                self.btnContact = true
                                self.btnChat = false
                                self.btnGrp = false
                                self.btnRight.setImage(UIImage(named: "ic_refresh"), forState: UIControlState.Normal)
                                self.btnContactClick()
                            }
                        })
                    }
                    else {
                        btnOthers.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    }
                }
            }
        }
    }
    
    
    //MARK:- VKSideMenu Delegate and Datasource
    //MARK:-
    func numberOfSectionsInSideMenu(sideMenu: VKSideMenu) -> Int {
        
        return 1
    }
    
    
    func sideMenu(sideMenu: VKSideMenu, numberOfRowsInSection section: Int) -> Int {
        
        return menuItems.count
    }
    
    
    func sideMenu(sideMenu: VKSideMenu, itemForRowAtIndexPath indexPath: NSIndexPath) -> VKSideMenuItem {
        let item: VKSideMenuItem = VKSideMenuItem()
        item.title = menuItems[indexPath.row] as? String
        let imgName = menuImageNames[indexPath.row] as? String
        item.icon = UIImage(named: imgName!)
        return item
    }
    
    
    func sideMenu(sideMenu: VKSideMenu, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if indexPath.row == 0 {
            ShowLoader()
            let profileVC = storyboard.instantiateViewControllerWithIdentifier("UpdateProfileViewController") as! UpdateProfileViewController
            profileVC.isFrom = "Profile"
            profileVC.userId = Constants.loginFields.userId//UserDefaults.sharedInstance.GetNSUserDefaultValue(currentUserId) //Constants.loginFields.userId
            profileVC.fName = Constants.loginFields.name
            profileVC.lName = Constants.loginFields.lastName
            profileVC.email = Constants.loginFields.email
            profileVC.status = Constants.loginFields.status
            profileVC.day = Constants.loginFields.day
            profileVC.month = Constants.loginFields.month
            profileVC.year = Constants.loginFields.year
            profileVC.gender = Constants.loginFields.gender
            profileVC.imageURL = Constants.loginFields.imageUrl
            
            //SwiftLoader.hide()
            HideLoader()
            self.navigationController?.pushViewController(profileVC, animated: true)
            
        }  else if indexPath.row == 1 {
            //GO TO SETTINGS
            ShowLoader()
            let settingsVC = storyboard.instantiateViewControllerWithIdentifier("SettingViewController") as! SettingViewController
            HideLoader()
            self.navigationController?.pushViewController(settingsVC, animated: true)
            
        }else if indexPath.row == 2 {
            //GO TO ABOUT US
            displayAlert("This feature will be available in next version", presentVC: self)
        }
    }
    
    //MARK:- Logout Action
    //MARK:-
    func logoutButtonAction() {
        let firebaseAuth = FIRAuth.auth()
        do {
            Digits.sharedInstance().logOut() //Logging out from digit
            try firebaseAuth?.signOut() //logging  out from firebase
            AppState.sharedInstance.signedIn = false
            
            //Setting current user status to offline on logout
            let presenceRef = FIRDatabase.database().referenceWithPath("activeStatus").child(Constants.loginFields.userId).child("isOnline");
            presenceRef.onDisconnectSetValue("false")
            
            //Navigate to login view controller
            let loginVC : LoginViewController = storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            let navigationController : UINavigationController = UINavigationController(rootViewController: loginVC)
            
            self.appDelegate?.window?.rootViewController = navigationController
            //Clearing preferences
            NSUserDefaults.standardUserDefaults().removeObjectForKey("mobile")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("device_key")
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "signedIn")
            UserDefaults.sharedInstance.RemoveKeyUserFefault(currentUserId)
            UserDefaults.sharedInstance.RemoveKeyUserFefault(phoneContacts)
            dismissViewControllerAnimated(true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        }catch {
            // Catch any other errors
        }
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    //MARK:- Fuction For Create Button
    //MARK:-
    func createMenuwithTitle(title: String, andFrame frame: CGRect, TitleColor titleColor: UIColor, action target: Selector, withTag tag: Int) -> UIButton {
        let btn = UIButton(type: .Custom)
        btn.frame = frame
        btn.tag = tag
        btn.setTitle(title, forState: .Normal)
        btn.setTitleColor(titleColor, forState: .Normal)
        btn.addTarget(self, action: target, forControlEvents: .TouchUpInside)
        return btn
    }
    
    
    //MARK:- TABLEVIEW DATASOURCE & DELEGATE
    //MARK:-
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(tableView == tabContact)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath) as! ContactCell
            if(btnContact == true)
            {
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.btnInvite.hidden = true
                if(arrFilteredContacts.count > 0)
                {
                    if(arrFilteredContacts.objectAtIndex(indexPath.row).valueForKey("userId") as! String != "")
                    {
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
                        cell.btnInvite.hidden = false
                        cell.btnInvite.tag = indexPath.row
                        cell.btnInvite.addTarget(self, action: #selector(onInviteButtonClick(_:)), forControlEvents: .TouchUpInside)
                        return cell
                    }
                }
                else
                {
                    return UITableViewCell()
                }
            }
            return cell
        }
        else if(btnChat == true)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("SingleChatCell", forIndexPath: indexPath) as! SingleChatCell
            
            if(arrRecentFilteredContacts.count > 0){
                
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.lblUserName.text = self.arrRecentFilteredContacts.objectAtIndex(indexPath.row).valueForKey("contactName") as? String
                //cell.btnInvite.hidden = true
                if((arrRecentFilteredContacts.objectAtIndex(indexPath.row).objectForKey("profilePic") as! String) != "null")
                {
                    let img = (arrRecentFilteredContacts.objectAtIndex(indexPath.row).objectForKey("profilePic") as! String)
                    cell.imgViewProfile.sd_setImageWithURL(NSURL(string: img),placeholderImage: UIImage(named:"default_profile"))
                }
                else
                {
                    cell.imgViewProfile.image = UIImage(named: "default_profile")
                }
                
                cell.lblStatus.text = self.arrRecentFilteredContacts.objectAtIndex(indexPath.row).valueForKey("lastMessage") as? String
                cell.lblTime.text = convertDate((self.arrRecentFilteredContacts.objectAtIndex(indexPath.row).valueForKey("timeStamp") as? String)!)
            }
            
            return cell
        }
            
        else
        {
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        
        if(tableView == tabContact)
        {
            if(btnContact == true)
            {
                if(arrFilteredContacts.count == 0)
                {
                    return 0
                }
                else
                {
                    return arrFilteredContacts.count
                }
                
            }
            return arrFilteredContacts.count
        }
        else
        {
            if arrRecentFilteredContacts.count <= 0 {
                return 0
            }
            else {
                return arrRecentFilteredContacts.count
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(AIReachability.sharedManager.isAavailable())
        {
            let jsqChatVC : ChatViewController = storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
            
            if(btnContact == true)
            {
                if(arrFilteredContacts.objectAtIndex(indexPath.row).valueForKey("userId") as! String != "")
                {
                    jsqChatVC.userName = (arrFilteredContacts.objectAtIndex(indexPath.row).objectForKey("contactName") as? String)!
                    jsqChatVC.userId = (arrFilteredContacts.objectAtIndex(indexPath.row).objectForKey("userId") as? String)!
                    jsqChatVC.getID = Constants.loginFields.userId
                    jsqChatVC.deviceToken = (arrFilteredContacts.objectAtIndex(indexPath.row).objectForKey("deviceToken") as? String)!
                    
                    if(arrFilteredContacts.objectAtIndex(indexPath.row).objectForKey("profilePic") as? String != "null")
                    {
                        let img = arrFilteredContacts.objectAtIndex(indexPath.row).objectForKey("profilePic") as? String
                        jsqChatVC.proPic.sd_setImageWithURL(NSURL(string: img!),placeholderImage: UIImage(named: "default_profile"))
                    }
                    else
                    {
                        jsqChatVC.proPic.image = UIImage(named: "default_profile")
                    }
                    jsqChatVC.isExistingGroup = false
                    jsqChatVC.isGroupChat = false
                    self.navigationController?.pushViewController(jsqChatVC, animated: true)
                }
                else
                {
                    self.sendInviteMessage(arrFilteredContacts.objectAtIndex(indexPath.row).valueForKey("phoneNo") as! String)
                }
                
            }
            else if(btnChat == true)
            {
                jsqChatVC.userName = (arrRecentFilteredContacts.objectAtIndex(indexPath.row).objectForKey("contactName") as! String)
                jsqChatVC.userId = (self.arrRecentFilteredContacts.objectAtIndex(indexPath.row).objectForKey("recentUserId") as? String)!
                jsqChatVC.getID = Constants.loginFields.userId
                
                jsqChatVC.deviceToken = (arrRecentFilteredContacts.objectAtIndex(indexPath.row).objectForKey("deviceToken") as? String)!
                
                if(arrRecentFilteredContacts!.objectAtIndex(indexPath.row).objectForKey("profilePic") as! String != "null")
                {
                    let img = (arrRecentFilteredContacts.objectAtIndex(indexPath.row).objectForKey("profilePic") as! String)
                    jsqChatVC.proPic.sd_setImageWithURL(NSURL(string: img),placeholderImage: UIImage(named:"default_profile"))
                }
                else
                {
                    jsqChatVC.proPic.image = UIImage(named: "default_profile")
                }
                jsqChatVC.isExistingGroup = false
                jsqChatVC.isGroupChat = false
                self.navigationController?.pushViewController(jsqChatVC, animated: true)
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    
    // MARK: - CollectionView Methods
    //MARK:-
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(arrGroups.count<=0)
        {
            return 0
        }
        else
        {
            return arrGroups.count
            
        }
    }
    
    // make a cell for each cell index path
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ChatRowCustomCell
        
        if(arrGroups.count > 0)
        {
            cell.lblUserName.text = arrGroups.objectAtIndex(indexPath.row).objectForKey("groupName") as? String
            var lastMessage : String = String()
            
            if(arrGroups.objectAtIndex(indexPath.row).objectForKey("lastMessage") as! String == "")
            {
                if(arrGroups.objectAtIndex(indexPath.row).valueForKey("userId") as! String == UserDefaults.sharedInstance.GetNSUserDefaultValue(currentUserId))
                {
                    lastMessage = "You created group"
                }
                else
                {
                    lastMessage = "\(arrGroups.objectAtIndex(indexPath.row).objectForKey("userName") as! String) created group"
                }
                
            }
            else
            {
                if(arrGroups.objectAtIndex(indexPath.row).valueForKey("userId") as! String == UserDefaults.sharedInstance.GetNSUserDefaultValue(currentUserId))
                {
                    lastMessage = "You: \(arrGroups.objectAtIndex(indexPath.row).objectForKey("lastMessage") as! String)"
                }
                else
                {
                    lastMessage = "\(arrGroups.objectAtIndex(indexPath.row).objectForKey("userName") as! String): \(arrGroups.objectAtIndex(indexPath.row).objectForKey("lastMessage") as! String)"
                }
            }
            
            cell.lblStatus.text = lastMessage
            cell.lblTime.text = convertDate((self.arrGroups.objectAtIndex(indexPath.row).valueForKey("timeStamp") as? String)!)
            if(arrGroups.objectAtIndex(indexPath.row).objectForKey("groupIcon") as? String != "null")
            {
                let img = arrGroups.objectAtIndex(indexPath.row).objectForKey("groupIcon") as? String
                cell.imgViewProfile.sd_setImageWithURL(NSURL(string: img!),placeholderImage: UIImage(named: "grp_icon"))
            }
            else
            {
                cell.imgViewProfile.image = UIImage(named: "grp_icon")
                cell.imgViewProfile.backgroundColor = UIColor.clearColor()
            }
            
            cell.lblMsgCount.hidden = true
            
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if(AIReachability.sharedManager.isAavailable())
        {
            if arrGroups.count > 0
            {
                let jsqChatVC : ChatViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
                if(self.arrGroups.count>0)
                {
                    jsqChatVC.groupName = self.arrGroups.objectAtIndex(indexPath.row).objectForKey("groupName") as! String
                    jsqChatVC.groupId = self.arrGroups.objectAtIndex(indexPath.row).objectForKey("Id") as! String
                    jsqChatVC.getID = Constants.loginFields.userId
                    jsqChatVC.isGroupChat = true
                    jsqChatVC.groupName = (self.arrGroups.objectAtIndex(indexPath.row).objectForKey("groupName") as? String)!
                    jsqChatVC.isGroupChat = true
                    jsqChatVC.isExistingGroup = true
                    if(self.arrGroups.objectAtIndex(indexPath.row).objectForKey("groupIcon") as? String != "null")
                    {
                        let img = self.arrGroups.objectAtIndex(indexPath.row).objectForKey("groupIcon") as? String
                        jsqChatVC.groupIcon.sd_setImageWithURL(NSURL(string: img!),placeholderImage: UIImage(named: "grp_icon"))
                    }
                    else
                    {
                        jsqChatVC.groupIcon.image = UIImage(named: "grp_icon")
                    }
                    self.navigationController?.pushViewController(jsqChatVC, animated: true)
                }
            }
        }
    }
    
    
    //////-----Menu Button Actions-----////
    // MARK: -
    // MARK: - Menu Tap Action
    @IBAction func btnAction(sender: AnyObject) {
        let btn = (sender as! UIButton)
        if contentScrollView.contentOffset.x == (MAIN_WIDTH * CGFloat(btn.tag)) {
            return
        }
        scrollactiondisabled = true
        contentScrollView.setContentOffset(CGPoint(x: MAIN_WIDTH * CGFloat(btn.tag), y: contentScrollView.contentOffset.y), animated: true)
        scrollactiondisabled = false
        
        for view: UIView in self.view.subviews {
            for object: Any in view.subviews {
                if (object is UIButton) {
                    let btnOthers = (object as! UIButton)
                    if btn.tag == btnOthers.tag {
                        btnOthers.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                        UIView.animateWithDuration(0.25, animations: {
                            self.indicatorView.frame = CGRectMake(btn.frame.size.width * CGFloat(btn.tag), self.indicatorView.frame.origin.y, self.indicatorView.frame.size.width, self.indicatorView.frame.size.height)
                            
                            if(btn.tag == 0)
                            {
                                self.btnRight.setImage(UIImage(named: "code_selected"), forState: .Normal)
                                self.btnTabClick()
                            }
                            else if(btn.tag == 1)
                            {
                                self.btnRight.setImage(UIImage(named: ""), forState: .Normal)
                                self.btnContact = false
                                self.btnChat = true
                                self.btnChatClick()
                            }
                            else
                            {
                                self.btnRight.setImage(UIImage(named: "ic_refresh"), forState: UIControlState.Normal)
                                self.btnContact = true
                            }
                        })
                    }
                    else {
                        btnOthers.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    }
                }
            }
        }
    }
    
    
    //MARK:- On Tab Clicks
    //MARK:-
    
    //MARK:- On Button Group Click
    //MARK:-
    func btnTabClick() {
        
        btnGrp = true
        btnContact = false
        btnChat = false
        tabGrp.reloadData()
    }
    
    
    //MARK:- On Button Chat Click
    //MARK:-
    func btnChatClick()
    {
        btnGrp = false
        btnContact = false
        btnChat = true
        //isRecentFirsttme = true
        
        if self.isRecentFirsttme {
            arrRecentFilteredContacts.removeAllObjects()
            self.isRecentFirsttme = false
            gettingRecentChat()
        }
        else
        {
            tabChat.reloadData()
        }
    }
    
    //MARK:- On Button Chat Click
    //MARK:-
    
    
    func btnContactClick()  {
        
        btnGrp = false
        btnContact = true
        btnChat = false
        //reload table contact
        tabContact.reloadData()
    }
    
    //MARK:- Right Bar Button Click
    //MARK:-
    @IBAction func btnRightClick(sender: UIButton) {
        
        if(AIReachability.sharedManager.isAavailable())
        {
            if(btnGrp == true)
            {
                let contactVC = storyboard?.instantiateViewControllerWithIdentifier("ContactViewController") as! ContactViewController
                contactVC.isComingFrom = "Group"
                self.navigationController?.pushViewController(contactVC, animated: true)
                
            }
            else if(btnContact == true)
            {
                gettingAllData({ () in
                    self.arrFilteredContacts.removeAllObjects() //= NSMutableArray()
                    self.arrFilteredContacts = UserDefaults.sharedInstance.GetArrayFromUserDefault(allContacts)
                    self.tabContact.reloadData()
                })
                
            }
        }
    }
    
    
    //MARK:- DIsplay Groups list
    //MARK:-
    func shwGrp()
    {
        ShowLoader()
        ref = FIRDatabase.database().reference()
        arrGroupIds.removeAllObjects()
        let uId = UserDefaults.sharedInstance.GetNSUserDefaultValue(currentUserId)
        let refGrp = ref.child("groupUsers").queryOrderedByChild("userId").queryEqualToValue(uId)
        
        refGrp.observeEventType(.Value, withBlock: { (snapshot) in
            
            if(snapshot.exists())
            {
                SwiftLoader.hide()
                let dicttempUser = snapshot.valueInExportFormat() as! NSMutableDictionary
                
                for strchildrenid in dicttempUser.allKeys{
                    
                    let dict: NSMutableDictionary = NSMutableDictionary()
                    let dicttemp = dicttempUser.valueForKey(strchildrenid as! String)
                    
                    dict.setObject((dicttemp?.valueForKey("groupId"))!, forKey: "groupId")
                    self.arrGroupIds.addObject(dict)
                    self.UpdateAndSortGroupArrayThanReloadTable()
                }
                
            }
            else
            {
                HideLoader()
            }
            HideLoader()
            self.getGroups(self.arrGroupIds, completionHandler: { () in
                self.UpdateAndSortGroupArrayThanReloadTable()
            })
            HideLoader()
        })
    }
    
    //MARK:- Get user group
    //MARK:-
    
    func getGroups(arrGetGrps : NSMutableArray,completionHandler : (Void) -> Void)
    {
        ref = FIRDatabase.database().reference()
        ShowLoader()
        
        for i in 0..<arrGetGrps.count {
            
            let groupId1 = arrGetGrps.objectAtIndex(i).valueForKey("groupId") as! String
            let ref1 = ref.child("group").child("\(groupId1)")
            ref1.observeEventType(.Value, withBlock: { (snapshot) in
            
            if(snapshot.exists())
             {
                    let dicttempUser = snapshot.valueInExportFormat() as! NSMutableDictionary
                    let dict: NSMutableDictionary = NSMutableDictionary()
                    dict.setObject(groupId1 , forKey: "Id")
                    dict.setObject((dicttempUser.valueForKey("groupName"))!, forKey: "groupName")
                    dict.setObject((dicttempUser.valueForKey("lastMessage"))!, forKey: "lastMessage")
                    dict.setObject((dicttempUser.valueForKey("userId"))!, forKey: "userId")
                    dict.setObject((dicttempUser.valueForKey("userName"))!, forKey: "userName")
                    dict.setObject((dicttempUser.valueForKey("timeStamp"))!, forKey: "timeStamp")
                    dict.setObject((dicttempUser.valueForKey("groupIcon"))!, forKey: "groupIcon")
                    let predicate = NSPredicate(format: "Id CONTAINS %@", argumentArray: [(dict.valueForKey("Id"))!])
                    let arrTemp1 = self.arrGroups.filteredArrayUsingPredicate(predicate)
                    
                    if (arrTemp1.count > 0) {
                        let index = self.arrGroups.indexOfObject(arrTemp1[0])
                        self.arrGroups.replaceObjectAtIndex(index, withObject: dict)
                        HideLoader()
                        self.UpdateAndSortGroupArrayThanReloadTable()
                    }
                    else {
                        HideLoader()
                        self.arrGroups.addObject(dict)
                        self.UpdateAndSortGroupArrayThanReloadTable()
                    }
                }
                HideLoader()
                completionHandler()
            })
        }
    }
    
    
    //MARK:- Invoke Chats & Managing online/offline
    //MARK:-
    func loadChats()
    {
        if(UserDefaults.sharedInstance.GetNSUserDefaultValue(currentUserId) != "" && UserDefaults.sharedInstance.GetNSUserDefaultValue(currentUserId) != "userId")
        {
            onDisconnect(UserDefaults.sharedInstance.GetNSUserDefaultValue(currentUserId))
        }
        count = false
        if(btnGrp == true)
        {
            if self.isFirsttmeGroup {
                arrGroups.removeAllObjects()
                arrGetGroups.removeAllObjects()
                self.isFirsttmeGroup = false
                shwGrp()
            }
        }
        else if(btnChat == true)
        {
            btnGrp = false
            btnContact = false
            btnChat = true
            
            if self.isRecentFirsttme {
                self.isRecentFirsttme = false
                arrRecentUser.removeAllObjects()
                arrRecentFilteredContacts.removeAllObjects()
                gettingRecentChat()
            }
        }
    }
    
    
    //MARK :- Getting Recent Chat
    //MARK :-
    func gettingRecentChat()
    {

        if Constants.loginFields.userId == "userId" || Constants.loginFields.userId == ""
        {
            let phNo = NSUserDefaults.standardUserDefaults().objectForKey(mobileKey) as! String
            getCurrentUser(phNo, completionHandler: { (status) in
                self.loadChat({ (status) in
                    self.UpdateAndSortArrayThanReloadTable()
                })
            })
        }
        else
        {
            self.loadChat({ (status) in
                self.UpdateAndSortArrayThanReloadTable()
            })
        }
    }
    
    
    //MARK:- Load Recent Chat
    //MarK:-
    func loadChat(completionHandler : ((status : Bool)-> Void)){
        
        ref.child("recentChat").child(Constants.loginFields.userId).observeEventType(.Value , withBlock: { (snapshot) -> Void in
            ShowLoader()
            
            if(snapshot.exists())
            {
                self.arrRecentUser.removeAllObjects()
                self.arrRecentFilteredContacts.removeAllObjects()
                
                let dicttemp1 = snapshot.valueInExportFormat() as! NSMutableDictionary
                
                for strchildrenid in dicttemp1.allKeys {
                    let dict: NSMutableDictionary = NSMutableDictionary()
                    
                    dict.setObject(strchildrenid as! String , forKey: "Id")
                    dict.setObject(dicttemp1.valueForKey(strchildrenid as! String)!.valueForKey("lastMessage")!, forKey: "lastMessage")
                    dict.setObject(dicttemp1.valueForKey(strchildrenid as! String)!.valueForKey("recentUserId")!, forKey: "recentUserId")
                    dict.setObject(dicttemp1.valueForKey(strchildrenid as! String)!.valueForKey("timeStamp")!, forKey: "timeStamp")
                    
                    let regextest:NSPredicate = NSPredicate(format: "(userId CONTAINS[C] %@ )", argumentArray: [dict["recentUserId"]!])
                    let arrTemp:NSMutableArray = self.arrFilteredContacts.mutableCopy() as! NSMutableArray
                    arrTemp.filterUsingPredicate(regextest)
                    
                    if(arrTemp.firstObject != nil)
                    {
                        let tempDict : NSMutableDictionary = NSMutableDictionary()
                        tempDict.setObject((arrTemp.firstObject!.valueForKey("phoneNo"))!, forKey:"contactNumber")
                        tempDict.setObject((arrTemp.firstObject!.valueForKey("contactName"))!, forKey:"contactName")
                        tempDict.setObject(dict.objectForKey("recentUserId")!, forKey:"recentUserId")
                        tempDict.setObject(dict.objectForKey("lastMessage")!, forKey:"lastMessage")
                        tempDict.setObject((arrTemp.firstObject!.valueForKey("profilePic"))!, forKey:"profilePic")
                        tempDict.setObject((arrTemp.firstObject!.valueForKey("deviceToken"))!, forKey:"deviceToken")
                        tempDict.setObject(arrTemp.firstObject!.objectForKey("firstName")!, forKey:"userName")
                        tempDict.setObject(dict.objectForKey("timeStamp")!, forKey:"timeStamp")
                        self.arrRecentFilteredContacts.addObject(tempDict)
                    }
                    else
                    {
                        let strKey = dict.valueForKey("recentUserId") as!String
                        ref.child("users").child(strKey).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            if(snapshot.exists())
                            {
                                let tempDict : NSMutableDictionary = NSMutableDictionary()
                                tempDict.setObject(snapshot.value!.valueForKey("phoneNo")!, forKey:"contactName")
                                tempDict.setObject("userId", forKey:"userId")
                                tempDict.setObject(snapshot.value!.valueForKey("profilePic")!, forKey:"profilePic")
                                tempDict.setObject(snapshot.value!.valueForKey("status")!, forKey:"status")
                                tempDict.setObject(dict.objectForKey("recentUserId")!, forKey:"recentUserId")
                                tempDict.setObject(dict.objectForKey("lastMessage")!, forKey:"lastMessage")
                                tempDict.setObject(dict.objectForKey("timeStamp")!, forKey:"timeStamp")
                                tempDict.setObject((snapshot.value!.valueForKey("deviceToken"))!, forKey:"deviceToken")
                                let regextest:NSPredicate = NSPredicate(format: "(recentUserId CONTAINS[C] %@ )", argumentArray: [tempDict["recentUserId"]!])
                                let arrTemp:NSMutableArray = self.arrRecentFilteredContacts.mutableCopy() as! NSMutableArray
                                arrTemp.filterUsingPredicate(regextest)
                                
                                if(arrTemp.firstObject != nil)
                                {
                                    
                                }
                                else
                                {
                                    HideLoader()
                                    self.arrRecentFilteredContacts.addObject(tempDict)
                                    self.UpdateAndSortArrayThanReloadTable()
                                }
                            }
                            completionHandler(status: true)
                            HideLoader()
                            self.UpdateAndSortArrayThanReloadTable()
                        })
                    }
                }
            }
            completionHandler(status: true)
           HideLoader()
            self.UpdateAndSortArrayThanReloadTable()
        })
    }
    
    
    //MARK:- Update and sort recent chat list
    //MARK:-
    func UpdateAndSortArrayThanReloadTable() {
        
        for obj in self.arrRecentFilteredContacts {
            let dict: NSMutableDictionary = obj as! NSMutableDictionary
            if dict.objectForKey("newtimeStamp") == nil {
                dict.setObject(self.convertstringTodate(dict.objectForKey("timeStamp") as! String), forKey: "newtimeStamp")
            }
        }
        
        let arrsortDescriptors = NSArray(object: NSSortDescriptor(key: "newtimeStamp", ascending: false))
        self.arrRecentFilteredContacts.sortUsingDescriptors(arrsortDescriptors as! [NSSortDescriptor])
        self.arrRecentFilteredContacts = NSMutableArray(array: self.arrRecentFilteredContacts)
        self.tabChat.reloadData()
    }
    
    
    //MARK:- Update and sort Group list
    //MARK:-
    func UpdateAndSortGroupArrayThanReloadTable() {
        
        for obj in self.arrGroups {
            let dict: NSMutableDictionary = obj as! NSMutableDictionary
            if dict.objectForKey("newtimeStamp") == nil {
                dict.setObject(self.convertstringTodate(dict.objectForKey("timeStamp") as! String), forKey: "newtimeStamp")
            }
        }
        
        let arrsortDescriptors = NSArray(object: NSSortDescriptor(key: "newtimeStamp", ascending: false))
        self.arrGroups.sortUsingDescriptors(arrsortDescriptors as! [NSSortDescriptor])
        self.arrGroups = NSMutableArray(array: self.arrGroups)
        self.tabGrp.reloadData()
    }
    
    
    //MARK:- Convert String to Date
    //MARK:-
    func convertstringTodate(str:String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "MMM d, yyyy hh:mm:ss a"
        if(dateFormatter.dateFromString(str) == nil){
            dateFormatter.dateFormat = "MMM d, yyyy HH:mm:ss a"
            return dateFormatter.dateFromString(str)!
        }else{
             return dateFormatter.dateFromString(str)!
        }
    }
    
    
    //MARK:- Invite Button Action
    //MARK:-
    @IBAction func onInviteButtonClick(sender: UIButton) {
        
        self.sendInviteMessage((arrFilteredContacts.objectAtIndex(sender.tag).valueForKey("phoneNo") as? String)!)
    }
    
    
    //MARK:- Send Invite Message
    //MARK:-
    func sendInviteMessage(number : String)
    {
        if MFMessageComposeViewController.canSendText()
        {
            let messageVC = MFMessageComposeViewController()
            
            messageVC.body = messageInviteUrl
            messageVC.recipients = [number]
            messageVC.messageComposeDelegate = self;
            self.presentViewController(messageVC, animated: false, completion: nil)
        }
        else
        {
            displayAlert("This device can not send SMS", presentVC: self)
        }
    }
    
    
    //MARK:- MESSAGECOMPOSEVIEWCONTROLLER DELEGATE
    //MARK:-
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        //Had to be commented out since it was causing a compile time issue
        //TODO fix this so that it works again
        /*
        switch result.rawValue {
        case MessageComposeResultCancelled.rawValue:
            displayAlert("Failed to send SMS!", presentVC: self)
            break
        case MessageComposeResultFailed.rawValue:
            displayAlert("Failed to send SMS!", presentVC: self)
            break
        case MessageComposeResultSent.rawValue:
            break
        default:
            break
        }*/
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        NSLog("MEMORY WARNING ")
        // Dispose of any resources that can be recreated.
    }
}
