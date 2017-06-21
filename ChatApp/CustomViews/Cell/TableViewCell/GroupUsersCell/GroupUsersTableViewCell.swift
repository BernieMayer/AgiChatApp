//
//  GroupUsersTableViewCell.swift
//  ChatApp
//
//  Created by admin on 18/11/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import UIKit

class GroupUsersTableViewCell: UITableViewCell {

    @IBOutlet weak var imgUser: UIImageView!
    
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var lblUserType: UILabel!
    
    @IBOutlet weak var lblCellSeprator: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgUser.layer.masksToBounds = true
        imgUser.layer.cornerRadius = imgUser.frame.width/2.3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
