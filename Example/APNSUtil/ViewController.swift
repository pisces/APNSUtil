//
//  ViewController.swift
//  APNSUtil
//
//  Created by pisces on 03/15/2018.
//  Copyright (c) 2018 pisces. All rights reserved.
//

import UIKit
import APNSUtil

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        APNSManager.shared
            .register()     // registering to use apns
            .processing(self) {     // processing received apns payload
                // your custom payload with generic
                let payload: APNSPayload = $0.payload()
                
                if $0.isInactive {
                    // TODO: write code to present viewController on inactive
                } else {
                    // TODO: write code to show toast message on active
                }
            }.begin()   // begin receiving apns payload
    }
}

