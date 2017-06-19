//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Anis Mansuri on 23/06/16.
//  Copyright © 2016 Agile. All rights reserved.
//

import UIKit
import Fabric
import Firebase
import DigitsKit
import Contacts

@available(iOS 9.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var contactStore = CNContactStore()
    var navVC : UINavigationController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        NSLog("$$$ app start $$$")
        NSUserDefaults.standardUserDefaults().setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        Fabric.with([Digits.self])
        FIRApp.configure()
        GADMobileAds.configureWithApplicationID(appIdforAd)
        FIRDatabase.database().persistenceEnabled = true
        ref.keepSynced(true)
             
        //Register for remote notification
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        // Add observer for InstanceID token refresh callback.
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.tokenRefreshNotification),
                                                         name: kFIRInstanceIDTokenRefreshNotification,
                                                         object: nil)
        
        if (launchOptions == nil) {
            //opened app without a push notification.
            
            //Login Session
            if(AppState.sharedInstance.signedIn == true || NSUserDefaults.standardUserDefaults().boolForKey("signedIn") == true)
            {
                //get current user data of logged in user
                getCurrentUser((NSUserDefaults.standardUserDefaults().valueForKey("mobile") as! String), completionHandler: { (status) in
                    
                })
                
                //Navigate to tab view controller
                let mainStoryBoard =  UIStoryboard(name: "Main", bundle: nil)
                let tabVC : TabViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("TabViewController") as! TabViewController
                let navigationController = UINavigationController(rootViewController: tabVC)
                self.window?.rootViewController = navigationController
            }
            else
            {
                
               // For New User that is to be registered
                let mainStoryBoard =  UIStoryboard(name: "Main", bundle: nil)
                let loginVC : LoginViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                let navigationController = UINavigationController(rootViewController: loginVC)
                self.window?.rootViewController = navigationController
            }
        }
        return true
    }
    
    
    //MARK:- REMOTE NOTIFICATION
    //MARK:-
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                     fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        if(application.applicationState == UIApplicationState.Active){
            
        }else{
            
            application.applicationIconBadgeNumber = 0 //Setting badge to 0 on opening chat
            application.cancelAllLocalNotifications() //Cancels all notification
            let mainStoryBoard =  UIStoryboard(name: "Main", bundle: nil)
            let tabVC : TabViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("TabViewController") as! TabViewController
            let navigationController = UINavigationController(rootViewController: tabVC)
            self.window?.rootViewController = navigationController
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        if let refreshedToken1 = FIRInstanceID.instanceID().token()
        {
            if refreshedToken1.length > 0
            {
                //Check if user is signed in or not to perform below task
                if(AppState.sharedInstance.signedIn == true || NSUserDefaults.standardUserDefaults().boolForKey("signedIn") == true)
                {
                    NSUserDefaults.standardUserDefaults().setObject(refreshedToken1, forKey: "device_key")
                    let currentId = UserDefaults.sharedInstance.GetNSUserDefaultValue(currentUserId)
                    //Updating device token of current user in Database
                    ref.child("users").child(currentId).updateChildValues(["deviceToken" : refreshedToken1])
                }
            }
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
        print("---------------FAILED TO RECIEVE NOTIFICATION-----------")
        print(error)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK:- [START refresh_token]
    func tokenRefreshNotification(notification: NSNotification) {
        
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            if(refreshedToken.length > 0)
            {
                NSUserDefaults.standardUserDefaults().setObject(refreshedToken, forKey: "device_key")
                print("----------------INSTANCE ID TOKEN------------")
                NSLog("InstanceID token: \(refreshedToken)")
            }
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    //MARK:- [END refresh_token]
    
    //MARK:- [START connect_to_fcm]
    func connectToFcm() {
        FIRMessaging.messaging().connectWithCompletion { (error) in
            if (error != nil) {
            
                print("Unable to connect with FCM. \(error)")
           
            } else {
              
                NSLog("Connected to FCM.")
                
            }
        }
    }
    
    
}

