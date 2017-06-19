//
//  BaseViewController.swift
//  ChatApp
//
//  Created by Anis Mansuri on 23/06/16.
//  Copyright © 2016 Agile. All rights reserved.
//
//
//  BaseViewController.swift
//  ChatApp
//
//  Created by agile on 16/03/16.
//  Copyright © 2016 agile. All rights reserved.
//

import UIKit
import SystemConfiguration
import Foundation


let internetAlert:String = "Please check your internet connection and try again."
//MARK: - ACCEPTED_CHARACTERS

let ACCEPTED_ALPHABATS: NSCharacterSet = NSCharacterSet(charactersInString: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.").invertedSet
let ACCEPTED_NUMERICS: NSCharacterSet = NSCharacterSet(charactersInString: "1234567890").invertedSet
let ACCEPTED_ALPHANUMERICS: NSCharacterSet = NSCharacterSet(charactersInString: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890. ").invertedSet

let ACCEPTED_EMAIL: NSCharacterSet = NSCharacterSet(charactersInString: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@_-.").invertedSet


@available(iOS 9.0, *)
class BaseViewController: UIViewController
{
    let MAIN_SCREEN = UIScreen.mainScreen()
    let MAIN_HEIGHT = UIScreen.mainScreen().bounds.height
    let MAIN_WIDTH = UIScreen.mainScreen().bounds.width
    
    let IMAGE_HEIGHT = UIScreen.mainScreen().bounds.height/100*45
    var  appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    
    var navigationColor:UIColor = UIColor(customColor: 29, green: 103, blue: 241, alpha: 1.0);
    
    
    
    //       FONTS
    ////////////////////////////
    
    var regularFontFamily:String = "Calibri"
    var boldFontFamily:String = "Calibri-Bold"
    var italicFontFamily:String = "Calibri-Italic"
    
    override func viewWillAppear(animated: Bool) {
        // navigationController!.navigationBar.barTintColor = UIColor.greenColor()
        hideNavigationBar()
        
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        return UIStatusBarStyle.LightContent
    }
    
    //MARK:- Email Validation
    //MARK:-
    func isValidEmail(value:String) -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(value)
    }
    
    //MARK:- UIView set
    //MArK:-
    func applyPlainShadow(view: UIView) {
        
        let layer = view.layer
        layer.shadowColor = UIColor.grayColor().CGColor
        layer.shadowOffset = CGSize(width:1 , height: 1)
        layer.shadowOpacity = 1
        layer.shadowRadius = 1
        layer.cornerRadius = 2
    }
    
    
    //MARK:- Set Color
    //MARK:-
    func ColorCode(red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat) -> UIColor
    {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}
