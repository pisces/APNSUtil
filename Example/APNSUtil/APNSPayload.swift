//
//  APNSPayload.swift
//  APNSUtil
//
//  Created by pisces on 03/15/2018.
//  Copyright (c) 2018 pisces. All rights reserved.
//

import APNSUtil
import ObjectMapper

extension RemoteNotificationElement {
    typealias T = APNSPayload
}

struct APNSPayload: Mappable {
    var msg: String?
    var id: String?
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        msg <- map["msg"]
        id <- map["id"]
    }
}

