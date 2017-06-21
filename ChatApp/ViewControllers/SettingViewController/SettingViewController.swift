//
//  SettingViewController.swift
//  ChatApp
//
//  Created by Anis Mansuri on 24/06/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
class SettingViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var barView: UIView!
    @IBOutlet var tblSetting: UITableView!
    
    var arrImageIconName : NSMutableArray = NSMutableArray()
    var arrSelectedImageIconName : NSMutableArray = NSMutableArray()
    var arrSettingName : NSMutableArray = NSMutableArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrSettingName = NSMutableArray(objects: "Help","Edit Profile","Status","Account","Chats and Calls","Notifications","Contacts") //Settings List Array
        arrImageIconName = NSMutableArray(objects: "help","name","status_Edit","account","chats_calls","notification","contacts") //Seting List Image Icon Array

        //Registering Nib
       tblSetting.register(UINib(nibName: "SettingCustomCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        barView.backgroundColor = navigationColor
        hideNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
         NSLog("WARNING FOR MEMORY")
    }
    
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
    }

    
    // MARK: - TableView Delegates & DataSource
    //MARK:-
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return arrSettingName.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        tableView.separatorStyle = .none
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SettingCustomCell
        cell.selectionStyle = .none
        cell.imgSettingIcon.image = UIImage(named: arrImageIconName.object(at: indexPath.row) as! String)
        cell.lblSettingName.text = arrSettingName.object(at: indexPath.row) as? String
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if(AIReachability.sharedManager.isAavailable())
        {
            if indexPath.row == 0 { //Help
                
                displayAlert("This feature will be available in next version", presentVC: self)
                
            }else if indexPath.row == 1 { //Edit Profile
                
                let mainVC = storyboard.instantiateViewController(withIdentifier: "UpdateProfileViewController") as! UpdateProfileViewController
                
                mainVC.userId = Constants.loginFields.userId
                mainVC.fName = Constants.loginFields.name
                mainVC.lName = Constants.loginFields.lastName
                mainVC.email = Constants.loginFields.email
                mainVC.status = Constants.loginFields.status
                mainVC.imageURL = Constants.loginFields.imageUrl
                mainVC.day = Constants.loginFields.day
                mainVC.month = Constants.loginFields.month
                mainVC.year = Constants.loginFields.year
                mainVC.gender = Constants.loginFields.gender
                
                self.navigationController?.pushViewController(mainVC, animated: true)
                
            }else if indexPath.row == 2 { //Status
                
                let statusVC  = storyboard.instantiateViewController(withIdentifier: "StatusViewController") as! StatusViewController
                self.navigationController?.pushViewController(statusVC, animated: true)
                
            }else if indexPath.row == 3 { //Account
                
                displayAlert("This feature will be available in next version", presentVC: self)
                
            }
            else if indexPath.row == 4 { //Chats and Calls
                
                displayAlert("This feature will be available in next version", presentVC: self)
                
            }else if indexPath.row == 5 { //Notifications
                
                displayAlert("This feature will be available in next version", presentVC: self)
                
            }else if indexPath.row == 6 { //Contacts
                
            let contactVC = storyboard.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
              contactVC.isComingFrom = "Settings"
              contactVC.arrFilteredContacts = UserDefaults.sharedInstance.GetArrayFromUserDefault(allContacts)
              self.navigationController?.pushViewController(contactVC, animated: true)
            }
            self.tableView(tableView, didDeselectRowAt: indexPath)
        }
    }
  
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        

    }
}
