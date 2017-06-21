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
public func ShowLoaderWithMessage(_ message:String) {
    startActivityAnimating(CGSize(width: 56, height: 56), message: message, type: NVActivityIndicatorType.ballSpinFadeLoader, color: UIColor(customColor: 143, green: 68, blue: 173, alpha: 1.0), padding: 2,isFromOnView: false)
}

//MARK:- ShowLoader
//Mark:-
public func ShowLoader() {
    startActivityAnimating(CGSize(width: 56, height: 56), message: nil, type: NVActivityIndicatorType.ballSpinFadeLoader, color: UIColor(customColor: 143, green: 68, blue: 173, alpha: 1.0), padding: 2,isFromOnView: false)
}

//MARK:- Hide Loader
//MARK:-
public func HideLoader() {
    stopActivityAnimating(false)
}

//MARK:- ShowLoaderOnView
//Mark:-
public func ShowLoaderOnView() {
    startActivityAnimating(CGSize(width: 56, height: 56), message: nil, type: NVActivityIndicatorType.ballSpinFadeLoader, color: UIColor(customColor: 143, green: 68, blue: 173, alpha: 1.0), padding: 2,isFromOnView: true)
}

//MARK:- HideLoaderOnView
//MARK:-
public func HideLoaderOnView() {
    stopActivityAnimating(true)
}

private func startActivityAnimating(_ size: CGSize? = nil, message: String? = nil, type: NVActivityIndicatorType? = nil, color: UIColor? = nil, padding: CGFloat? = nil, isFromOnView:Bool) {

    let activityContainer: UIView = UIView(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height))
    activityContainer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
    activityContainer.restorationIdentifier = activityRestorationIdentifier
    
    activityContainer.isUserInteractionEnabled = false
    let actualSize = size ?? CGSize(width: 56,height: 56)
    

    let activityIndicatorView = NVActivityIndicatorView(
        frame: CGRect(x: 0, y: 0, width: actualSize.width, height: actualSize.height),
        type: type!,
        color: color!,
        padding: padding!)
    
    activityIndicatorView.center = activityContainer.center
    //activityIndicatorView.hidesWhenStopped = true // TODO: ADD this line back in somehow
    activityIndicatorView.startAnimating()
    activityContainer.addSubview(activityIndicatorView)
    
    if message != nil {
        let width = activityContainer.frame.size.width / 2
        if let message = message, !message.isEmpty {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 30))
            label.center = CGPoint(
                x: activityIndicatorView.center.x,
                y: activityIndicatorView.center.y + actualSize.height)
            label.textAlignment = .center
            label.text = message
            label.textColor = activityIndicatorView.color
            activityContainer.addSubview(label)
        }
    }
    UIApplication.shared.keyWindow?.isUserInteractionEnabled = false
    if isFromOnView == true {
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(activityContainer)
    }
    else {
        UIApplication.shared.keyWindow?.addSubview(activityContainer)
    }
}


/**
 Stop animation and remove from view hierarchy.
 */
private func stopActivityAnimating(_ isFromOnView:Bool) {
    UIApplication.shared.keyWindow?.isUserInteractionEnabled = true
    if isFromOnView == true {
        for item in (UIApplication.shared.keyWindow?.rootViewController?.view.subviews)!
            where item.restorationIdentifier == activityRestorationIdentifier {
                item.removeFromSuperview()
        }
    }
    else {
        for item in (UIApplication.shared.keyWindow?.subviews)!
            where item.restorationIdentifier == activityRestorationIdentifier {
                item.removeFromSuperview()
        }
    }
}

