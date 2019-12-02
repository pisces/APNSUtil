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
//  APNSInstance.swift
//  APNSUtil
//
//  Created by pisces on 12/01/2018.
//  Copyright © 2019 Steve Kim. All rights reserved.
//

import Foundation

@objcMembers public class APNSInstance: NSObject {
    
    // MARK: - Private Constants
    
    private struct Const {
        static let keyForAPNSInstance = "APNSInstance.shared"
    }
    
    public static let shared = decodeInstance()
    
    // MARK: - Public Properties
    
    public private(set) var tokenString: String?
    public private(set) var token: Data?
    
    // MARK: - Constructors
    
    public override init() {
        super.init()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        
        decodeProperties(with: aDecoder)
    }
    
    // MARK: - Public Methods
    
    public func clear() {
        token = nil
        tokenString = nil
        
        UserDefaults.standard.removeObject(forKey: Const.keyForAPNSInstance)
        UserDefaults.standard.synchronize()
    }
    public func setAPNSToken(_ token: Data) {
        self.token = token
        tokenString = token.reduce("", { $0 + String(format: "%02X", $1) })
        
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: self), forKey: Const.keyForAPNSInstance)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Private Methods
    
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
