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
        
        radioFemale.setImage(checkImage, forState: UIControlState.Selected)
        radioMale.setImage(checkImage, forState: UIControlState.Selected)
        
        
        radioMale.setImage(unCheckImage, forState: UIControlState.Normal)
        radioFemale.setImage(unCheckImage, forState: UIControlState.Normal)
        

        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
