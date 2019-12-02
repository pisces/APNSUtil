//
//  MIT License
//
//  Copyright (c) 2019 Steve Kim
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  APNSManager.swift
//  APNSUtil
//
//  Created by pisces on 12/01/2018.
//  Copyright © 2019 Steve Kim. All rights reserved.
//

import UIKit
import UserNotifications

public class APNSManager {
    
    // MARK: - Public Constants
    
    public typealias SubscribeClosure = (RemoteNotificationElement) -> Void
    
    public static let shared = APNSManager()
    private let kAuthorizationStatusDetermined: String = "kAuthorizationStatusDetermined"
    
    // MARK: - Public Properties
    
    private(set) var isAuthorizationStatusDetermined: Bool {
        get {
            return UserDefaults.standard.bool(forKey: kAuthorizationStatusDetermined)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kAuthorizationStatusDetermined)
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: - Private Properties
    
    private var isInitialized = false
    private var types: UIUserNotificationType = [.sound, .alert, .badge]
    private var subscribeClosureMap = [Int: SubscribeClosure]()
    private var elements = [RemoteNotificationElement]()
    
    // MARK: - Public Methods
    
    @discardableResult
    public func begin() -> Self {
        isInitialized = true
        dequeue()
        return self
    }
    public func register() -> Self {
        #if !APP_EXTENSIONS
        if #available(iOS 10.0, *) {
            let types = self.types
            let options: () -> UNAuthorizationOptions = {
                var rawValue: UInt = 0
                if types.rawValue & UIUserNotificationType.alert.rawValue == UIUserNotificationType.alert.rawValue {
                    rawValue |= UNAuthorizationOptions.alert.rawValue
                }
                if types.rawValue & UIUserNotificationType.sound.rawValue == UIUserNotificationType.sound.rawValue {
                    rawValue |= UNAuthorizationOptions.sound.rawValue
                }
                if types.rawValue & UIUserNotificationType.badge.rawValue == UIUserNotificationType.badge.rawValue {
                    rawValue |= UNAuthorizationOptions.badge.rawValue
                }
                return UNAuthorizationOptions(rawValue: rawValue)
            }
            
            let center = UNUserNotificationCenter.current()
            center.delegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate
            center.requestAuthorization(options: options()) { (granted, error) in
                guard error == nil else {return}
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: types, categories: nil))
        }
        isAuthorizationStatusDetermined = true
        #endif
        return self
    }
    public func registerDeviceToken(_ deviceToken: Data) {
        APNSInstance.shared.setAPNSToken(deviceToken)
    }
    public func setTypes(_ types: UIUserNotificationType) -> Self {
        self.types = types
        return self
    }
    public func subscribe<T: Hashable>(_ target: T, _ closure: @escaping SubscribeClosure) -> Self {
        guard subscribeClosureMap[target.hashValue] == nil else {return self}
        subscribeClosureMap[target.hashValue] = closure
        return self
    }
    public func unregister() {
        subscribeClosureMap.removeAll()
        #if !APP_EXTENSIONS
        UIApplication.shared.unregisterForRemoteNotifications()
        #endif
        APNSInstance.shared.clear()
        elements.removeAll()
        isAuthorizationStatusDetermined = true
    }
    public func unsubscribe<T: Hashable>(_ target: T) {
        subscribeClosureMap.removeValue(forKey: target.hashValue)
    }
    
    // MARK: - Private Methods
    
    private func dequeue() {
        guard isInitialized, elements.count > 0 else {return}
        let element = elements.removeFirst()
        subscribeClosureMap.forEach { $0.value(element) }
        dequeue()
    }
    private func didReceive(userInfo: [AnyHashable : Any], isInactive: Bool) {
        enqueue(.init(isInactive: isInactive, userInfo: userInfo)).dequeue()
    }
    @discardableResult
    private func enqueue(_ element: RemoteNotificationElement) -> Self {
        elements.append(element)
        return self
    }
}

#if !APP_EXTENSIONS
extension APNSManager {
    
    // MARK: - Public Methods (Launching)
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard #available(iOS 10.0, *) else {
            let remote = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]
            let local = launchOptions?[UIApplication.LaunchOptionsKey.localNotification] as? [AnyHashable: Any]
            guard let userInfo = remote ?? local else {return}
            didReceive(userInfo: userInfo, isInactive: true)
            return
        }
    }
    
    // MARK: - Public Methods (Register device token)
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        registerDeviceToken(deviceToken)
    }
    
    // MARK: - Public Methods (Push Notification for iOS 9)
    
    public func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        guard #available(iOS 10.0, *) else {
            application.registerForRemoteNotifications()
            return
        }
    }
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        guard #available(iOS 10.0, *) else {
            didReceive(userInfo: userInfo, isInactive: application.applicationState == .inactive)
            return
        }
    }
    
    // MARK: - Public Methods (Local Notification)
    
    public func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        didReceive(userInfo: notification.userInfo ?? [:], isInactive: application.applicationState == .inactive)
    }
    
    // MARK: - Public Methods (Push Notification for iOS 9)
    
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) {
        didReceive(userInfo: notification.request.content.userInfo, isInactive: false)
    }
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) {
        didReceive(userInfo: response.notification.request.content.userInfo, isInactive: true)
    }
}
#endif

public struct RemoteNotificationElement {
    public let isInactive: Bool
    public let userInfo: [AnyHashable : Any]
    
    public init(isInactive: Bool, userInfo: [AnyHashable : Any]) {
        self.isInactive = isInactive
        self.userInfo = userInfo
    }
    
    public func payload<T: Decodable>() -> T? {
        do {
            let data = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }
}
