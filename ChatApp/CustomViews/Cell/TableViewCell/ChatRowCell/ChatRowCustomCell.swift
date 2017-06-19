//
//  ChatRowCustomCell.swift
//  ChatApp
//
//  Created by Anis Mansuri on 24/06/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ChatRowCustomCell: UICollectionViewCell {
    
    @IBOutlet var imgViewProfile: UIImageView!
    @IBOutlet var lblStatus: UILabel!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var lblOnlineStatus: UILabel!
    @IBOutlet var lblMsgCount: UILabel!
    
    var ref: FIRDatabaseReference!
    var arrRecentUser : NSMutableArray!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        arrRecentUser = NSMutableArray()
        imgViewProfile.layer.masksToBounds = true
        lblMsgCount.hidden = true
        imgViewProfile.layer.cornerRadius = CGRectGetWidth(imgViewProfile.frame)/2.5
    }
    
    func UpdateCell(userId : String, isComingFrom : String )
    {
        if(isComingFrom == "Chat")
        {
            getRecentChat(userId)
        }
    }
    
    
    func getRecentChat(userId:String)
    {
        
         //Getting User name for recent chats
        
       // ref = FIRDatabase.database().reference()

        
        self.ref.child("users").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
           if(snapshot.exists())
           {
            let dicttempUser = snapshot.valueInExportFormat() as! NSMutableDictionary
            for strchildrenid in dicttempUser.allKeys{
                let dict: NSMutableDictionary = NSMutableDictionary()
                
                var dicttemp = dicttempUser.valueForKey(strchildrenid as! String)
                dict.setObject(strchildrenid as! String, forKey: "Id")
                dict.setObject((dicttemp!.valueForKey("firstName"))!, forKey: "firstName")
                dict.setObject((dicttemp!.valueForKey("lastName"))!, forKey: "lastName")
                dict.setObject((dicttemp!.valueForKey("profilePic"))!, forKey: "profilePic")
                
                self.arrRecentUser.addObject(dict)
                
                dicttemp = nil
            }
            
            for i in 0..<self.arrRecentUser.count
            {
                if(self.arrRecentUser.objectAtIndex(i).objectForKey("Id") as! String == userId )
                {
                    self.lblUserName.text =  self.arrRecentUser.objectAtIndex(i).objectForKey("firstName") as? String
                    
                    let img = self.arrRecentUser.objectAtIndex(i).objectForKey("profilePic") as? String
                    if let url = NSURL(string: img!) {
                        if let data = NSData(contentsOfURL: url) {
                            self.imgViewProfile.image = UIImage(data: data)
                            
                        }
                    }
                    
                    // break
                }
            }

           }
           // self.myCollectiionView.reloadData()
            
        })
        
    }


}
