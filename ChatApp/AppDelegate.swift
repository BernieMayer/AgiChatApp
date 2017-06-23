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
import UserNotifications

@available(iOS 9.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, FIRMessagingDelegate {
    
    var window: UIWindow?
    var contactStore = CNContactStore()
    var navVC : UINavigationController?
    
    // The callback to handle data message received via FCM for devices running iOS 10 or above.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        NSLog("$$$ app start $$$")
        Foundation.UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        Fabric.with([Digits.self])
        FIRApp.configure()
        GADMobileAds.configure(withApplicationID: appIdforAd)
        FIRDatabase.database().persistenceEnabled = true
        ref.keepSynced(true)
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            FIRMessaging.messaging().remoteMessageDelegate = self
        } else {
        
        
        //Register for remote notification
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        FIRMessaging.messaging().subscribe(toTopic: "/topics/condition1")
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(self.tokenRefreshNotification),
                                                         name: NSNotification.Name.firInstanceIDTokenRefresh,
                                                         object: nil)
        
        if (launchOptions == nil) {
            //opened app without a push notification.
            
            //Login Session
            if(AppState.sharedInstance.signedIn == true || Foundation.UserDefaults.standard.bool(forKey: "signedIn") == true)
            {
                //get current user data of logged in user
                getCurrentUser((Foundation.UserDefaults.standard.value(forKey: "mobile") as! String), completionHandler: { (status) in
                    
                })
                
                //Navigate to tab view controller
                let mainStoryBoard =  UIStoryboard(name: "Main", bundle: nil)
                let tabVC : TabViewController = mainStoryBoard.instantiateViewController(withIdentifier: "TabViewController") as! TabViewController
                let navigationController = UINavigationController(rootViewController: tabVC)
                self.window?.rootViewController = navigationController
            }
            else
            {
                
               // For New User that is to be registered
                let mainStoryBoard =  UIStoryboard(name: "Main", bundle: nil)
                let loginVC : LoginViewController = mainStoryBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                let navigationController = UINavigationController(rootViewController: loginVC)
                self.window?.rootViewController = navigationController
            }
        }
        return true
    }
    
    
    //MARK:- REMOTE NOTIFICATION
    //MARK:-
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
       
        
        if(application.applicationState == UIApplicationState.active){
            
        }else{
            
            application.applicationIconBadgeNumber = 0 //Setting badge to 0 on opening chat
            application.cancelAllLocalNotifications() //Cancels all notification
            let mainStoryBoard =  UIStoryboard(name: "Main", bundle: nil)
            let tabVC : TabViewController = mainStoryBoard.instantiateViewController(withIdentifier: "TabViewController") as! TabViewController
            let navigationController = UINavigationController(rootViewController: tabVC)
            self.window?.rootViewController = navigationController
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        if let refreshedToken1 = FIRInstanceID.instanceID().token()
        {
            if refreshedToken1.length > 0
            {
                //Check if user is signed in or not to perform below task
                if(AppState.sharedInstance.signedIn == true || Foundation.UserDefaults.standard.bool(forKey: "signedIn") == true)
                {
                    Foundation.UserDefaults.standard.set(refreshedToken1, forKey: "device_key")
                    let currentId = UserDefaults.sharedInstance.GetNSUserDefaultValue(currentUserId)
                    //Updating device token of current user in Database
                    ref.child("users").child(currentId).updateChildValues(["deviceToken" : refreshedToken1])
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("---------------FAILED TO RECIEVE NOTIFICATION-----------")
        print(error)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK:- [START refresh_token]
    func tokenRefreshNotification(_ notification: Notification) {
        
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            if(refreshedToken.length > 0)
            {
                Foundation.UserDefaults.standard.set(refreshedToken, forKey: "device_key")
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
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
            
                print("Unable to connect with FCM. \(error)")
           
            } else {
              
                NSLog("Connected to FCM.")
                
            }
        }
    }
    
    
}

