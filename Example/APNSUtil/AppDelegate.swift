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
        APNSManager.shared.didFinishLaunching(withOptions: launchOptions)
        return true
    }
    
    // MARK: - Push Notification
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        APNSManager.shared.registerDeviceToken(deviceToken)
        // <<your function to register device token on your server>>(APNSInstance.shared.tokenString)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    // MARK: - Push Notification for iOS 9
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        APNSManager.shared.didReceive(userInfo: userInfo, isInactive: application.applicationState == .inactive)
    }
    
    // MARK: - Push Notification for iOS 10 or higher
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        APNSManager.shared.didReceive(userInfo: notification.request.content.userInfo, isInactive: false)
    }
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        APNSManager.shared.didReceive(userInfo: response.notification.request.content.userInfo, isInactive: true)
    }
}

