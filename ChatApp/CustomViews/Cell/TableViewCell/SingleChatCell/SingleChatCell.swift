//
//  SingleChatCell.swift
//  ChatApp
//
//  Created by admin on 17/02/17.
//  Copyright © 2017 Agile. All rights reserved.
//

import UIKit

class SingleChatCell: UITableViewCell {

    
    @IBOutlet var imgViewProfile: UIImageView!
    
    @IBOutlet var lblUserName: UILabel!
    
    @IBOutlet var lblStatus: UILabel!
    
    @IBOutlet weak var btnInvite: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgViewProfile.layer.masksToBounds = true
        imgViewProfile.layer.cornerRadius = CGRectGetWidth(imgViewProfile.frame)/2.5
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
