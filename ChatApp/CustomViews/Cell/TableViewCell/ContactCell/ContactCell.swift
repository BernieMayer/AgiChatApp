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


class ContactCell:UITableViewCell {
    
    @IBOutlet var imgViewProfile: UIImageView!
    
    @IBOutlet var lblUserName: UILabel!
    
    @IBOutlet var lblStatus: UILabel!
    
    @IBOutlet weak var btnInvite: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    var ref: FIRDatabaseReference!
    var arrRecentUser : NSMutableArray!

    

    override func awakeFromNib() {
        super.awakeFromNib()
        imgViewProfile.layer.masksToBounds = true
        imgViewProfile.layer.cornerRadius = imgViewProfile.frame.width/2.5
    }
    
}
