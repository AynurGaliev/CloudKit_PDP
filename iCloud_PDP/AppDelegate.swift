//
//  AppDelegate.swift
//  iCloud_PDP
//
//  Created by Aynur Galiev on 15.06.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.requestForRemoteNotifications()
        
        let predicate = NSPredicate(format: "%K != %@", "name", "")
        let subscription = CKSubscription(recordType: "Album", predicate: predicate, options: [CKSubscriptionOptions.FiresOnRecordUpdate, CKSubscriptionOptions.FiresOnRecordCreation, CKSubscriptionOptions.FiresOnRecordDeletion])
        
        PUBLIC_DATABASE.saveSubscription(subscription) { (subscription: CKSubscription?, error: NSError?) in
            
            UI_THREAD {
                if let lError = error {
                    let alert = UIAlertController(title: "Error", message: lError.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil))
                    self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                } else {
                    
                }
            }
        }
        
        PRIVATE_DATABASE.saveSubscription(subscription) { (subscription: CKSubscription?, error: NSError?) in
            
            UI_THREAD {
                if let lError = error {
                    let alert = UIAlertController(title: "Error", message: lError.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil))
                    self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                } else {
                    
                }
            }
        }
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""

        for i in 0 ..< deviceToken.length {
            let formatString = "%02.2hhx"
            tokenString += String(format: formatString, arguments: [tokenChars[i]])
        }
        
        NSUserDefaults.standardUserDefaults().setObject(deviceToken, forKey: "tokenData")
        NSUserDefaults.standardUserDefaults().setObject(tokenString, forKey: "tokenString")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
    }
    
    func requestForRemoteNotifications () {
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Sound, UIUserNotificationType.Badge], categories: nil))
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
}

