//
//  Utilities.swift
//  QuantumListing
//
//  Created by lucky clover on 3/30/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class Utilities: NSObject {
    class func degreesToRadians(degrees: Float) -> Float {
        return (Float(M_PI) * degrees)/180
    }
    class func date(fromString str: String) -> Date {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let d = dateFormat.date(from: str)
       
        if d != nil {
            return d!
        }
        return Date(timeIntervalSince1970: 0)
    }
    
    class func str(from date: Date) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormat.string(from: date)
    }
    
    class func date(fromStringShort str: String) -> Date {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy"
        return dateFormat.date(from: str)!
    }
    
    class func str(fromDateShort date: Date) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        return dateFormat.string(from: date)
    }
    
    class func miles(fromKM km: Float) -> Float {
        return km * 1.60934
    }
    
    class func kM(fromMiles miles: Float) -> Float {
        return miles / 0.62137
    }
    
    class func distance(fromLocation: CLLocationCoordinate2D, toLocation: CLLocationCoordinate2D) -> Float {
        let R = 6371000.0 as Float
        // metres
        let f1 = degreesToRadians(degrees: Float(fromLocation.latitude))
        let f2 = degreesToRadians(degrees: Float(fromLocation.latitude))
        
        let deltaF = degreesToRadians(degrees: Float(toLocation.latitude - fromLocation.latitude))
        let deltaR = self.degreesToRadians(degrees: Float(toLocation.longitude - fromLocation.longitude))
        let a = sinf(deltaF / 2) * sinf(deltaF / 2) + cosf(f1) * cosf(f2) * sinf(deltaR / 2) * sinf(deltaR / 2)
        let c = 2 * Float(atan2(sqrtf(a), sqrtf(1-a)))
        
        let d = R * c / 1000
        
        return self.miles(fromKM: d)
    }

    static var MAX_UPLOAD_COUNT = 10
    
    // Color Set //
    static var registerBorderColor = UIColor(red: 0xc1/0xff, green: 0xcd/0xff, blue: 0xdc/0xff, alpha: 1.0)
    static var txtMainColor = UIColor(red: 0x29/0xff, green: 0x42/0xff, blue: 0x62/0xff, alpha: 1.0)
    static var txtSubColor = UIColor(red: 0xae/0xff, green: 0xbc/0xff, blue: 0xcd/0xff, alpha: 1.0)
    static var greenColor = UIColor(red: 0x56/0xff, green: 0xbc/0xff, blue: 0x56/0xff, alpha: 1.0)
    static var borderGrayColor = UIColor(red: 0xdd/0xff, green: 0xe8/0xff, blue: 0xf3/0xff, alpha: 1.0)
    static var sliderTintColor = UIColor(red: 0xdc/0xff, green: 0xe0/0xff, blue: 0xe9/0xff, alpha: 1.0)
    static var loginBorderColor = UIColor(red: 0xeb/0xff, green: 0xe9/0xff, blue: 0xc7/0xff, alpha: 1.0)
}
//Other utility functions

var user: User?
var loginNav = UINavigationController()
var tc = UITabBarController()
let appDelegate = UIApplication.shared.delegate as! AppDelegate
var products: NSArray?

func removeSession() {
    let defaults = UserDefaults.standard
    
    defaults.set("", forKey: "session_id")
    defaults.set("", forKey: "access_token")
    defaults.set("", forKey: "user_id")
    
    defaults.synchronize()
}

func resizeImage(image: UIImage, newWidth: CGFloat, newHeight: CGFloat) -> UIImage {
    let newSize = CGSize(width: newWidth, height: newHeight)
    UIGraphicsBeginImageContext(newSize)
    
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}
func saveUserInfo() {
    let defaults = UserDefaults.standard
    
    defaults.set(user?.user_id, forKey: "user_id")
    defaults.set(user?.umail, forKey: "umail")
    defaults.set(user?.uname, forKey: "uname")
    defaults.set(user?.session_id, forKey: "session_id")
    defaults.set(user?.access_token, forKey: "access_token")
    defaults.set(user?.password, forKey: "password")
    defaults.set(user?.phone_num, forKey: "phone_num")
    defaults.set(user?.user_blog, forKey: "blog")
    defaults.set(user?.user_bio, forKey: "bio")
    defaults.set(user?.user_photo, forKey: "photo")
    defaults.set(user?.ms_type, forKey: "ms_type")
    defaults.set(user?.ms_startDate, forKey: "ms_startdate")
    defaults.set(user?.ms_endDate, forKey: "ms_enddate")
    defaults.set(user?.ms_isAuto, forKey: "ms_isauto")
    defaults.set(user?.uf_sort, forKey: "uf_sort")
    defaults.set((user?.uf_priceStart)!, forKey: "uf_priceStart")
    defaults.set((user?.uf_priceEnd)!, forKey: "uf_priceEnd")
    defaults.set(user?.uf_lease, forKey: "uf_lease")
    defaults.set(user?.uf_distanceStart, forKey: "uf_distanceStart")
    defaults.set(user?.uf_distanceEnd, forKey: "uf_distanceEnd")
    defaults.set(user?.uf_dateTo, forKey: "uf_dateTo")
    defaults.set(user?.uf_dateFrom, forKey: "uf_dateFrom")
    defaults.set(user?.uf_building, forKey: "uf_building")
    
    defaults.set(user?.isUpdatedProfile, forKey: "isUpdatedProfile")
    
    defaults.set(user?.latitude, forKey: "latitude")
    defaults.set(user?.longitude, forKey: "longitude")
    defaults.synchronize()
}

