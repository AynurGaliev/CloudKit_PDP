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
        if let _ = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject]? {
            
        }
        
        let subscription = self.makeSubscription()
        self.subscribe(subscription, database: PUBLIC_DATABASE)
        self.subscribe(subscription, database: PRIVATE_DATABASE)
        
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        completionHandler()
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        completionHandler()
    }
    
    func makeSubscription() -> CKSubscription {
        
        let predicate = NSPredicate(format: "%K != %@", "title", "")
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.alertBody = "Your photos has been changed. Get more information :)"
        notificationInfo.shouldBadge = true
        notificationInfo.alertLaunchImage = "apples"
        if #available(iOS 9.0, *) {
            notificationInfo.category = "com.remoteNotifications.Action Category"
        }
        
        let subscription = CKSubscription(recordType : "Photo",
                                          predicate  : predicate,
                                          options    : [CKSubscriptionOptions.FiresOnRecordUpdate,
                                                        CKSubscriptionOptions.FiresOnRecordCreation,
                                                        CKSubscriptionOptions.FiresOnRecordDeletion])
        subscription.notificationInfo = notificationInfo
        return subscription
    }
    
    func subscribe(subscription: CKSubscription, database: CKDatabase) {
        
        database.saveSubscription(subscription) { (subscription: CKSubscription?, error: NSError?) in
            
            UI_THREAD {
                
                if let lError = error, let ckError = CKErrorCode(rawValue: lError.code) {
                    
                    switch ckError {
                    case .ServerRejectedRequest:
                        return
                    case .NotAuthenticated:
                        let alert = UIAlertController(title: "Error", message: lError.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil))
                        alert.addAction(UIAlertAction(title: "Go to settings", style: UIAlertActionStyle.Default, handler: { Void in
                            if UIApplication.sharedApplication().canOpenURL(NSURL(string: "prefs:root=CASTLE")!) {
                                UIApplication.sharedApplication().openURL(NSURL(string: "prefs:root=CASTLE")!)
                            } else {
                                let alert = UIAlertController(title: "Error", message: "Failed to open iCloud settings", preferredStyle: UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil))
                                self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                            }
                        }))
                        UI_THREAD {
                            self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                        }
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

        let action1 = UIMutableUserNotificationAction()
        if #available(iOS 9.0, *) {
            action1.behavior = .TextInput
        }
        action1.activationMode = .Foreground
        action1.title = "Action 1"
        action1.identifier = "com.remoteNotifications.Action1"
        action1.destructive = true
        action1.authenticationRequired = true
        
        let action2 = UIMutableUserNotificationAction()
        action2.activationMode = .Background
        action2.title = "Action 2"
        action2.identifier = "com.remoteNotifications.Action2"
        action2.destructive = false
        action2.authenticationRequired = false
        
        let actionCategory = UIMutableUserNotificationCategory()
        actionCategory.identifier = "com.remoteNotifications.Action Category"
        actionCategory.setActions([action1, action2], forContext: UIUserNotificationActionContext.Default)
        actionCategory.setActions([action1, action2], forContext: UIUserNotificationActionContext.Minimal)
        
        let categories = Set<UIUserNotificationCategory>([actionCategory])
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Sound, UIUserNotificationType.Badge]
        
        let settings = UIUserNotificationSettings(forTypes: notificationTypes, categories: categories)

        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
}

