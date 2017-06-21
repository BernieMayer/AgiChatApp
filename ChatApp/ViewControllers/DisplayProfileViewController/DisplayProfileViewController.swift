//
//  DisplayProfileViewController.swift
//  ChatApp
//
//  Created by Anis Mansuri on 27/06/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import CoreTelephony

@available(iOS 9.0, *)
class DisplayProfileViewController: BaseViewController ,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet var imgHeight: NSLayoutConstraint!
    @IBOutlet var tblHeader: UIView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var btnBack: UIButton!
    
     var notificationStaus = true
    var userId : String = String() //Stores User's Id
    var isNavigateFrom : String = String() //Stores, where the controller is navigated from
    
    //user variable
    var userName : String = String() //Stores User Name
    var phoneNumber : String! //Stores Phone Number
    var status : String!   //Stores User's Status
    var proPic : String!  //Stores Profile Pic
    var media  : NSMutableArray! //Stores Media
    
    //Group Chat Variables
    var groupName : String = String() //Stores Group Name
    var groupId : String = String()       //Stores Group Id
    var groupIcon : UIImageView = UIImageView() //Stores Group Icon
    
    @IBOutlet var tblViewProfile: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //INITIALIZING DATA
        phoneNumber = String()
        status = String()
        proPic = String()
        media = NSMutableArray()
        
        tblHeader.frame.size.height = IMAGE_HEIGHT
        imgHeight.constant = IMAGE_HEIGHT
        tblViewProfile.tableHeaderView = tblHeader
        
        tblViewProfile.backgroundColor = UIColor(customColor: 245, green: 245, blue: 245, alpha: 1)
        
        //Registering Nib's
        tblViewProfile.register(UINib(nibName: "NumberCell", bundle: nil), forCellReuseIdentifier: "numberCell")
        tblViewProfile.register(UINib(nibName: "StatusCell", bundle: nil), forCellReuseIdentifier: "statusCell")
        //tblViewProfile.registerNib(UINib(nibName: "MediaCell", bundle: nil), forCellReuseIdentifier: "mediaCell")
        tblViewProfile.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "notificationCell")
        tblViewProfile.register(UINib(nibName: "LocationCell", bundle: nil), forCellReuseIdentifier: "locationCell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        if(isNavigateFrom == "Chat") //navigates from one-to-one chat
        {
            //Retrieve Profile of User to chat with
            retrieveDataFromProfile(userId)
        }
        else if(isNavigateFrom == "group") //navigates from group chat
        {
            self.profileImage.image = groupIcon.image
            self.lblUserName.text = groupName
            self.phoneNumber = " "
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        NSLog("WARNING FOR MEMORY")
    }
    
    
    //MARK:- TableView Delegate
    //MARK:-
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        tableView.separatorStyle = .none
        let cell : UITableViewCell = UITableViewCell()
        
        if indexPath.section == 0{ //Setting Phone Number to Number Cell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "numberCell", for: indexPath) as! NumberCell
            cell.lblPhoneNumber.text = self.phoneNumber
            cell.btnCall.addTarget(self, action: #selector(DisplayProfileViewController.dialCall(_:)), for: .touchUpInside)
            applyPlainShadow(cell.shadowView)
            cell.btnMsg.addTarget(self, action: #selector(DisplayProfileViewController.btnMsgClick(_:)), for: .touchUpInside)
            return cell
            
        }else if indexPath.section == 1{ //Setting Status to Status Cell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "statusCell", for: indexPath) as! StatusCell
            cell.lblStatus.text = self.status
            applyPlainShadow(cell.shadowView)
            return cell
            
        }
            //        }else if indexPath.section == 2{
            //            let cell = tableView.dequeueReusableCellWithIdentifier("mediaCell", forIndexPath: indexPath) as! MediaCell
            //            applyPlainShadow(cell.shadowView)
            //            return cell
            //
            //        }
            
        else if indexPath.section == 2{ //Setting Notification Status
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationCell
            applyPlainShadow(cell.shadowView)
            let switch_on = UIImage(named: "switch_on") as UIImage?
            let switch_off = UIImage(named: "switch_off") as UIImage?
            cell.btnNotificationStatus.addTarget(self, action: #selector(DisplayProfileViewController.NotificationStatus(_:)), for: UIControlEvents.touchUpInside)
            
            if notificationStaus == true {
                
                cell.btnNotificationStatus.setImage(switch_off, for: UIControlState())
                
            }else{
                
                cell.btnNotificationStatus.setImage(switch_on, for: UIControlState())
            }
            
            return cell
            
        }else if indexPath.section == 3{  //Location Cell , for now location is being set from Location Cell class
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! LocationCell
            applyPlainShadow(cell.shadowView)
            return cell
        }
        
        return cell
    }
    
    
    //MARK:- Dial button Action
    //MARK:-
    func dialCall(_ sender:UIButton)
    {
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        
        if(carrier != nil) //Checks whether carrier is available or not
        {
            if(carrier!.mobileNetworkCode == nil || carrier!.mobileNetworkCode == "")
            {
                
                displayAlert("No SIM Card Installed", presentVC: self)
            }
            else
            {
                UIApplication.shared.openURL(URL(string: "tel://\(phoneNumber)")!) //dials
            }
        }
        else {
            
            displayAlert("Your device is not able to call.", presentVC: self)
        }
    }
    
    
    //MARK:- Message button action
    //MARK:-
    func btnMsgClick(_ sender:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {//Number
            return 75
        }else if indexPath.section == 1{ //Status
            return 125
            
            //        }else if indexPath.section == 2{//Media
            //            return 175
        }else if indexPath.section == 2{//Custom
            return 71
        }
        else if indexPath.section == 3{ //Location
            return 260
        }
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 6.0
        }
        return 1.0
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect.zero)
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect.zero)
    }
    
    //MARK:- GoBack Button Action
    //MARK:-
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Notification Status
    //MARK:-
    func NotificationStatus(_ sender: UIButton)  {
        
        notificationStaus = !notificationStaus
        tblViewProfile.reloadRows(at: [IndexPath(row: 0, section: 2)], with: UITableViewRowAnimation.none)
    }
    
    
    //MARK:- Getting User Detail
    //MARK:-
    func retrieveDataFromProfile(_ userId : String)
    {
        
        let refDetail = ref.child("users").child("\(userId)")
         refDetail.observeSingleEvent(of: .value, with: { (snapshot) -> Void in //fetching data from snapshot
            
            if(snapshot.exists()) //check whether snapshot exists or not
            {
                self.phoneNumber = (snapshot.value as AnyObject).value(forKey: "phoneNo") as! String //stores phone number
                self.status = (snapshot.value as AnyObject).value(forKey: "status") as! String //stores status
                self.lblUserName.text = self.userName //Stores UserName
                self.proPic = (snapshot.value as AnyObject).value(forKey: "profilePic") as! String //Stores Profile pic url (string)
                
                if(self.proPic != "null") //Check whether variable contains string or not
                {
                    self.profileImage.sd_setImage(with: URL(string: self.proPic),placeholderImage: UIImage(named: "default_profile")) //displays using url
                }
                else
                {
                    self.profileImage.image = UIImage(named:"default_profile") //when variable is null, then it displays default pic
                }
                
            }
            refDetail.removeAllObservers() //Removing Reference
            self.tblViewProfile.reloadData()//Reloading table
        })
    }
}
