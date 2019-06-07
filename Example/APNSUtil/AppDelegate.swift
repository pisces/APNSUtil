//
//  AppDelegate.swift
//  APNSUtil
//
//  Created by pisces on 03/15/2018.
//  Copyright (c) 2018 pisces. All rights reserved.
//

import UIKit
import UserNotifications
import APNSUtil

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        APNSManager.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    // MARK: - Push Notification
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        APNSManager.shared.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        // <<your function to register device token on your server>>(APNSInstance.shared.tokenString)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    // MARK: - Push Notification for iOS 9
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        APNSManager.shared.application(application, didRegister: notificationSettings)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        APNSManager.shared.application(application, didReceiveRemoteNotification: userInfo)
    }
    
    // MARK: - Public Methods (UIApplicationDelegate - Local Notification)
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        APNSManager.shared.application(application, didReceive: notification)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        APNSManager.shared.userNotificationCenter(center, willPresent: notification)
    }
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        APNSManager.shared.userNotificationCenter(center, didReceive: response)
    }
}
