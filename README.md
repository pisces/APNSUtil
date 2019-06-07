# APNSUtil

![Swift](https://img.shields.io/badge/Swift-4.x-orange.svg)
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
            .register()                                     // register to use apns
            .subscribe(self) {                             // subscribe to receive apns payload
                // your payload model with generic
                guard let payload: APNSPayload = $0.payload() else {
                    return
                }

                print("subscribe", $0.isInactive, $0.userInfo, payload)

                if $0.isInactive {
                    // TODO: write code to present viewController on inactive
                } else {
                    // TODO: write code to show toast message on active
                }
            }.begin()   // begin to receive apns payload
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
        APNSManager.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    // MARK: - Push Notification
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        APNSManager.shared.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        // <<your function to register device token on your server>>(APNSInstance.shared.tokenString)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    // MARK: - Push Notification for iOS 9
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        APNSManager.shared.application(application, didRegister: notificationSettings)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        APNSManager.shared.application(application, didReceiveRemoteNotification: userInfo)
    }
    
    // MARK: - Public Methods (UIApplicationDelegate - Local Notification)
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        APNSManager.shared.application(application, didReceive: notification)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        APNSManager.shared.userNotificationCenter(center, willPresent: notification)
    }
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        APNSManager.shared.userNotificationCenter(center, didReceive: response)
    }
}
```

### Implement your payload model
```swift
struct APNSPayload: Decodable {
    let aps: APS?

    // Add properties here you need

    struct APS: Decodable {
        let sound: String?
        let alert: Alert?
    }

    struct Alert: Decodable {
        let body: String?
        let title: String?
    }
}
```

### Using with your payload model as generic

```swift
  APNSManager.shared
      .setTypes([.sound, .alert, .badge])
      .register()
      .subscribe(self) {
          guard let payload: APNSPayload = $0.payload() else {
              return
          }

          // write here to process payload model
      }.begin()
```

### Using with raw userInfo

```swift
  APNSManager.shared
      .setTypes([.sound, .alert, .badge])
      .register()
      .subscribe(self) {
          let userInfo = $0.userInfo

          // write here to process userInfo
      }.begin()
```

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.0.0+ is required to build APNSUtil 1.1.5+.

To integrate APNSUtil into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

# Default
target '<Your Target Name>' do
    pod 'APNSUtil', '~> 1.4.0'
end

# for AppExtension
target '<Your Target Name>' do
    pod 'APNSUtil/AppExtension', '~> 1.4.0'
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
github "pisces/APNSUtil" ~> 1.4.0
```

Run `carthage update` to build the framework and drag the built `APNSUtil.framework` into your Xcode project.

## Requirements

iOS Deployment Target 9.0 higher

## Author

Steve Kim, hh963103@gmail.com

## License

APNSUtil is available under the MIT license. See the LICENSE file for more info.
