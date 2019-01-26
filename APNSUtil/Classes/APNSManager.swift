//
//  APNSManager.swift
//  APNSUtil
//
//  Created by pisces on 12/01/2018.
//  Copyright © 2018 pisces. All rights reserved.
//

import UIKit
import UserNotifications

public class APNSManager {
    
    // MARK: - Constants
    
    public typealias SubscribeClosure = (RemoteNotificationElement) -> Void
    
    public static let shared = APNSManager()
    private let kAuthorizationStatusDetermined: String = "kAuthorizationStatusDetermined"
    
    // MARK: - Properties
    
    private var isInitialized: Bool = false
    private var types: UIUserNotificationType = [.sound, .alert, .badge]
    private var subscribeClosureMap = [Int: SubscribeClosure]()
    private var elements = [RemoteNotificationElement]()
    private(set) var isAuthorizationStatusDetermined: Bool {
        get {
            return UserDefaults.standard.bool(forKey: kAuthorizationStatusDetermined)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kAuthorizationStatusDetermined)
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: - Public methods
    
    @discardableResult
    public func begin() -> Self {
        isInitialized = true
        dequeue()
        return self
    }
    public func didFinishLaunching(withOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        let remote = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]
        let local = launchOptions?[UIApplicationLaunchOptionsKey.localNotification] as? [AnyHashable: Any]
        guard let userInfo = remote ?? local else {return}
        didReceive(userInfo: userInfo, isInactive: true)
    }
    public func didReceive(userInfo: [AnyHashable : Any], isInactive: Bool) {
        enqueue(.init(isInactive: isInactive, userInfo: userInfo)).dequeue()
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
    
    // MARK: - Private methods
    
    private func dequeue() {
        guard isInitialized, elements.count > 0 else {return}
        let element = elements.removeFirst()
        subscribeClosureMap.forEach { $0.value(element) }
        dequeue()
    }
    @discardableResult
    private func enqueue(_ element: RemoteNotificationElement) -> Self {
        elements.append(element)
        return self
    }
}

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
