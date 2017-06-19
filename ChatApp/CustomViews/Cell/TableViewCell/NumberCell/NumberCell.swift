//
//  NumberCell.swift
//  ChatApp
//
//  Created by Anis Mansuri on 27/06/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import UIKit

class NumberCell: UITableViewCell {
    
    @IBOutlet var shadowView: UIView!
    
    @IBOutlet var btnCall: UIButton!
    
    @IBOutlet var btnMsg: UIButton!
    
    @IBOutlet var lblPhoneNumber: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(customColor: 245, green: 245, blue: 245, alpha: 1)
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
