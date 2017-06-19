//
//  GroupUsersTableViewController.swift
//  ChatApp
//
//  Created by admin on 24/10/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import UIKit
import SDWebImage

class GroupUsersTableViewController:BaseTableView, UITableViewDataSource,UITableViewDelegate {
    
    var arrGroupUser : NSMutableArray = NSMutableArray()
    var groupId : String = String()
    var arrCount : Int = Int()
    override func awakeFromNib() {
        
        super.awakeFromNib()
        //Register Nib
        self.registerNib(UINib(nibName: "GroupUsersTableViewCell", bundle: nil), forCellReuseIdentifier: "groupUsersCell")
        self.dataSource = self
        self.delegate = self

    }
    
    
    //MARK:- TableView Delegate / DATASOURCE
    //MARK:-
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrGroupUser.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : GroupUsersTableViewCell  = tableView.dequeueReusableCellWithIdentifier("groupUsersCell") as! GroupUsersTableViewCell
        cell.updateConstraints()
        cell.selectionStyle = .None
        
        let str = UserDefaults.sharedInstance.GetNSUserDefaultValue(currentUserId) //Getting current user's Id from user default
        cell.lblCellSeprator.backgroundColor = UIColor.init(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1)
        
        //Loading group users in table
        if(arrGroupUser.objectAtIndex(indexPath.row).valueForKey("userId") as! String != str)
        {
            cell.lblUserName.text = arrGroupUser.objectAtIndex(indexPath.row).valueForKey("contactName") as? String
            cell.lblUserType.textColor = UIColor.blackColor()
            
            if(arrGroupUser.objectAtIndex(indexPath.row).valueForKey("userType") as? String == "Admin")
            {
                cell.lblUserType.text = "Admin"
            }
            else
            {
                cell.lblUserType.text = ""
            }
            let img = self.arrGroupUser.objectAtIndex(indexPath.row).objectForKey("profilePic") as? String
            
            //image in string url
            if(img != "null")
            {
                cell.imgUser.sd_setImageWithURL(NSURL(string: img! as String), placeholderImage: UIImage(named:"grp_icon"))
            }
            else
            {
                cell.imgUser.image = UIImage(named: "grp_icon")
            }
        }
        else
        {
            //Current User Detail
            cell.lblUserName.text = "You"
            if(arrGroupUser.objectAtIndex(indexPath.row).valueForKey("userType") as? String == "Admin")
            {
                cell.lblUserType.text = "Admin"
            }
            else
            {
                cell.lblUserType.text = ""
            }
            var img = NSString()
            img = Constants.loginFields.imageUrl
            //image in string url
            if(img != "null")
            {
                cell.imgUser.sd_setImageWithURL(NSURL(string: img as String as String), placeholderImage: UIImage(named:"grp_icon"))
            }
            else
            {
                cell.imgUser.image = UIImage(named: "grp_icon")
            }
        }
        return cell
    }
    
    //MARK:- height for row
    //MARK:-
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
        
    }
    
    func didReceiveMemoryWarning() {
        didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
         NSLog("WARNING FOR MEMORY")
    }
    
}
