//
//  AppDelegate.swift
//  SKDCalendar
//
//  Created by Nick Kibish on 12.01.16.
//  Copyright © 2016 Nick Kibish. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Parse.setApplicationId("7C7UOwMg0Z1kSuLYrcbSoeT4M2AAnE66UrJnx9qu", clientKey: "aol0fQT09wZ1bxkAgYgbcB5hGzauFHuyOVRCjtjT")
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions);
        registerForRemoteNotifications()
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func registerForRemoteNotifications() {
        let application = UIApplication.sharedApplication()
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation["user"] = PFUser.currentUser()
        installation.saveInBackground()
    }
}

