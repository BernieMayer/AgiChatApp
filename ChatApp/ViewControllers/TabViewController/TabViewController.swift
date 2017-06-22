    
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
    var menuItems: [AnyObject] = ["Profile" as AnyObject ,"Settings" as AnyObject,"About Us" as AnyObject]
    var menuImageNames : [AnyObject] = ["name" as AnyObject,"setting" as AnyObject,"about_us" as AnyObject]
    var menuLeft : VKSideMenu = VKSideMenu()
    
    //Group Chat Variables
    var groupId : String = String()
    var flag  : Bool = false
    var arrMemeberGrouplist :[String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //clear notifications and set badge to 0
        UIApplication.shared.applicationIconBadgeNumber = 0
        UIApplication.shared.cancelAllLocalNotifications()
        
        //setting up Ad
        adBanner.adUnitID = unitIdForAd
        adBanner.rootViewController = self
        adBanner.load(GADRequest())
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
        
        menuLeft = VKSideMenu(width: MAIN_WIDTH/3, andDirection: VKSideMenuDirection.leftToRight)
        menuLeft.dataSource = self
        menuLeft.delegate  = self
        
        //will store current user mobile number
        mobile = Foundation.UserDefaults.standard.object(forKey: mobileKey) as! String
        
        menuViewHeight = 40
        createTabTables()
        
        isRecentFirsttme = true
        
        btnChat = true
        tabChat.separatorColor = UIColor.clear
        tabContact.separatorColor = UIColor.clear
        
        self.arrFilteredContacts = UserDefaults.sharedInstance.GetArrayFromUserDefault(allContacts)
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        ref = FIRDatabase.database().reference()
        isFirsttmeContact = true
        
        if(Foundation.UserDefaults.standard.bool(forKey: btnGroup) == true)
        {
            contentScrollView.setContentOffset(CGPoint(x: 0, y: contentScrollView .contentOffset.y), animated: true)
            Foundation.UserDefaults.standard.set(false, forKey: btnGroup)
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
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        
        print("ERROR IS :- \(error)")
       // print(GADErrorCode(rawValue: <#Int#>))
    }
    
    
    //MARK:- RECEIVED ADs
    //MARK:-
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        
        print("______________AD RECEIVED______________")
    }
    
    //MARK:- TOUCHES BEGAN
    //MARK:-
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.menuLeft.hide()
    }
    
    
    //MARK:- ON LEFT MENU CLICK
    //MARK:-
    @IBAction func btnMenuLeftClick(_ sender: UIButton) {
        
        self.menuLeft.show()
    }
    
    
    //MARK:- CREATE TABLES
    //MARK:-
    func createTabTables()  {
        //Creates tables
        
        let arrBtn = ["Groups","Chat","Contacts"]
        self.createMenuWithButtonTitles(arrBtn as NSArray)
        contentScrollView.frame = CGRect(x: 0, y: 140,width: MAIN_WIDTH, height: MAIN_HEIGHT-64)
        contentScrollView.contentSize = CGSize(width: 3*contentScrollView.frame.size.width, height: 0)
        contentScrollView.delegate = self
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.isPagingEnabled = true
        contentScrollView.scrollsToTop = false
        
        //tabGrp is collection View
        tabGrp = self.createCollectionViewWithFrame(CGRect(x: 0, y: 15, width: MAIN_WIDTH, height: contentScrollView.frame.size.height-menuViewHeight-40))
        
        //tabChat frame(tableView)
        tabChat = self.createTableView(withFrame: CGRect(x: MAIN_WIDTH , y: 15, width: MAIN_WIDTH, height: contentScrollView.frame.size.height-70))
        //tabcontact frame(tableview)
        tabContact = self.createTableView(withFrame: CGRect(x: MAIN_WIDTH * 2, y: 15, width: MAIN_WIDTH, height: contentScrollView.frame.size.height-70))
        
        contentScrollView.setContentOffset(CGPoint(x: MAIN_WIDTH, y: contentScrollView .contentOffset.y), animated: true)//Scroll Offset
    }
    
    
    //MARK:- Use for size
    //MARK:-
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if (reuseIdentifier == "list"){
            return CGSize(width: MAIN_SCREEN.bounds.width, height: 100)
        }else{
            return CGSize(width: 100, height: 140)
        }
    }
    
    
    //MARK:- Use for interspacing
    //MARK:-
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    
    //MARK:- Function For Create UICollectionView
    //MARK:-
    func createCollectionViewWithFrame(_ frame: CGRect) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        tabGrp = UICollectionView(frame: frame, collectionViewLayout: layout)
        tabGrp.dataSource = self
        tabGrp.delegate = self
        tabGrp.backgroundColor = UIColor.white
        
        contentScrollView.addSubview(tabGrp)
        
        //Register Collectionview cell
        tabGrp.register(UINib(nibName: "ChatRowCustomCell", bundle: nil), forCellWithReuseIdentifier: "list")
        return tabGrp
    }
    
    
    //MARK:- Function For Setting up UITableView
    //MARK:-
    func createTableView(withFrame frame: CGRect) -> UITableView {
        //Setting up Table View
        let tableView : UITableView = UITableView(frame: frame, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        contentScrollView.addSubview(tableView)
        //Register Table Nib
        tableView.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "contactCell")
        tableView.register(UINib(nibName: "SingleChatCell", bundle: nil), forCellReuseIdentifier: "SingleChatCell")
        return tableView
    }
    
    
    //MARK:- creating menu with button title
    //MARK:-
    func createMenuWithButtonTitles(_ arrBtn : NSArray)
    {
        //similar to navigationColor but less blue to add a gradient
        let menuViewColor = UIColor(customColor: 26, green: 207, blue: 252, alpha: 1.0);
        
        let menuview = UIView(frame:  CGRect(x: 0, y: 64, width: MAIN_WIDTH, height: menuViewHeight))
        menuview.backgroundColor = menuViewColor
        self.view.addSubview(menuview)
        indicatorView = UIView(frame: CGRect(x: 0, y: menuview.frame.size.height - 2, width: MAIN_WIDTH / CGFloat(arrBtn.count), height: 2))
        indicatorView.backgroundColor = UIColor.white
        menuview.addSubview(indicatorView)
        
        for i in 0..<arrBtn.count {
            
            var btn: UIButton!
            if i == 0 {
                let valueOfX = (MAIN_WIDTH / CGFloat(arrBtn.count)) * CGFloat(i)
                
                btn = self.createMenuwithTitle(arrBtn[i] as! String, andFrame: CGRect(x: valueOfX, y: 0, width: MAIN_WIDTH / CGFloat(arrBtn.count), height: menuViewHeight), TitleColor: UIColor.white, action: #selector(btnAction(_:)), withTag: i)
            }
            if i == 1
            {
                let valueOfX = (MAIN_WIDTH / CGFloat(arrBtn.count)) * CGFloat(i)
                
                btn = self.createMenuwithTitle(arrBtn[i] as! String, andFrame: CGRect(x: valueOfX, y: 0, width: MAIN_WIDTH / CGFloat(arrBtn.count), height: menuViewHeight), TitleColor: UIColor.white, action: #selector(btnAction(_:)), withTag: i)
            }
            else {
                let valueOfX = (MAIN_WIDTH / CGFloat(arrBtn.count)) * CGFloat(i)
                
                btn = self.createMenuwithTitle(arrBtn[i] as! String, andFrame: CGRect(x: valueOfX, y: 0, width: MAIN_WIDTH / CGFloat(arrBtn.count), height: menuViewHeight), TitleColor: UIColor.white, action: #selector(btnAction(_:)), withTag: i)
            }
            menuview.addSubview(btn)
        }
    }
    
    
    //MARK: - Scrollview delegate
    //MARK:-
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
                        btnOthers.setTitleColor(UIColor.white, for: UIControlState())
                        UIView.animate(withDuration: 0.25, animations: {() -> Void in
                            self.indicatorView.frame = CGRect(x: btnOthers.frame.size.width * x, y: self.indicatorView.frame.origin.y, width: self.indicatorView.frame.size.width, height: self.indicatorView.frame.size.height)
                            if(x==0)
                            {
                                self.btnGrp = true
                                self.btnContact = false
                                self.btnChat = false
                                self.btnRight.setImage(UIImage(named: "ic_group"), for: UIControlState())
                            }
                            else if(x==1)
                            {
                                self.btnChat = true
                                self.btnGrp = false
                                self.btnContact = false
                                self.btnRight.setImage(UIImage(named: ""), for: UIControlState())
                                self.btnChatClick()
                            }
                            else
                            {
                                self.btnContact = true
                                self.btnChat = false
                                self.btnGrp = false
                                self.btnRight.setImage(UIImage(named: "ic_refresh"), for: UIControlState())
                                self.btnContactClick()
                            }
                        })
                    }
                    else {
                        btnOthers.setTitleColor(UIColor.white, for: UIControlState())
                    }
                }
            }
        }
    }
    
    
    //MARK:- VKSideMenu Delegate and Datasource
    //MARK:-
    func numberOfSections(in sideMenu: VKSideMenu) -> Int {
        
        return 1
    }
    
    
    func sideMenu(_ sideMenu: VKSideMenu, numberOfRowsInSection section: Int) -> Int {
        
        return menuItems.count
    }
    
    
    func sideMenu(_ sideMenu: VKSideMenu, itemForRowAt indexPath: IndexPath) -> VKSideMenuItem {
        let item: VKSideMenuItem = VKSideMenuItem()
        item.title = menuItems[indexPath.row] as? String
        let imgName = menuImageNames[indexPath.row] as? String
        item.icon = UIImage(named: imgName!)
        return item
    }
    
    
    func sideMenu(_ sideMenu: VKSideMenu, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if indexPath.row == 0 {
            ShowLoader()
            let profileVC = storyboard.instantiateViewController(withIdentifier: "UpdateProfileViewController") as! UpdateProfileViewController
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
            let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
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
            let presenceRef = FIRDatabase.database().reference(withPath: "activeStatus").child(Constants.loginFields.userId).child("isOnline");
            presenceRef.onDisconnectSetValue("false")
            
            //Navigate to login view controller
            let loginVC : LoginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            let navigationController : UINavigationController = UINavigationController(rootViewController: loginVC)
            
            self.appDelegate?.window?.rootViewController = navigationController
            //Clearing preferences
            Foundation.UserDefaults.standard.removeObject(forKey: "mobile")
            Foundation.UserDefaults.standard.removeObject(forKey: "device_key")
            Foundation.UserDefaults.standard.set(false, forKey: "signedIn")
            UserDefaults.sharedInstance.RemoveKeyUserFefault(currentUserId)
            UserDefaults.sharedInstance.RemoveKeyUserFefault(phoneContacts)
            dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        }catch {
            // Catch any other errors
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    //MARK:- Fuction For Create Button
    //MARK:-
    func createMenuwithTitle(_ title: String, andFrame frame: CGRect, TitleColor titleColor: UIColor, action target: Selector, withTag tag: Int) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.frame = frame
        btn.tag = tag
        btn.setTitle(title, for: UIControlState())
        btn.setTitleColor(titleColor, for: UIControlState())
        btn.addTarget(self, action: target, for: .touchUpInside)
        return btn
    }
    
    
    //MARK:- TABLEVIEW DATASOURCE & DELEGATE
    //MARK:-
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(tableView == tabContact)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactCell
            if(btnContact == true)
            {
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.btnInvite.isHidden = true
                if(arrFilteredContacts.count > 0)
                {
                    if((arrFilteredContacts.object(at: indexPath.row) as AnyObject).value(forKey: "userId") as! String != "")
                    {
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
                        cell.btnInvite.isHidden = false
                        cell.btnInvite.tag = indexPath.row
                        cell.btnInvite.addTarget(self, action: #selector(onInviteButtonClick(_:)), for: .touchUpInside)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "SingleChatCell", for: indexPath) as! SingleChatCell
            
            if(arrRecentFilteredContacts.count > 0){
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.lblUserName.text = (self.arrRecentFilteredContacts.object(at: indexPath.row) as AnyObject).value(forKey: "contactName") as? String
                //cell.btnInvite.hidden = true
                if(((arrRecentFilteredContacts.object(at: indexPath.row) as AnyObject).object(forKey: "profilePic") as! String) != "null")
                {
                    let img = ((arrRecentFilteredContacts.object(at: indexPath.row) as AnyObject).object(forKey: "profilePic") as! String)
                    cell.imgViewProfile.sd_setImage(with: URL(string: img),placeholderImage: UIImage(named:"default_profile"))
                }
                else
                {
                    cell.imgViewProfile.image = UIImage(named: "default_profile")
                }
                
                cell.lblStatus.text = (self.arrRecentFilteredContacts.object(at: indexPath.row) as AnyObject).value(forKey: "lastMessage") as? String
                cell.lblTime.text = convertDate(((self.arrRecentFilteredContacts.object(at: indexPath.row) as AnyObject).value(forKey: "timeStamp") as? String)!)
            }
            
            return cell
        }
            
        else
        {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(AIReachability.sharedManager.isAavailable())
        {
            let jsqChatVC : ChatViewController = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            
            if(btnContact == true)
            {
                if((arrFilteredContacts.object(at: indexPath.row) as AnyObject).value(forKey: "userId") as! String != "")
                {
                    jsqChatVC.userName = ((arrFilteredContacts.object(at: indexPath.row) as AnyObject).object(forKey: "contactName") as? String)!
                    jsqChatVC.userId = ((arrFilteredContacts.object(at: indexPath.row) as AnyObject).object(forKey: "userId") as? String)!
                    jsqChatVC.getID = Constants.loginFields.userId
                    jsqChatVC.deviceToken = ((arrFilteredContacts.object(at: indexPath.row) as AnyObject).object(forKey: "deviceToken") as? String)!
                    
                    if((arrFilteredContacts.object(at: indexPath.row) as AnyObject).object(forKey: "profilePic") as? String != "null")
                    {
                        let img = (arrFilteredContacts.object(at: indexPath.row) as AnyObject).object(forKey: "profilePic") as? String
                        jsqChatVC.proPic.sd_setImage(with: URL(string: img!),placeholderImage: UIImage(named: "default_profile"))
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
                    self.sendInviteMessage((arrFilteredContacts.object(at: indexPath.row) as AnyObject).value(forKey: "phoneNo") as! String)
                }
                
            }
            else if(btnChat == true)
            {
                jsqChatVC.userName = ((arrRecentFilteredContacts.object(at: indexPath.row) as AnyObject).object(forKey: "contactName") as! String)
                jsqChatVC.userId = ((self.arrRecentFilteredContacts.object(at: indexPath.row) as AnyObject).object(forKey: "recentUserId") as? String)!
                jsqChatVC.getID = Constants.loginFields.userId
                
                jsqChatVC.deviceToken = ((arrRecentFilteredContacts.object(at: indexPath.row) as AnyObject).object(forKey: "deviceToken") as? String)!
                
                if((arrRecentFilteredContacts!.object(at: indexPath.row) as AnyObject).object(forKey: "profilePic") as! String != "null")
                {
                    let img = ((arrRecentFilteredContacts.object(at: indexPath.row) as AnyObject).object(forKey: "profilePic") as! String)
                    jsqChatVC.proPic.sd_setImage(with: URL(string: img),placeholderImage: UIImage(named:"default_profile"))
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    // MARK: - CollectionView Methods
    //MARK:-
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatRowCustomCell
        
        if(arrGroups.count > 0)
        {
            cell.lblUserName.text = (arrGroups.object(at: indexPath.row) as AnyObject).object(forKey: "groupName") as? String
            var lastMessage : String = String()
            
            if((arrGroups.object(at: indexPath.row) as AnyObject).object(forKey: "lastMessage") as! String == "")
            {
                if((arrGroups.object(at: indexPath.row) as AnyObject).value(forKey: "userId") as! String == UserDefaults.sharedInstance.GetNSUserDefaultValue(currentUserId))
                {
                    lastMessage = "You created group"
                }
                else
                {
                    lastMessage = "\((arrGroups.object(at: indexPath.row) as AnyObject).object(forKey: "userName") as! String) created group"
                }
                
            }
            else
            {
                if((arrGroups.object(at: indexPath.row) as AnyObject).value(forKey: "userId") as! String == UserDefaults.sharedInstance.GetNSUserDefaultValue(currentUserId))
                {
                    lastMessage = "You: \((arrGroups.object(at: indexPath.row) as AnyObject).object(forKey: "lastMessage") as! String)"
                }
                else
                {
                    lastMessage = "\((arrGroups.object(at: indexPath.row) as AnyObject).object(forKey: "userName") as! String): \((arrGroups.object(at: indexPath.row) as AnyObject).object(forKey: "lastMessage") as! String)"
                }
            }
            
            cell.lblStatus.text = lastMessage
            cell.lblTime.text = convertDate(((self.arrGroups.object(at: indexPath.row) as AnyObject).value(forKey: "timeStamp") as? String)!)
            if((arrGroups.object(at: indexPath.row) as AnyObject).object(forKey: "groupIcon") as? String != "null")
            {
                let img = (arrGroups.object(at: indexPath.row) as AnyObject).object(forKey: "groupIcon") as? String
                cell.imgViewProfile.sd_setImage(with: URL(string: img!),placeholderImage: UIImage(named: "grp_icon"))
            }
            else
            {
                cell.imgViewProfile.image = UIImage(named: "grp_icon")
                cell.imgViewProfile.backgroundColor = UIColor.clear
            }
            
            cell.lblMsgCount.isHidden = true
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(AIReachability.sharedManager.isAavailable())
        {
            if arrGroups.count > 0
            {
                let jsqChatVC : ChatViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                if(self.arrGroups.count>0)
                {
                    jsqChatVC.groupName = (self.arrGroups.object(at: indexPath.row) as AnyObject).object(forKey: "groupName") as! String
                    jsqChatVC.groupId = (self.arrGroups.object(at: indexPath.row) as AnyObject).object(forKey: "Id") as! String
                    jsqChatVC.getID = Constants.loginFields.userId
                    jsqChatVC.isGroupChat = true
                    jsqChatVC.groupName = ((self.arrGroups.object(at: indexPath.row) as AnyObject).object(forKey: "groupName") as? String)!
                    jsqChatVC.isGroupChat = true
                    jsqChatVC.isExistingGroup = true
                    if((self.arrGroups.object(at: indexPath.row) as AnyObject).object(forKey: "groupIcon") as? String != "null")
                    {
                        let img = (self.arrGroups.object(at: indexPath.row) as AnyObject).object(forKey: "groupIcon") as? String
                        jsqChatVC.groupIcon.sd_setImage(with: URL(string: img!),placeholderImage: UIImage(named: "grp_icon"))
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
    @IBAction func btnAction(_ sender: AnyObject) {
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
                        btnOthers.setTitleColor(UIColor.white, for: UIControlState())
                        UIView.animate(withDuration: 0.25, animations: {
                            self.indicatorView.frame = CGRect(x: btn.frame.size.width * CGFloat(btn.tag), y: self.indicatorView.frame.origin.y, width: self.indicatorView.frame.size.width, height: self.indicatorView.frame.size.height)
                            
                            if(btn.tag == 0)
                            {
                                self.btnRight.setImage(UIImage(named: "code_selected"), for: UIControlState())
                                self.btnTabClick()
                            }
                            else if(btn.tag == 1)
                            {
                                self.btnRight.setImage(UIImage(named: ""), for: UIControlState())
                                self.btnContact = false
                                self.btnChat = true
                                self.btnChatClick()
                            }
                            else
                            {
                                self.btnRight.setImage(UIImage(named: "ic_refresh"), for: UIControlState())
                                self.btnContact = true
                            }
                        })
                    }
                    else {
                        btnOthers.setTitleColor(UIColor.white, for: UIControlState())
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
    @IBAction func btnRightClick(_ sender: UIButton) {
        
        if(AIReachability.sharedManager.isAavailable())
        {
            if(btnGrp == true)
            {
                let contactVC = storyboard?.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
                contactVC.isComingFrom = "Group"
                self.navigationController?.pushViewController(contactVC, animated: true)
                
            }
            else if(btnContact == true)
            {
                gettingAllData({ () in
                    //self.arrFilteredContacts.removeAllObjects() //= NSMutableArray()
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
        let refGrp = ref.child("groupUsers").queryOrdered(byChild: "userId").queryEqual(toValue: uId)
        
        refGrp.observe(.value, with: { (snapshot) in
            
            if(snapshot.exists())
            {
                SwiftLoader.hide()
                let dicttempUser = snapshot.valueInExportFormat() as! NSMutableDictionary
                
                for strchildrenid in dicttempUser.allKeys{
                    
                    let dict: NSMutableDictionary = NSMutableDictionary()
                    let dicttemp = dicttempUser.value(forKey: strchildrenid as! String)
                    
                    dict.setObject(((dicttemp as AnyObject).value(forKey: "groupId"))!, forKey: "groupId" as NSCopying)
                    self.arrGroupIds.add(dict)
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
    
    func getGroups(_ arrGetGrps : NSMutableArray,completionHandler : @escaping (Void) -> Void)
    {
        ref = FIRDatabase.database().reference()
        ShowLoader()
        
        for i in 0..<arrGetGrps.count {
            
            let groupId1 = (arrGetGrps.object(at: i) as AnyObject).value(forKey: "groupId") as! String
            let ref1 = ref.child("group").child("\(groupId1)")
            ref1.observe(.value, with: { (snapshot) in
            
            if(snapshot.exists())
             {
                    let dicttempUser = snapshot.valueInExportFormat() as! NSMutableDictionary
                    let dict: NSMutableDictionary = NSMutableDictionary()
                    dict.setObject(groupId1 , forKey: "Id" as NSCopying)
                    dict.setObject((dicttempUser.value(forKey: "groupName"))!, forKey: "groupName" as NSCopying)
                    dict.setObject((dicttempUser.value(forKey: "lastMessage"))!, forKey: "lastMessage" as NSCopying)
                    dict.setObject((dicttempUser.value(forKey: "userId"))!, forKey: "userId" as NSCopying)
                    dict.setObject((dicttempUser.value(forKey: "userName"))!, forKey: "userName" as NSCopying)
                    dict.setObject((dicttempUser.value(forKey: "timeStamp"))!, forKey: "timeStamp" as NSCopying)
                    dict.setObject((dicttempUser.value(forKey: "groupIcon"))!, forKey: "groupIcon" as NSCopying)
                    let predicate = NSPredicate(format: "Id CONTAINS %@", argumentArray: [(dict.value(forKey: "Id"))!])
                    let arrTemp1 = self.arrGroups.filtered(using: predicate)
                    
                    if (arrTemp1.count > 0) {
                        let index = self.arrGroups.index(of: arrTemp1[0])
                        self.arrGroups.replaceObject(at: index, with: dict)
                        HideLoader()
                        self.UpdateAndSortGroupArrayThanReloadTable()
                    }
                    else {
                        HideLoader()
                        self.arrGroups.add(dict)
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
            let phNo = Foundation.UserDefaults.standard.object(forKey: mobileKey) as! String
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
    func loadChat(_ completionHandler : @escaping ((_ status : Bool)-> Void)){
        
        ref.child("recentChat").child(Constants.loginFields.userId).observe(.value , with: { (snapshot) -> Void in
            ShowLoader()
            
            if(snapshot.exists())
            {
                self.arrRecentUser.removeAllObjects()
                self.arrRecentFilteredContacts.removeAllObjects()
                
                let dicttemp1 = snapshot.valueInExportFormat() as! NSMutableDictionary
                
                for strchildrenid in dicttemp1.allKeys {
                    let dict: NSMutableDictionary = NSMutableDictionary()
                    
                    dict.setObject(strchildrenid as! String , forKey: "Id" as NSCopying)
                    dict.setObject((dicttemp1.value(forKey: strchildrenid as! String)! as AnyObject).value(forKey: "lastMessage")!, forKey: "lastMessage" as NSCopying)
                    dict.setObject((dicttemp1.value(forKey: strchildrenid as! String)! as AnyObject).value(forKey: "recentUserId")!, forKey: "recentUserId" as NSCopying)
                    dict.setObject((dicttemp1.value(forKey: strchildrenid as! String)! as AnyObject).value(forKey: "timeStamp")!, forKey: "timeStamp" as NSCopying)
                    
                    let regextest:NSPredicate = NSPredicate(format: "(userId CONTAINS[C] %@ )", argumentArray: [dict["recentUserId"]!])
                    let arrTemp:NSMutableArray = self.arrFilteredContacts.mutableCopy() as! NSMutableArray
                    arrTemp.filter(using: regextest)
                    
                    if(arrTemp.firstObject != nil)
                    {
                        let tempDict : NSMutableDictionary = NSMutableDictionary()
                        tempDict.setObject(((arrTemp.firstObject! as AnyObject).value(forKey: "phoneNo"))!, forKey:"contactNumber" as NSCopying)
                        tempDict.setObject(((arrTemp.firstObject! as AnyObject).value(forKey: "contactName"))!, forKey:"contactName" as NSCopying)
                        tempDict.setObject(dict.object(forKey: "recentUserId")!, forKey:"recentUserId" as NSCopying)
                        tempDict.setObject(dict.object(forKey: "lastMessage")!, forKey:"lastMessage" as NSCopying)
                        tempDict.setObject(((arrTemp.firstObject! as AnyObject).value(forKey: "profilePic"))!, forKey:"profilePic" as NSCopying)
                        tempDict.setObject(((arrTemp.firstObject! as AnyObject).value(forKey: "deviceToken"))!, forKey:"deviceToken" as NSCopying)
                        tempDict.setObject((arrTemp.firstObject! as AnyObject).object(forKey: "firstName")!, forKey:"userName" as NSCopying)
                        tempDict.setObject(dict.object(forKey: "timeStamp")!, forKey:"timeStamp" as NSCopying)
                        self.arrRecentFilteredContacts.add(tempDict)
                    }
                    else
                    {
                        let strKey = dict.value(forKey: "recentUserId") as!String
                        ref.child("users").child(strKey).observeSingleEvent(of: .value, with: { (snapshot) in
                            if(snapshot.exists())
                            {
                                let tempDict : NSMutableDictionary = NSMutableDictionary()
                                tempDict.setObject((snapshot.value! as AnyObject).value(forKey: "phoneNo")!, forKey:"contactName" as NSCopying)
                                tempDict.setObject("userId", forKey:"userId" as NSCopying)
                                tempDict.setObject((snapshot.value! as AnyObject).value(forKey: "profilePic")!, forKey:"profilePic" as NSCopying)
                                tempDict.setObject((snapshot.value! as AnyObject).value(forKey: "status")!, forKey:"status" as NSCopying)
                                tempDict.setObject(dict.object(forKey: "recentUserId")!, forKey:"recentUserId" as NSCopying)
                                tempDict.setObject(dict.object(forKey: "lastMessage")!, forKey:"lastMessage" as NSCopying)
                                tempDict.setObject(dict.object(forKey: "timeStamp")!, forKey:"timeStamp" as NSCopying)
                                tempDict.setObject(((snapshot.value! as AnyObject).value(forKey: "deviceToken"))!, forKey:"deviceToken" as NSCopying)
                                let regextest:NSPredicate = NSPredicate(format: "(recentUserId CONTAINS[C] %@ )", argumentArray: [tempDict["recentUserId"]!])
                                let arrTemp:NSMutableArray = self.arrRecentFilteredContacts.mutableCopy() as! NSMutableArray
                                arrTemp.filter(using: regextest)
                                
                                if(arrTemp.firstObject != nil)
                                {
                                    
                                }
                                else
                                {
                                    HideLoader()
                                    self.arrRecentFilteredContacts.add(tempDict)
                                    self.UpdateAndSortArrayThanReloadTable()
                                }
                            }
                            completionHandler(true)
                            HideLoader()
                            self.UpdateAndSortArrayThanReloadTable()
                        })
                    }
                }
            }
            completionHandler(true)
           HideLoader()
            self.UpdateAndSortArrayThanReloadTable()
        })
    }
    
    
    //MARK:- Update and sort recent chat list
    //MARK:-
    func UpdateAndSortArrayThanReloadTable() {
        
        for obj in self.arrRecentFilteredContacts {
            let dict: NSMutableDictionary = obj as! NSMutableDictionary
            if dict.object(forKey: "newtimeStamp") == nil {
                dict.setObject(self.convertstringTodate(dict.object(forKey: "timeStamp") as! String), forKey: "newtimeStamp" as NSCopying)
            }
        }
        
        let arrsortDescriptors = NSArray(object: NSSortDescriptor(key: "newtimeStamp", ascending: false))
        self.arrRecentFilteredContacts.sort(using: arrsortDescriptors as! [NSSortDescriptor])
        self.arrRecentFilteredContacts = NSMutableArray(array: self.arrRecentFilteredContacts)
        self.tabChat.reloadData()
    }
    
    
    //MARK:- Update and sort Group list
    //MARK:-
    func UpdateAndSortGroupArrayThanReloadTable() {
        
        for obj in self.arrGroups {
            let dict: NSMutableDictionary = obj as! NSMutableDictionary
            if dict.object(forKey: "newtimeStamp") == nil {
                dict.setObject(self.convertstringTodate(dict.object(forKey: "timeStamp") as! String), forKey: "newtimeStamp" as NSCopying)
            }
        }
        
        let arrsortDescriptors = NSArray(object: NSSortDescriptor(key: "newtimeStamp", ascending: false))
        self.arrGroups.sort(using: arrsortDescriptors as! [NSSortDescriptor])
        self.arrGroups = NSMutableArray(array: self.arrGroups)
        self.tabGrp.reloadData()
    }
    
    
    //MARK:- Convert String to Date
    //MARK:-
    func convertstringTodate(_ str:String) -> Date {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MMM d, yyyy hh:mm:ss a"
        if(dateFormatter.date(from: str) == nil){
            dateFormatter.dateFormat = "MMM d, yyyy HH:mm:ss a"
            return dateFormatter.date(from: str)!
        }else{
             return dateFormatter.date(from: str)!
        }
    }
    
    
    //MARK:- Invite Button Action
    //MARK:-
    @IBAction func onInviteButtonClick(_ sender: UIButton) {
        
        self.sendInviteMessage(((arrFilteredContacts.object(at: sender.tag) as AnyObject).value(forKey: "phoneNo") as? String)!)
    }
    
    
    //MARK:- Send Invite Message
    //MARK:-
    func sendInviteMessage(_ number : String)
    {
        if MFMessageComposeViewController.canSendText()
        {
            let messageVC = MFMessageComposeViewController()
            
            messageVC.body = messageInviteUrl
            messageVC.recipients = [number]
            messageVC.messageComposeDelegate = self;
            self.present(messageVC, animated: false, completion: nil)
        }
        else
        {
            displayAlert("This device can not send SMS", presentVC: self)
        }
    }
    
    
    //MARK:- MESSAGECOMPOSEVIEWCONTROLLER DELEGATE
    //MARK:-
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
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
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        NSLog("MEMORY WARNING ")
        // Dispose of any resources that can be recreated.
    }
}
