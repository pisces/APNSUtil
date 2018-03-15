//
//  APNSManager.swift
//  APNSUtil
//
//  Created by pisces on 12/01/2018.
//  Copyright © 2018 pisces. All rights reserved.
//

import UIKit
import UserNotifications
import ObjectMapper

public class APNSManager {
    
    // MARK: - Constants
    
    public typealias Processing = (RemoteNotificationElement) -> Void
    
    public static let shared = APNSManager()
    private let kAuthorizationStatusDetermined: String = "kAuthorizationStatusDetermined"
    
    // MARK: - Properties
    
    private var isInitialized: Bool = false
    private var types: UIUserNotificationType = [.sound, .alert, .badge]
    private var processingClosureMap = [Int: Processing]()
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
    public func begin() -> APNSManager {
        isInitialized = true
        dequeue()
        return self
    }
    public func didReceive<T: Mappable>(userInfo: [AnyHashable : Any], as: T.Type, isInactive: Bool) {
        let map = Map(mappingType: .fromJSON, JSON: userInfo as! [String: Any])
        let model = T.init(map: map)!
        enqueue(RemoteNotificationElement(isInactive: isInactive, model: model)).dequeue()
    }
    public func processing(_ subscribable: Subscribable, _ closure: @escaping Processing) -> APNSManager {
        guard processingClosureMap[subscribable.hash] == nil else {return self}
        processingClosureMap[subscribable.hash] = closure
        return self
    }
    public func register() -> APNSManager {
        if #available(iOS 10.0, *) {
            let options: () -> UNAuthorizationOptions = {
                var rawValue: UInt = 0
                if self.types.rawValue & UIUserNotificationType.alert.rawValue == UIUserNotificationType.alert.rawValue {
                    rawValue |= UNAuthorizationOptions.alert.rawValue
                }
                if self.types.rawValue & UIUserNotificationType.sound.rawValue == UIUserNotificationType.sound.rawValue {
                    rawValue |= UNAuthorizationOptions.sound.rawValue
                }
                if self.types.rawValue & UIUserNotificationType.badge.rawValue == UIUserNotificationType.badge.rawValue {
                    rawValue |= UNAuthorizationOptions.badge.rawValue
                }
                return UNAuthorizationOptions(rawValue: rawValue)
            }
            
            let center = UNUserNotificationCenter.current()
            center.delegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate!
            center.requestAuthorization(options: options()) { (granted, error) in
                if let error = error {
                    print("Push registration failed")
                    print("ERROR: \(error.localizedDescription) - \(error.localizedDescription)")
                    return
                }
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: types, categories: nil))
        }
        isAuthorizationStatusDetermined = true
        return self
    }
    public func registerDeviceToken(_ deviceToken: Data) {
        APNSInstance.shared.setAPNSToken(deviceToken)
    }
    public func setTypes(_ types: UIUserNotificationType) -> APNSManager {
        self.types = types
        return self
    }
    public func unregister() {
        processingClosureMap.removeAll()
        UIApplication.shared.unregisterForRemoteNotifications()
        APNSInstance.shared.clear()
        elements.removeAll()
        isAuthorizationStatusDetermined = true
    }
    public func unsubscribe(_ subscribable: Subscribable) {
        processingClosureMap.removeValue(forKey: subscribable.hash)
    }
    
    // MARK: - Private methods
    
    private func dequeue() {
        guard isInitialized, elements.count > 0 else {return}
        processingClosureMap.forEach { $0.value(elements.first!) }
        elements.remove(at: 0)
        dequeue()
    }
    @discardableResult
    private func enqueue(_ element: RemoteNotificationElement) -> APNSManager {
        elements.append(element)
        return self
    }
}

public struct RemoteNotificationElement {
    public typealias T = Mappable
    
    public private(set) var isInactive: Bool = false
    private var model: T!
    
    public init(isInactive: Bool, model: T) {
        self.isInactive = isInactive
        self.model = model
    }
    
    public func payload<E: Mappable>() -> E {
        return model as! E
    }
}

public protocol Subscribable {
    var hash: Int {get}
}

extension NSObject: Subscribable {}