func getUserInfo(key : String) -> String
{
    let defaults = UserDefaults.standard
    
    if let data = defaults.string(forKey: key)
    {
        return data
    }
    else
    {
        return ""
    }
}

func shouldAutoLogin() -> Bool {
    
    let defaults = UserDefaults.standard
    
    guard defaults.value(forKey: "autologin") != nil else
    {
        return false
    }
    
    return defaults.bool(forKey: "autologin")
}

func saveAutoLoginInfo(autologin : Bool)
{
    let defaults = UserDefaults.standard
    
    defaults.set(autologin, forKey: "autologin")
}

func loadUserInfo() {
    let defaults = UserDefaults.standard
    
    user?.user_id = getUserInfo(key: "user_id")
    
    
    user?.umail = getUserInfo(key: "umail")
    user?.uname = getUserInfo(key: "uname")
    user?.session_id = getUserInfo(key: "session_id")
    user?.access_token = getUserInfo(key: "access_token")
    user?.password = getUserInfo(key: "password")
    user?.phone_num = getUserInfo(key: "phone_num")
    user?.user_blog = getUserInfo(key: "blog")
    user?.user_photo = getUserInfo(key: "photo")
    user?.user_bio = getUserInfo(key: "bio")
    user?.ms_isAuto = getUserInfo(key: "isauto")
    user?.ms_endDate = getUserInfo(key: "ms_enddate")
    user?.ms_startDate = getUserInfo(key: "ms_startdate")
    user?.ms_type = getUserInfo(key: "ms_type")
    user?.uf_building = getUserInfo(key: "uf_building")
    user?.uf_dateFrom = getUserInfo(key: "uf_dateFrom")
    user?.uf_dateTo = getUserInfo(key: "uf_dateTo")
    user?.uf_distanceEnd = getUserInfo(key: "uf_distanceEnd")
    user?.uf_distanceStart = getUserInfo(key:"uf_distanceStart")
    user?.uf_lease = getUserInfo(key: "uf_lease")
    user?.uf_priceEnd = getUserInfo(key:"uf_priceEnd")
    user?.uf_priceStart = getUserInfo(key: "uf_priceStart")
    user?.uf_sort = getUserInfo(key: "uf_sort")
    
    user?.isUpdatedProfile = defaults.bool(forKey: "isUpdatedProfile")
    
    user?.latitude = getUserInfo(key: "latitude")
    user?.longitude = getUserInfo(key: "longitude")
}
func configureRootNav() {
    let user_info: NSMutableDictionary = [
        "user_id" : (user?.user_id)!,
        "profile_pic" : (user?.user_photo)!,
        "about_me" : (user?.user_bio)!,
        "email": (user?.umail)!,
        "website": (user?.user_blog)!,
        "mobile": (user?.phone_num)!,
        "full_name": (user?.uname)!,
        "membership_type":(user?.ms_type)!,
        "membership_start":(user?.ms_startDate)!,
        "membership_end":(user?.ms_endDate)!
    ]
    tc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
    DispatchQueue.main.async { // Correct
    
        let image = UIImage(named : "my_top_header.png")
        for i in 0...4 {
            let vc = tc.viewControllers?[i] as! UINavigationController
            let width = (appDelegate.window?.bounds.width)!
            let height = vc.navigationBar.frame.size.height
            
            let newimage = resizeImage(image: image!, newWidth: width, newHeight: height)
            vc.navigationBar.setBackgroundImage(newimage, for: UIBarMetrics.default)
        }
        
        let nc = tc.viewControllers?[4] as! UINavigationController
        let uc = nc.viewControllers[0] as! UserViewController
        uc.user_info = user_info
        
        appDelegate.window?.rootViewController = tc
    }
}

func configureLoginNav()
{
    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
    loginNav = UINavigationController(rootViewController: vc)
    loginNav.navigationBar.isHidden = true
    DispatchQueue.main.async {
        appDelegate.window?.rootViewController = loginNav
    }
}
