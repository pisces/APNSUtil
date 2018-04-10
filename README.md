# APNSUtil

![Swift](https://img.shields.io/badge/Swift-4.0-orange.svg)
![Swift](https://img.shields.io/badge/Swift-3.x-orange.svg)
[![CI Status](http://img.shields.io/travis/pisces/APNSUtil.svg?style=flat)](https://travis-ci.org/pisces/APNSUtil)
[![Version](https://img.shields.io/cocoapods/v/APNSUtil.svg?style=flat)](http://cocoapods.org/pods/APNSUtil)
[![License](https://img.shields.io/cocoapods/l/APNSUtil.svg?style=flat)](http://cocoapods.org/pods/APNSUtil)
[![Platform](https://img.shields.io/cocoapods/p/APNSUtil.svg?style=flat)](http://cocoapods.org/pods/APNSUtil)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

- APNSUtil makes code simple settings and landing for apple push notification service.

## Features
- Using apple push notification service simply
- No need write codes for any iOS versions
- Support chained functional programing

## Import

```swift
import APNSUtil
```

## Using

### Implementation for main view controller
```swift
import UIKit
import APNSUtil

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        APNSManager.shared
            .setTypes([.sound, .alert, .badge])             // setting user notification types
            .register()                                     // registering to use apns
            .processing(self) {                             // processing received apns payload
                let payload: APNSPayload = $0.payload()     // your custom payload with generic

                if $0.isInactive {
                    // TODO: write code to present viewController on inactive
                } else {
                    // TODO: write code to show toast message on active
                }
            }.begin()   // begin receiving apns payload
    }
}
```

### Implementation for app delegate

```swift
import UIKit
import UserNotifications
import APNSUtil

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Logic for handling push notifications at initial startup
        APNSManager.shared.didFinishLaunching(withOptions: launchOptions, as: APNSPayload.self)
        return true
    }

    // MARK: - Push Notification

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        APNSManager.shared.registerDeviceToken(deviceToken)
        // TODO: write code to update device token with your api server
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // TODO: write code to update device token with your api server
    }

    // MARK: - Push Notification for iOS 9

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        APNSManager.shared.didReceive(userInfo: userInfo, as: APNSPayload.self, isInactive: application.applicationState == .inactive)
    }

    // MARK: - Push Notification for iOS 10 or higher

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        APNSManager.shared.didReceive(userInfo: notification.request.content.userInfo, as: APNSPayload.self, isInactive: false)
    }
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        APNSManager.shared.didReceive(userInfo: response.notification.request.content.userInfo, as: APNSPayload.self, isInactive: true)
    }
}
```

### Implement your payload model
```swift
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
```

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.2+ is required to build APNSUtil 1.0.0+.

To integrate APNSUtil into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

target '<Your Target Name>' do
    pod 'APNSUtil', '~> 1.1.2'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Alamofire into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "pisces/APNSUtil" ~> 1.1.2
```

Run `carthage update` to build the framework and drag the built `APNSUtil.framework` into your Xcode project.

## Requirements

iOS Deployment Target 9.0 higher

## Author

Steve Kim, hh963103@gmail.com

## License

APNSUtil is available under the MIT license. See the LICENSE file for more info.
