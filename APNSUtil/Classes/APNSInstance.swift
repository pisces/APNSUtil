//
//  APNSInstance.swift
//  APNSUtil
//
//  Created by pisces on 12/01/2018.
//  Copyright © 2018 pisces. All rights reserved.
//

import Foundation

@objc public class APNSInstance: NSObject {
    
    // MARK: - Constants
    
    private struct Const {
        static let keyForAPNSInstance = "APNSInstance.shared"
    }
    
    public static let shared = decodeInstance()
    
    // MARK: - Properties
    
    public private(set) var tokenString: String?
    public private(set) var token: Data?
    
    // MARK: - Con(De)structor
    
    public override init() {
        super.init()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        
        decodeProperties(with: aDecoder)
    }
    
    // MARK: - Public methods
    
    public func clear() {
        token = nil
        
        UserDefaults.standard.removeObject(forKey: Const.keyForAPNSInstance)
        UserDefaults.standard.synchronize()
    }
    public func setAPNSToken(_ token: Data) {
        self.token = token
        tokenString = token.reduce("", { $0 + String(format: "%02X", $1) })
        
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: self), forKey: Const.keyForAPNSInstance)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Private methods
    
    private class func decodeInstance() -> APNSInstance {
        guard let data = UserDefaults.standard.data(forKey: Const.keyForAPNSInstance),
            let instance = NSKeyedUnarchiver.unarchiveObject(with: data) as? APNSInstance else {
                return APNSInstance()
        }
        return instance
    }
}

extension APNSInstance: NSCoding {
    public func encode(with aCoder: NSCoder) {
        encodeProperties(with: aCoder)
    }
}
