//
//  NSObject+Codable.swift
//  APNSUtil
//
//  Created by pisces on 12/01/2018.
//  Copyright © 2018 pisces. All rights reserved.
//

import Foundation

extension NSObject {
    public var mirrorChildList: [Mirror.Child] {
        return Mirror(reflecting: self).children.filter { $0.label != nil }
    }
    
    public func encodeProperties(with corder: NSCoder, ignoreKeys: [String]? = nil) {
        mirrorChildList.forEach {
            if let ignoreKeys = ignoreKeys, ignoreKeys.contains($0.label!) {
                return
            }
            
            if !($0.value is NSNull) {
                corder.encode($0.value, forKey: $0.label!)
            }
        }
    }
    public func decodeProperties(with corder: NSCoder, ignoreKeys: [String]? = nil) {
        mirrorChildList.forEach {
            if let ignoreKeys = ignoreKeys, ignoreKeys.contains($0.label!) {
                return
            }
            if let value = corder.decodeObject(forKey: $0.label!), !(value is NSNull) {
                setValue(value, forKey: $0.label!)
            }
        }
    }
    public func dictionary(ignoreKeys: [String]? = nil) -> [String: Any] {
        var dict = [String: Any]()
        mirrorChildList.forEach {
            if let ignoreKeys = ignoreKeys, ignoreKeys.contains($0.label!) {
                return
            }
            dict[$0.label!] = value(forKey: $0.label!)
        }
        return dict
    }
}
