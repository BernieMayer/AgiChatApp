//
//  GroupProfileViewController.swift
//  ChatApp
//
//  Created by admin on 24/10/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

@available(iOS 9.0, *)
class GroupProfileViewController: BaseViewController, UIImagePickerControllerDelegate {
    
    //self variables
    @IBOutlet weak var tblUpdateGroup: GroupProfileTableViewController!
    @IBOutlet var barView: UIView!
    @IBOutlet var tblContact: UITableView!
    @IBOutlet var imgGroupIcon: UIImageView? = UIImageView()
    @IBOutlet var tblHeader: UIView!
    @IBOutlet weak var tblUserList: GroupUsersTableViewController!
    @IBOutlet weak var btnAddUser: UIButton!
    @IBOutlet weak var btnLeaveGrp: UIButton!
    @IBOutlet weak var lblGroupName: UILabel!
    
    //Group cht variables
    var groupName : String = String()
    var groupId : String = String()
    var arrGroupUsers : NSMutableArray = NSMutableArray()
    var arrFilteredContacts : NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        barView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        tblHeader.frame.size.height = IMAGE_HEIGHT
        tblUpdateGroup.tableHeaderView = tblHeader
        
        //tblUserList Displays list of users  in group
        tblUserList.arrGroupUser = arrGroupUsers
    }
    
    @IBAction func btnBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnAddUserClick(sender: AnyObject) {
        
        if(AIReachability.sharedManager.isAavailable())
        {
            let contactVC : ContactViewController = storyboard?.instantiateViewControllerWithIdentifier("ContactViewController") as! ContactViewController
            contactVC.isComingFrom =  "GroupA" //Navigate from Add User
            contactVC.groupId = groupId
            contactVC.existingContacts = arrGroupUsers
            self.navigationController?.pushViewController(contactVC, animated: true)
        }
    }
    
    @IBAction func btnGroupIcon(sender: UIButton) {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        barView.backgroundColor = navigationColor
        hideNavigationBar()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
    }
    
    
    //MARK:- LEAVE GROUP
    //MARK:-
    @IBAction func btnLeaveGroupClick(sender: UIButton) {
        
        //User will be left from group
        
        let ref1 = ref.child("groupUsers")
        ref1.observeEventType(.Value, withBlock: { (snapshot) -> Void in
            if snapshot.exists(){
                for item in snapshot.children {
                    if item.value["userId"] == Constants.loginFields.userId && item.value["groupId"] == self.groupId{
                        item.ref.child(item.key!).parent?.removeValue() // this will remove user from group users
                        ref1.removeAllObservers()
                        
                        let deviceToken = Constants.loginFields.deviceToken
                        self.unSubcscribeUser(self.groupId, deviceId: deviceToken) //Unsubscribing user from recieving notification
                        let tabVC : TabViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TabViewController") as! TabViewController
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: btnGroup)
                        NSUserDefaults.standardUserDefaults().synchronize()
                        self.navigationController?.pushViewController(tabVC, animated: true)
                    }
                }
                
            }
        })
    }
    
    //MARK:- API For Unsubscribing user frm recieving notification when user leaves group
    //MARK:-
    func unSubcscribeUser(groupId : String, deviceId : String)
    {
        let dict : NSMutableDictionary = NSMutableDictionary()
        dict.setObject(groupId, forKey: "topic_key")
        dict.setObject(deviceId, forKey: "device_token")
        //Calling Unsubscribe API
        HttpManager.sharedInstance.unSubscribeGroupDevice("", loaderShow: false, dict: dict, SuccessCompletion: { (result) in
            print("UNSUBSCRIBED") //Successfully unsubscribed
        }) { (result) in
            print("NOT UNSUBSCRIBED ") //Failed to unsubscribe
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        NSLog("WARNING FOR MEMORY")
    }
    
}
