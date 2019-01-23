//
//  APNSPayload.swift
//  APNSUtil
//
//  Created by pisces on 03/15/2018.
//  Copyright (c) 2018 pisces. All rights reserved.
//

import APNSUtil

extension RemoteNotificationElement {
    typealias T = APNSPayload
}

struct APNSPayload: Decodable {
    var msg: String?
    var id: String?
}

