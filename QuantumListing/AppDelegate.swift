//
//  AppDelegate.swift
//  QuantumListing
//
//  Created by lucky clover on 3/20/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import TwitterKit
import FBSDKCoreKit
import SDWebImage
import Alamofire
import IQKeyboardManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var isOwner: Bool?
    var deviceToken: NSString = ""
    var msg: NSDictionary?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self])
        
        Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = 10
        SDWebImageDownloader.shared().maxConcurrentDownloads = 6
        
        TWTRTwitter.sharedInstance().start(withConsumerKey: "QVPn0PxH4TQYYshvnY6Ap44uC", consumerSecret: "wcX5dSuFYEwiflydWcOfarrB1qgn0o1LBok88xM1EghG6dIU2F")
        
        // Override point for customization after application launch.
        user = User()
        loadUserInfo()
        if user?.user_id == nil || (user?.user_id == "") || shouldAutoLogin() == false {
            configureLoginNav()
        }
        else {
            
            configureRootNav()
        }
        
        RentagraphAPHelper.sharedInstance().requestProducts { (success, productslist) in
            
            if success
            {
                products = productslist! as NSArray
            }
        }
        
        IQKeyboardManager.shared().isEnabled = true
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        FBSDKAppEvents.activateApp()
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

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let scheme = url.scheme
        
        if scheme!.hasPrefix("file")
        {
            return PDFManageViewController.handleOpenURL(importedURL: url)
        }
        else if scheme!.hasPrefix("twitterkit"){
            return true
//            if TWTRTwitter.sharedInstance().application(application, open: url, options: [:]) {
//                return true
//            }else{
//                return false
//            }
        }else if scheme!.hasPrefix("fb")
        {
        
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication : sourceApplication, annotation : annotation)
        }else{
            return true
        }
    }
    
    func application(_ supportedInterfaceOrientationsForapplication: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if self.window?.rootViewController?.presentedViewController is YoutubeVideoPlayerViewController {
            
            let secondController = self.window!.rootViewController!.presentedViewController as! YoutubeVideoPlayerViewController
            
            if secondController.isPresented { // Check current controller state
                return UIInterfaceOrientationMask.all
            } else {
                return UIInterfaceOrientationMask.portrait
            }
        } else {
            return UIInterfaceOrientationMask.portrait
        }
        
    }
    
}


