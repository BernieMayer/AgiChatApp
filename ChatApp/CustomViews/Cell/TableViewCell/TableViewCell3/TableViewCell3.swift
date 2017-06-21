//
//  TableViewCell3.swift
//  ChatApp
//
//  Created by Anis Mansuri on 27/06/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import UIKit

class TableViewCell3: UITableViewCell {
    @IBOutlet var radioMale: UIButton!
    
    @IBOutlet var radioFemale: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let UNSELECTED = "radio_unselected"
        let SELECTED = "radio_selected"
        let checkImage = UIImage(named: SELECTED) as UIImage?
        let unCheckImage = UIImage(named: UNSELECTED) as UIImage?
        
        radioFemale.setImage(checkImage, for: UIControlState.selected)
        radioMale.setImage(checkImage, for: UIControlState.selected)
        
        
        radioMale.setImage(unCheckImage, for: UIControlState())
        radioFemale.setImage(unCheckImage, for: UIControlState())
        

        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
