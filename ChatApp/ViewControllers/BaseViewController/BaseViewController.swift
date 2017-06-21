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

let ACCEPTED_ALPHABATS: CharacterSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.").inverted
let ACCEPTED_NUMERICS: CharacterSet = CharacterSet(charactersIn: "1234567890").inverted
let ACCEPTED_ALPHANUMERICS: CharacterSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890. ").inverted

let ACCEPTED_EMAIL: CharacterSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@_-.").inverted


@available(iOS 9.0, *)
class BaseViewController: UIViewController
{
    let MAIN_SCREEN = UIScreen.main
    let MAIN_HEIGHT = UIScreen.main.bounds.height
    let MAIN_WIDTH = UIScreen.main.bounds.width
    
    let IMAGE_HEIGHT = UIScreen.main.bounds.height/100*45
    var  appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    var navigationColor:UIColor = UIColor(customColor: 29, green: 103, blue: 241, alpha: 1.0);
    
    
    
    //       FONTS
    ////////////////////////////
    
    var regularFontFamily:String = "Calibri"
    var boldFontFamily:String = "Calibri-Bold"
    var italicFontFamily:String = "Calibri-Italic"
    
    override func viewWillAppear(_ animated: Bool) {
        // navigationController!.navigationBar.barTintColor = UIColor.greenColor()
        hideNavigationBar()
        
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        
        return UIStatusBarStyle.lightContent
    }
    
    //MARK:- Email Validation
    //MARK:-
    func isValidEmail(_ value:String) -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: value)
    }
    
    //MARK:- UIView set
    //MArK:-
    func applyPlainShadow(_ view: UIView) {
        
        let layer = view.layer
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width:1 , height: 1)
        layer.shadowOpacity = 1
        layer.shadowRadius = 1
        layer.cornerRadius = 2
    }
    
    
    //MARK:- Set Color
    //MARK:-
    func ColorCode(_ red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat) -> UIColor
    {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}
