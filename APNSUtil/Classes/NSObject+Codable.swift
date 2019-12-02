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
//  NSObject+Codable.swift
//  APNSUtil
//
//  Created by pisces on 12/01/2018.
//  Copyright © 2019 Steve Kim. All rights reserved.
//

import Foundation

extension NSObject {
    
    // MARK: - Public Properties
    
    public var mirrorChildList: [Mirror.Child] {
        return Mirror(reflecting: self).children.filter { $0.label != nil }
    }
    
    // MARK: - Public Methods
    
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
    public func encodeProperties(with corder: NSCoder, ignoreKeys: [String]? = nil) {
        let mirror = Mirror(reflecting: self)
        var current = mirror.superclassMirror
        
        while current != nil {
            encodeChildren(filteredChildren(current), corder: corder, ignoreKeys: ignoreKeys)
            current = current?.superclassMirror
        }
        
        encodeChildren(filteredChildren(mirror), corder: corder, ignoreKeys: ignoreKeys)
    }
    
    // MARK: - Private Methods
    
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
