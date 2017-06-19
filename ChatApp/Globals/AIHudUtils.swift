//
//  AIHudUtils.swift
//  Arrangd
//
//  Created by Agile-mac on 19/12/16.
//  Copyright © 2016 Harsh. All rights reserved.
//

import Foundation
import NVActivityIndicatorView


private var activityRestorationIdentifier: String {
    return "NVActivityIndicatorViewContainer"
}

/**
 Create a activity indicator view with specified frame, type, color and padding and start animation.
 
 - parameter size: activity indicator view's size. Default size is 60x60.
 - parameter message: message under activity indicator view.
 - parameter type: animation type, value of NVActivityIndicatorType enum. Default type is BallSpinFadeLoader.
 - parameter color: color of activity indicator view. Default color is white.
 - parameter padding: view's padding. Default padding is 0.
 */

//MARK:- Show Loader With Messsage
//MARK:-
public func ShowLoaderWithMessage(message:String) {
    startActivityAnimating(CGSizeMake(56, 56), message: message, type: NVActivityIndicatorType.BallSpinFadeLoader, color: UIColor(customColor: 143, green: 68, blue: 173, alpha: 1.0), padding: 2,isFromOnView: false)
}

//MARK:- ShowLoader
//Mark:-
public func ShowLoader() {
    startActivityAnimating(CGSizeMake(56, 56), message: nil, type: NVActivityIndicatorType.BallSpinFadeLoader, color: UIColor(customColor: 143, green: 68, blue: 173, alpha: 1.0), padding: 2,isFromOnView: false)
}

//MARK:- Hide Loader
//MARK:-
public func HideLoader() {
    stopActivityAnimating(false)
}

//MARK:- ShowLoaderOnView
//Mark:-
public func ShowLoaderOnView() {
    startActivityAnimating(CGSizeMake(56, 56), message: nil, type: NVActivityIndicatorType.BallSpinFadeLoader, color: UIColor(customColor: 143, green: 68, blue: 173, alpha: 1.0), padding: 2,isFromOnView: true)
}

//MARK:- HideLoaderOnView
//MARK:-
public func HideLoaderOnView() {
    stopActivityAnimating(true)
}

private func startActivityAnimating(size: CGSize? = nil, message: String? = nil, type: NVActivityIndicatorType? = nil, color: UIColor? = nil, padding: CGFloat? = nil, isFromOnView:Bool) {

    let activityContainer: UIView = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width,UIScreen.mainScreen().bounds.height))
    activityContainer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
    activityContainer.restorationIdentifier = activityRestorationIdentifier
    
    activityContainer.userInteractionEnabled = false
    let actualSize = size ?? CGSizeMake(56,56)
    

    let activityIndicatorView = NVActivityIndicatorView(
        frame: CGRectMake(0, 0, actualSize.width, actualSize.height),
        type: type!,
        color: color!,
        padding: padding!)
    
    activityIndicatorView.center = activityContainer.center
    activityIndicatorView.hidesWhenStopped = true
    activityIndicatorView.startAnimating()
    activityContainer.addSubview(activityIndicatorView)
    
    if message != nil {
        let width = activityContainer.frame.size.width / 2
        if let message = message where !message.isEmpty {
            let label = UILabel(frame: CGRectMake(0, 0, width, 30))
            label.center = CGPointMake(
                activityIndicatorView.center.x,
                activityIndicatorView.center.y + actualSize.height)
            label.textAlignment = .Center
            label.text = message
            label.textColor = activityIndicatorView.color
            activityContainer.addSubview(label)
        }
    }
    UIApplication.sharedApplication().keyWindow?.userInteractionEnabled = false
    if isFromOnView == true {
        UIApplication.sharedApplication().keyWindow?.rootViewController?.view.addSubview(activityContainer)
    }
    else {
        UIApplication.sharedApplication().keyWindow?.addSubview(activityContainer)
    }
}


/**
 Stop animation and remove from view hierarchy.
 */
private func stopActivityAnimating(isFromOnView:Bool) {
    UIApplication.sharedApplication().keyWindow?.userInteractionEnabled = true
    if isFromOnView == true {
        for item in (UIApplication.sharedApplication().keyWindow?.rootViewController?.view.subviews)!
            where item.restorationIdentifier == activityRestorationIdentifier {
                item.removeFromSuperview()
        }
    }
    else {
        for item in (UIApplication.sharedApplication().keyWindow?.subviews)!
            where item.restorationIdentifier == activityRestorationIdentifier {
                item.removeFromSuperview()
        }
    }
}

