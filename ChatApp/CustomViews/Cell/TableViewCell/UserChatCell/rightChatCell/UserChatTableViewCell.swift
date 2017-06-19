//
//  UserChatTableViewCell.swift
//  ChatApp
//
//  Created by admin on 22/09/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import UIKit

class UserChatTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblText: UILabel!
    
    @IBOutlet weak var btnText: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        btnText.userInteractionEnabled = false

        // Configure the view for the selected state
    }
    
}
