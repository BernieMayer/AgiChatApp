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
        self.register(UINib(nibName: "GroupUsersTableViewCell", bundle: nil), forCellReuseIdentifier: "groupUsersCell")
        self.dataSource = self
        self.delegate = self

    }
    
    
    //MARK:- TableView Delegate / DATASOURCE
    //MARK:-
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrGroupUser.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : GroupUsersTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "groupUsersCell") as! GroupUsersTableViewCell
        cell.updateConstraints()
        cell.selectionStyle = .none
        
        let str = UserDefaults.sharedInstance.GetNSUserDefaultValue(currentUserId) //Getting current user's Id from user default
        cell.lblCellSeprator.backgroundColor = UIColor.init(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1)
        
        //Loading group users in table
        if((arrGroupUser.object(at: indexPath.row) as AnyObject).value(forKey: "userId") as! String != str)
        {
            cell.lblUserName.text = (arrGroupUser.object(at: indexPath.row) as AnyObject).value(forKey: "contactName") as? String
            cell.lblUserType.textColor = UIColor.black
            
            if((arrGroupUser.object(at: indexPath.row) as AnyObject).value(forKey: "userType") as? String == "Admin")
            {
                cell.lblUserType.text = "Admin"
            }
            else
            {
                cell.lblUserType.text = ""
            }
            let img = (self.arrGroupUser.object(at: indexPath.row) as AnyObject).object(forKey: "profilePic") as? String
            
            //image in string url
            if(img != "null")
            {
                cell.imgUser.sd_setImage(with: URL(string: img! as String), placeholderImage: UIImage(named:"grp_icon"))
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
            if((arrGroupUser.object(at: indexPath.row) as AnyObject).value(forKey: "userType") as? String == "Admin")
            {
                cell.lblUserType.text = "Admin"
            }
            else
            {
                cell.lblUserType.text = ""
            }
            var img = NSString()
            img = Constants.loginFields.imageUrl as NSString
            //image in string url
            if(img != "null")
            {
                cell.imgUser.sd_setImage(with: URL(string: img as String as String), placeholderImage: UIImage(named:"grp_icon"))
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
        
    }
    
    func didReceiveMemoryWarning() {
        didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
         NSLog("WARNING FOR MEMORY")
    }
    
}
