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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    override func viewWillAppear(_ animated: Bool) {
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
        tblStatus.separatorColor = UIColor.clear
        
        txtEditStatus.delegate = self
        txtEditStatus.text = Constants.loginFields.status
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        ref.child("statuses").queryOrdered(byChild: "userId").queryEqual(toValue: Constants.loginFields.userId).removeAllObservers() //Removing Observer
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        txtEditStatus.resignFirstResponder()
    }
    
    //MARK:- Configure database
    //MARK:-
    func configureDatabase(_ handler:@escaping ((Bool)->Void))
    {
        //calling observer for statuse to fetch snapshot of statuses of current user
        ref.child("statuses").queryOrdered(byChild: "userId").queryEqual(toValue: Constants.loginFields.userId).observe(.value, with: { (snapshot) in
            
            if(snapshot.exists()) //Checks whether snapshot exists or not
            {
                self.arrStatuses.removeAllObjects()
                
                let dicttemp = snapshot.valueInExportFormat() as! NSMutableDictionary // storing snapshot in dict
                for strchildrenid in dicttemp.allKeys{
                    
                    let dict : NSMutableDictionary = NSMutableDictionary()
                    let dicttemp1 = dicttemp.value(forKey: strchildrenid as! String) as! NSMutableDictionary
                    dict.setObject(strchildrenid as! String, forKey: "statusId" as NSCopying)
                    dict.setObject(dicttemp1.object_forKeyWithValidationForClass_String("userId"), forKey: "userId" as NSCopying)
                    dict.setObject(dicttemp1.object_forKeyWithValidationForClass_String("status"), forKey: "status" as NSCopying)
                    
                    if(self.txtEditStatus.text == dict.object(forKey: "status") as? String)
                    {
                        self.arrStatuses.insert(dict, at: 0) //if add new status then it will be display on 0th index
                    }
                    else
                    {
                        self.arrStatuses.add(dict) //adding all statuses to array status
                    }
                    
                }
            }
            handler(true)
        })
    }
    
    //MARK:- On back click
    //MARK:-
    @IBAction func btnBackClick(_ sender: UIButton) {
        
        if(AIReachability.sharedManager.isAavailable())
        {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK:- On button Done Click
    //MarK:-
    @IBAction func btnDoneClick(_ sender: UIButton) {
        
        // if Added new status then it will update value and push viewController
        if(txtEditStatus.text?.length > 0)
        {
            let str = txtEditStatus.text
            
            let trimmedString = str!.trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines)
            let data = [Constants.statusField.status: trimmedString as String]
            changeStatus(data, data1: trimmedString) //Will change status
            tblStatus.reloadData()
            txtEditStatus.resignFirstResponder()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK:- TextField Delegate
    //MARK:-
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(arrStatuses.count<=0)
        {
            return 0
        }
        else
        {
            return arrStatuses.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "statusListCell") as! statusListCell
        
        let status = (arrStatuses.object(at: indexPath.row) as AnyObject).object(forKey: "status") as! String
        var status1 = txtEditStatus.text
        status1 = status1!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let trimmedString = status1!.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines)
        
        if(trimmedString == (arrStatuses.object(at: indexPath.row) as AnyObject).object(forKey: "status") as? String)
        {
            cell.lblStatuses.textColor = navigationColor
            cell.lblStatuses.text = status
        }
        else
        {
            cell.lblStatuses.textColor = UIColor.black
            cell.lblStatuses.text = status
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var status =  (arrStatuses.object(at: indexPath.row) as AnyObject).object(forKey: "status") as! String
        status = status.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let trimmedString = status.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines)
        
        
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
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        NSLog("WARNING FOR MEMORY")
    }
    
    
}
