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
        
        // For remote Notification
        if let _ = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as! [NSObject : AnyObject]? {
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        }
        
        let subscription = self.makeSubscription()
        self.subscribe(subscription, database: PUBLIC_DATABASE)
        self.subscribe(subscription, database: PRIVATE_DATABASE)
        
        return true
    }
    
    func makeSubscription() -> CKSubscription {
        
        let predicate = NSPredicate(format: "%K != %@", "title", "")
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.alertBody = "Your photos has been changed. Get more information :)"
        notificationInfo.shouldBadge = true
        notificationInfo.alertLaunchImage = "NotificationImage"
        
        let subscription = CKSubscription(recordType : "Photo",
                                          predicate  : predicate,
                                          options    : [CKSubscriptionOptions.FiresOnRecordUpdate,
                                                        CKSubscriptionOptions.FiresOnRecordCreation,
                                                        CKSubscriptionOptions.FiresOnRecordDeletion])
        subscription.notificationInfo = notificationInfo
        return subscription
    }
    
    func subscribe(subscription: CKSubscription, database: CKDatabase) {
        
        
        PRIVATE_DATABASE.saveSubscription(subscription) { (subscription: CKSubscription?, error: NSError?) in
            
            UI_THREAD {
                
                if let lError = error, let ckError = CKErrorCode(rawValue: lError.code) {
                    
                    switch ckError {
                    case .ServerRejectedRequest:
                        return
                    default:
                        let alert = UIAlertController(title: "Error", message: lError.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil))
                        self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                    }
                } else {
                    
                }
            }
        }

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
    
        guard let infoDict = userInfo as? [String : NSObject] else {
            completionHandler(UIBackgroundFetchResult.Failed)
            return
        }
        
        let _ = CKNotification(fromRemoteNotificationDictionary: infoDict)
        //make smth useful with notification
        completionHandler(UIBackgroundFetchResult.NewData)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        guard let infoDict = userInfo as? [String : NSObject] else {
            return
        }
        
        let _ = CKNotification(fromRemoteNotificationDictionary: infoDict)
        //make smth useful with notification
    }
    
    func requestForRemoteNotifications () {
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Sound, UIUserNotificationType.Badge], categories: nil))
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
}

