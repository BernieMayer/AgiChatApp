//
//  leftChatTableViewCell.swift
//  ChatApp
//
//  Created by admin on 22/09/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import UIKit

class leftChatTableViewCell: UITableViewCell {

    
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    
    @IBOutlet weak var btnText: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        btnText.isUserInteractionEnabled = false
    
        // Configure the view for the selected state
    }
    
}
