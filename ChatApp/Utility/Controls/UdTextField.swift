//
//  UdTextField.swift
//  Udgam
//
//  Created by agile on 16/03/16.
//  Copyright © 2016 agile. All rights reserved.
//

import Foundation
import UIKit

class UdTextField: UITextField {

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
       
        //TODO: Had to change this in order to get the application to run
        /*
        if action == #selector(NSObject.paste(_:)) {
            return false
        }*/
        return super.canPerformAction(action, withSender: sender)
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        //self.layer.cornerRadius = 5.0;
       // self.layer.borderColor = UIColor.grayColor().CGColor
        //self.layer.borderWidth = 1.5
       // self.backgroundColor = UIColor.blueColor()
        //self.textColor = UIColor.whiteColor()
        //self.tintColor = UIColor.purpleColor()
        
       
        
        self.borderStyle = UITextBorderStyle.none
        
        
        
        
    }

}
