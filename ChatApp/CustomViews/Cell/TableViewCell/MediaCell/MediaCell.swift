//
//  MediaCell.swift
//  ChatApp
//
//  Created by Anis Mansuri on 27/06/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import UIKit

class MediaCell: UITableViewCell {
    
    @IBOutlet var shadowView: UIView!
    
    @IBOutlet var lblMediaCount: UILabel!
    
    @IBOutlet var imgaeCollectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(customColor: 245, green: 245, blue: 245, alpha: 1)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
