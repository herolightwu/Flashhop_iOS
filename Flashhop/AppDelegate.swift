//
//  AppDelegate.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/7.
//

import UIKit
import IQKeyboardManager
import FBSDKCoreKit
import GoogleMaps
import GooglePlaces
import OneSignal
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OSSubscriptionObserver, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        //OneSignal
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            
            //print("Received Notification: \(notification!.payload.notificationID)")
            //print("launchURL = \(notification?.payload.launchURL ?? "None")")
            //print("content_available = \(notification?.payload.contentAvailable ?? false)")
            
            if let additionalData = notification?.payload!.additionalData {
                print("additionalData = \(additionalData)")
                if let action = additionalData["action"] {
                    let type = action as! String
                    if type == "chat" {
                        NotificationCenter.default.post(name: .receiveChat, object: self, userInfo: nil)
                    } else if type == "liked"{
                        let wid = additionalData["whatsup_id"] as! Int
                        let uname = additionalData["sender_name"] as! String
                        let avatar = additionalData["sender_avatar"] as! String
                        let uid = additionalData["sender_id"] as! Int
                        let dic: Dictionary<String, String> = ["whatsup_id":"\(wid)", "sender_name":uname, "sender_avatar": avatar, "sender_id": "\(uid)"]
                        NotificationCenter.default.post(name: .receiveLiked, object: self, userInfo: dic)
                    } else if type == "disliked" {
                        let wid = additionalData["whatsup_id"] as! Int
                        let uname = additionalData["sender_name"] as! String
                        let avatar = additionalData["sender_avatar"] as! String
                        let uid = additionalData["sender_id"] as! Int
                        let dic: Dictionary<String, String> = ["whatsup_id":"\(wid)", "sender_name":uname, "sender_avatar": avatar, "sender_id": "\(uid)"]
                        NotificationCenter.default.post(name: .receiveDisliked, object: self, userInfo: dic)
                    } else if type == "me_too" {
                        let wid = additionalData["whatsup_id"] as! Int
                        let uname = additionalData["sender_name"] as! String
                        let avatar = additionalData["sender_avatar"] as! String
                        let uid = additionalData["sender_id"] as! Int
                        let dic: Dictionary<String, String> = ["whatsup_id":"\(wid)", "sender_name":uname, "sender_avatar": avatar, "sender_id": "\(uid)"]
                        NotificationCenter.default.post(name: .receiveMetoo, object: self, userInfo: dic)
                    } else {
                        NotificationCenter.default.post(name: .receiveWhatsup, object: self, userInfo: nil)
                    }
                }
            }
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            //let payload: OSNotificationPayload? = result?.notification.payload
            //print("Message = \(payload!.body)")
            //print("badge number = \(payload?.badge ?? 0)")
            //print("notification sound = \(payload?.sound ?? "None")")
            
            if let additionalData = result!.notification.payload!.additionalData {
                print("additionalData = \(additionalData)")
                if let action = additionalData["action"] {
                    let type = action as! String
                    //let dic = additionalData as! [String:String]
                    if type == "chat" {
                        NotificationCenter.default.post(name: .openChat, object: self, userInfo: nil)
                    } else if type != "liked" && type != "disliked" && type != "me_too" {
                        NotificationCenter.default.post(name: .openWhatsup, object: self, userInfo: nil)
                    }
                }
            }
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "46b7d793-bd13-4788-83d1-362754041de2",
                                        handleNotificationReceived: notificationReceivedBlock,
                                        handleNotificationAction: notificationOpenedBlock,
                                        settings: onesignalInitSettings)
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        OneSignal.add(self as OSSubscriptionObserver)
        
        // This is the workaround for Xcode 11.2
        UITextViewWorkaround.unique.executeWorkaround()
        
        // IQKeyboardManager
        IQKeyboardManager.shared().toolbarManageBehaviour = .byTag
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().previousNextDisplayMode = .alwaysHide
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 100
        
        // Google Maps
        GMSServices.provideAPIKey(GOOGLE_API_KEY)
        GMSPlacesClient.provideAPIKey(GOOGLE_API_KEY)
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FirebaseApp.configure()
        //Google signin
        GIDSignIn.sharedInstance()?.clientID = "945997803187-lr9umf94k63p7f7bb5n4pa4j6ok5ektn.apps.googleusercontent.com"
        //GIDSignIn.sharedInstance()?.delegate = self
        

        return true
    }
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
        }
        //print("SubscriptionStateChange: \n\(stateChanges)")
        //The player id is inside stateChanges. But be careful, this value can be nil if the user has not granted you permission to send notifications.
        if let playerId = stateChanges.to.userId {
            print("Current playerId \(playerId)")
        }
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = ApplicationDelegate.shared.application(app, open: url, options: options)
        let googlehandle = GIDSignIn.sharedInstance()?.handle(url) ?? false
        return handled || googlehandle
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let googlehandle = GIDSignIn.sharedInstance()?.handle(url) ?? false
        let handled = ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        return googlehandle || handled
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

extension Notification.Name {
    static let openChat = Notification.Name("openChat")
    static let openWhatsup = Notification.Name("openWhatsup")
    static let receiveChat = Notification.Name("receiveChat")
    static let receiveWhatsup = Notification.Name("receiveWhatsup")
    static let receiveLiked = Notification.Name("receiveLiked")
    static let receiveDisliked = Notification.Name("receiveDisliked")
    static let receiveMetoo = Notification.Name("receiveMetoo")
}

//******************************************************************
// MARK: - Workaround for the Xcode 11.2 bug
//******************************************************************
class UITextViewWorkaround: NSObject {

    // --------------------------------------------------------------------
    // MARK: Singleton
    // --------------------------------------------------------------------
    // make it a singleton
    static let unique = UITextViewWorkaround()

    // --------------------------------------------------------------------
    // MARK: executeWorkaround()
    // --------------------------------------------------------------------
    func executeWorkaround() {

        if #available(iOS 13.2, *) {

            NSLog("UITextViewWorkaround.unique.executeWorkaround(): we are on iOS 13.2+ no need for a workaround")

        } else {

            // name of the missing class stub
            let className = "_UITextLayoutView"

            // try to get the class
            var cls = objc_getClass(className)

            // check if class is available
            if cls == nil {

                // it's not available, so create a replacement and register it
                cls = objc_allocateClassPair(UIView.self, className, 0)
                objc_registerClassPair(cls as! AnyClass)

                #if DEBUG
                NSLog("UITextViewWorkaround.unique.executeWorkaround(): added \(className) dynamically")
               #endif
           }
        }
    }
}

