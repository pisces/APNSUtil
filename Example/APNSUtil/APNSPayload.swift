//
//  APNSPayload.swift
//  APNSUtil
//
//  Created by pisces on 03/15/2018.
//  Copyright (c) 2018 pisces. All rights reserved.
//

import APNSUtil

struct APNSPayload: Decodable {
    let aps: APS?
    
    struct APS: Decodable {
        let sound: String?
        let alert: Alert?
    }
    
    struct Alert: Decodable {
        let body: String?
        let title: String?
    }
}
