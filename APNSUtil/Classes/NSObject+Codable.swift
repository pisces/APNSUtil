//
//  NSObject+Codable.swift
//  APNSUtil
//
//  Created by pisces on 12/01/2018.
//  Copyright © 2018 pisces. All rights reserved.
//

import Foundation

extension NSObject {
    
    // MARK: - Properties
    
    public var mirrorChildList: [Mirror.Child] {
        return Mirror(reflecting: self).children.filter { $0.label != nil }
    }
    
    // MARK: - Public methods
    
    public func encodeProperties(with corder: NSCoder, ignoreKeys: [String]? = nil) {
        let mirror = Mirror(reflecting: self)
        var current = mirror.superclassMirror
        
        while current != nil {
            encodeChildren(filteredChildren(current), corder: corder, ignoreKeys: ignoreKeys)
            current = current?.superclassMirror
        }
        
        encodeChildren(filteredChildren(mirror), corder: corder, ignoreKeys: ignoreKeys)
    }
    public func decodeProperties(with corder: NSCoder, ignoreKeys: [String]? = nil) {
        let mirror = Mirror(reflecting: self)
        var current = mirror.superclassMirror
        
        while current != nil {
            decodeChildren(filteredChildren(current), corder: corder, ignoreKeys: ignoreKeys)
            current = current?.superclassMirror
        }
        
        decodeChildren(filteredChildren(mirror), corder: corder, ignoreKeys: ignoreKeys)
    }
    public func dictionary(ignoreKeys: [String]? = nil) -> [String: Any] {
        let mirror = Mirror(reflecting: self)
        var current = mirror.superclassMirror
        var dict = [String: Any]()
        
        while current != nil {
            setValue(with: filteredChildren(current), dict: &dict, ignoreKeys: ignoreKeys)
            current = current?.superclassMirror
        }
        
        setValue(with: filteredChildren(mirror), dict: &dict, ignoreKeys: ignoreKeys)
        
        return dict
    }
    
    // MARK: - Private methods
    
    private func encodeChildren(_ children: [Mirror.Child]?, corder: NSCoder, ignoreKeys: [String]? = nil) {
        children?.forEach {
            if let ignoreKeys = ignoreKeys, ignoreKeys.contains($0.label!) {
                return
            }
            if !($0.value is NSNull) {
                corder.encode($0.value, forKey: $0.label!)
            }
        }
    }
    private func decodeChildren(_ children: [Mirror.Child]?, corder: NSCoder, ignoreKeys: [String]? = nil) {
        children?.forEach {
            if let ignoreKeys = ignoreKeys, ignoreKeys.contains($0.label!) {
                return
            }
            if let value = corder.decodeObject(forKey: $0.label!), !(value is NSNull) {
                setValue(value, forKey: $0.label!)
            }
        }
    }
    private func filteredChildren(_ mirror: Mirror?) -> [Mirror.Child] {
        return mirror?.children.filter { $0.label != nil } ?? []
    }
    private func setValue(with children: [Mirror.Child]?, dict: inout [String: Any], ignoreKeys: [String]? = nil) {
        children?.forEach {
            if let ignoreKeys = ignoreKeys, ignoreKeys.contains($0.label!) {
                return
            }
            dict[$0.label!] = value(forKey: $0.label!)
        }
    }
}
