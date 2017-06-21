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
        lblMsgCount.isHidden = true
        imgViewProfile.layer.cornerRadius = imgViewProfile.frame.width/2.5
    }
    
    func UpdateCell(_ userId : String, isComingFrom : String )
    {
        if(isComingFrom == "Chat")
        {
            getRecentChat(userId)
        }
    }
    
    
    func getRecentChat(_ userId:String)
    {
        
         //Getting User name for recent chats
        
       // ref = FIRDatabase.database().reference()

        
        self.ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
           if(snapshot.exists())
           {
            let dicttempUser = snapshot.valueInExportFormat() as! NSMutableDictionary
            for strchildrenid in dicttempUser.allKeys{
                let dict: NSMutableDictionary = NSMutableDictionary()
                
                var dicttemp = dicttempUser.value(forKey: strchildrenid as! String)
                dict.setObject(strchildrenid as! String, forKey: "Id" as NSCopying)
                dict.setObject(((dicttemp! as AnyObject).value(forKey: "firstName"))!, forKey: "firstName" as NSCopying)
                dict.setObject(((dicttemp! as AnyObject).value(forKey: "lastName"))!, forKey: "lastName" as NSCopying)
                dict.setObject(((dicttemp! as AnyObject).value(forKey: "profilePic"))!, forKey: "profilePic" as NSCopying)
                
                self.arrRecentUser.add(dict)
                
                dicttemp = nil
            }
            
            for i in 0..<self.arrRecentUser.count
            {
                if((self.arrRecentUser.object(at: i) as AnyObject).object(forKey: "Id") as! String == userId )
                {
                    self.lblUserName.text =  (self.arrRecentUser.object(at: i) as AnyObject).object(forKey: "firstName") as? String
                    
                    let img = (self.arrRecentUser.object(at: i) as AnyObject).object(forKey: "profilePic") as? String
                    if let url = URL(string: img!) {
                        if let data = try? Data(contentsOf: url) {
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
