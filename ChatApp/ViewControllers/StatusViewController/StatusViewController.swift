//
//  StatusViewController.swift
//  ChatApp
//
//  Created by admin on 28/09/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

@available(iOS 9.0, *)
class StatusViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet var barView: UIView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet var tblStatus: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var txtEditStatus: TJTextField!
    
    var userId : String = String()                  //Stores UserId
    var arrStatuses : NSMutableArray!       //Stores array of current user's stauses
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barView.backgroundColor = navigationColor
        arrStatuses = NSMutableArray()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        barView.backgroundColor = navigationColor
        configureDatabase { (isTrue) in //Configuring Database
            self.tblStatus.reloadData()
        }
        
        //setting table status
        tblStatus.delegate = self
        tblStatus.dataSource = self
        tblStatus.rowHeight = UITableViewAutomaticDimension
        tblStatus.estimatedRowHeight = 200
        tblStatus.separatorColor = UIColor.clearColor()
        
        txtEditStatus.delegate = self
        txtEditStatus.text = Constants.loginFields.status
        
    }
    override func viewWillDisappear(animated: Bool) {
        ref.child("statuses").queryOrderedByChild("userId").queryEqualToValue(Constants.loginFields.userId).removeAllObservers() //Removing Observer
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        txtEditStatus.resignFirstResponder()
    }
    
    //MARK:- Configure database
    //MARK:-
    func configureDatabase(handler:((Bool)->Void))
    {
        //calling observer for statuse to fetch snapshot of statuses of current user
        ref.child("statuses").queryOrderedByChild("userId").queryEqualToValue(Constants.loginFields.userId).observeEventType(.Value, withBlock: { (snapshot) in
            
            if(snapshot.exists()) //Checks whether snapshot exists or not
            {
                self.arrStatuses.removeAllObjects()
                
                let dicttemp = snapshot.valueInExportFormat() as! NSMutableDictionary // storing snapshot in dict
                for strchildrenid in dicttemp.allKeys{
                    
                    let dict : NSMutableDictionary = NSMutableDictionary()
                    let dicttemp1 = dicttemp.valueForKey(strchildrenid as! String) as! NSMutableDictionary
                    dict.setObject(strchildrenid as! String, forKey: "statusId")
                    dict.setObject(dicttemp1.object_forKeyWithValidationForClass_String("userId"), forKey: "userId")
                    dict.setObject(dicttemp1.object_forKeyWithValidationForClass_String("status"), forKey: "status")
                    
                    if(self.txtEditStatus.text == dict.objectForKey("status") as? String)
                    {
                        self.arrStatuses.insertObject(dict, atIndex: 0) //if add new status then it will be display on 0th index
                    }
                    else
                    {
                        self.arrStatuses.addObject(dict) //adding all statuses to array status
                    }
                    
                }
            }
            handler(true)
        })
    }
    
    //MARK:- On back click
    //MARK:-
    @IBAction func btnBackClick(sender: UIButton) {
        
        if(AIReachability.sharedManager.isAavailable())
        {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    //MARK:- On button Done Click
    //MarK:-
    @IBAction func btnDoneClick(sender: UIButton) {
        
        // if Added new status then it will update value and push viewController
        if(txtEditStatus.text?.length > 0)
        {
            let str = txtEditStatus.text
            
            let trimmedString = str!.stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let data = [Constants.statusField.status: trimmedString as String]
            changeStatus(data, data1: trimmedString) //Will change status
            tblStatus.reloadData()
            txtEditStatus.resignFirstResponder()
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    //MARK:- TextField Delegate
    //MARK:-
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if range.location == 0 && (string == " ") {
            return false
        }
        
        if range.location >= 255 {
            return false
        }
        
        return true
    }
    
    
    //MARK:- TableView Delegate
    //MARK:-
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(arrStatuses.count<=0)
        {
            return 0
        }
        else
        {
            return arrStatuses.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("statusListCell") as! statusListCell
        
        let status = arrStatuses.objectAtIndex(indexPath.row).objectForKey("status") as! String
        var status1 = txtEditStatus.text
        status1 = status1!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        let trimmedString = status1!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if(trimmedString == arrStatuses.objectAtIndex(indexPath.row).objectForKey("status") as? String)
        {
            cell.lblStatuses.textColor = navigationColor
            cell.lblStatuses.text = status
        }
        else
        {
            cell.lblStatuses.textColor = UIColor.blackColor()
            cell.lblStatuses.text = status
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var status =  arrStatuses.objectAtIndex(indexPath.row).objectForKey("status") as! String
        status = status.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        let trimmedString = status.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        
        if(trimmedString.length > 0)
        {
            txtEditStatus.text = trimmedString
            let data = [Constants.statusField.status: txtEditStatus.text! as String]
            
            changeStatus(data, data1: trimmedString)
            tblStatus.reloadData()
        }
    }
    
    //MARK:- Row Height
    //MARK:-
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65.0
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        NSLog("WARNING FOR MEMORY")
    }
    
    
}
