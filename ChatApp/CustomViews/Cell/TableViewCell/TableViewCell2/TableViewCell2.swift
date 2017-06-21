//
//  TableViewCell2.swift
//  ChatApp
//
//  Created by Anis Mansuri on 27/06/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import UIKit

class TableViewCell2: UITableViewCell {
    
    @IBOutlet var txtDate: TJTextField!
    
    
    @IBOutlet weak var btnDatePicker: UIButton!
    @IBOutlet var txtMonth: TJTextField!
    
    @IBOutlet var txtYear: TJTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
