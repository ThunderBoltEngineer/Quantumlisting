//
//  ViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/20/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import TwitterKit
import Fabric
import Crashlytics
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import CircularSpinner
import Alamofire

class ViewController: UIViewController {


    @IBOutlet weak var fbBtn: UIButton!
    @IBOutlet weak var twBtn: UIButton!

    @IBAction func onFBBtn(_ sender: Any)
    {

        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()

        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
                        fbLoginManager.logOut()
                    }
                }
            }
        }

    }

    func getFBUserData()
    {
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    let data = result as! NSDictionary

                    print(data.description)

                    var parameters : [String : String] = [:]
                    let email = data["email"] as! String
                    parameters["email"] = email
                    parameters["username"] = (data["name"] as! String)
                    parameters["full_name"] = (data["name"] as! String)
                    let picture = ((data["picture"] as! NSDictionary)["data"] as! NSDictionary)["url"] as! String

                    parameters["profile_pic"] = picture
                    parameters["socialmedia"] = "Facebook"

                    CircularSpinner.show("Log In", animated: true, type: .indeterminate, showDismissButton: false)
                    let urlString = BASE_URL + "/account/registerWithSocialMedia"
                    print("API CALL: \(urlString)")
                    print("Params: \(String(describing: parameters))")
                    Alamofire.request(urlString, method: .get, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                        print("Request: \(response.request?.httpMethod as! String) \(response.request!)")
                        print("Response: \(response.response?.statusCode as! Int) (\(response.data!))")
                        debugPrint(response.result)

                        switch response.result {
                        case .success:
                            if let result = response.result.value{
                                let JSON = result as! NSDictionary
                                if JSON["status"] as! String == "true"
                                {
                                    let profile = JSON.object(forKey: "profile") as! NSDictionary

                                    user?.uname = profile.object(forKey: "username") as! String
                                    user?.umail = profile.object(forKey: "email") as! String
                                    user?.user_id = "\(JSON["user_id"] ?? "")!)"

//                                    user?.user_blog = profile.object(forKey: "website") as! String
                                    user?.phone_num = profile.object(forKey: "mobile") as! String
                                    user?.user_bio = profile.object(forKey: "about_me") as! String
                                    user?.user_photo = profile.object(forKey: "profile_pic") as! String
                                    user?.ms_type = (profile.object(forKey: "membership_type") as! String)
                                    user?.ms_startDate = profile.object(forKey: "membership_start") as! String
                                    user?.ms_endDate = profile.object(forKey: "membership_end") as! String

                                    if JSON["isUpdatedProfile"] as? String == "yes"
                                    {
                                        user?.isUpdatedProfile = true
                                        configureRootNav()
                                    }
                                    else
                                    {
                                        user?.isUpdatedProfile = false
                                        configureRootNav()
                                    }
                                    let transition = CATransition()
                                    transition.type = kCATransitionFade
                                    transition.duration = 0.3
                                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                                    appDelegate.window?.layer.add(transition, forKey: "transition")
                                    saveUserInfo()
                                    saveAutoLoginInfo(autologin: true)
                                }
                            }

                        case .failure(let error):
                            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                                print("Data: \(utf8Text)")
                            }

//                            let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
//                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                            self.present(alert, animated: true, completion: nil)
                        }
                        CircularSpinner.hide()
                    }
                }
            })
        }

    }

    @IBAction func onTWBtn(_ sender: Any) {

        TWTRTwitter.sharedInstance().logIn(completion: {

            (session, error) in

            if session == nil
            {
                return
            }
            user?.tw_id = (session?.userName)!

            let client = TWTRAPIClient.withCurrentUser()

            let request = client.urlRequest(withMethod: "GET",
                                            urlString: "https://api.twitter.com/1.1/account/verify_credentials.json",
                                            parameters: ["include_email": "true", "skip_status": "true"],
                                            error: nil)
            client.sendTwitterRequest(request, completion: { (response, data, connectionError) in

                do{
                    CircularSpinner.show("Log In", animated: true, type: .indeterminate, showDismissButton: false)

                    let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : Any]
                    print(jsonResponse)


                    var parameters = ["socialmedia":"Twitter", "username":jsonResponse["name"] as! String, "profile_pic" : jsonResponse["profile_image_url"] as! String, "full_name":jsonResponse["name"] as! String]
                    if let email = jsonResponse["email"] as? String {
                        parameters["email"] = email
                    }else{
                        parameters["email"] = "testemail@test.com"
                    }
                    let urlString = BASE_URL + "/account/registerWithSocialMedia"
                    print("API CALL: \(urlString)")
                    print("Params: \(String(describing: parameters))")
                    Alamofire.request(urlString, method: .get, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                        print("Request: \(response.request?.httpMethod as! String) \(response.request!)")
                        print("Response: \(response.response?.statusCode as! Int) (\(response.data!))")
                        debugPrint(response.result)

                        switch response.result {
                        case .success:
                            if let result = response.result.value{
                                let JSON = result as! NSDictionary
                                if (JSON["status"] as! String) == "true"
                                {
                                    let profile = JSON["profile"] as! NSDictionary

                                    user?.uname = profile.object(forKey: "username") as! String
                                    user?.umail = profile.object(forKey: "email") as! String
                                    user?.user_id = "\(JSON["user_id"]!)"
                                    user?.user_blog = profile.object(forKey: "website") as! String
                                    user?.phone_num = profile.object(forKey: "mobile") as! String
                                    user?.user_bio = profile.object(forKey: "about_me") as! String
                                    user?.user_photo = profile.object(forKey: "profile_pic") as! String
                                    user?.ms_type = (profile.object(forKey: "membership_type") as! String)
                                    user?.ms_startDate = profile.object(forKey: "membership_start") as! String
                                    user?.ms_endDate = profile.object(forKey: "membership_end") as! String

                                    if JSON["isUpdatedProfile"] as! String == "yes"
                                    {
                                        user?.isUpdatedProfile = true
                                        configureRootNav()
                                    }
                                    else
                                    {
                                        user?.isUpdatedProfile = false
                                        configureRootNav()
                                    }
                                    let transition = CATransition()
                                    transition.type = kCATransitionFade
                                    transition.duration = 0.3
                                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                                    DispatchQueue.main.async {
                                        appDelegate.window?.layer.add(transition, forKey: "transition")
                                    }
                                    saveUserInfo()
                                    saveAutoLoginInfo(autologin: true)
                                }
                                else {
                                    // show message
                                }
                            }
                        case .failure(let error):
                            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                                print("Data: \(utf8Text)")
                            }

//                            let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
//                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                            self.present(alert, animated: true, completion: nil)
                        }
                        CircularSpinner.hide()
                    }
                }catch{
                    CircularSpinner.hide()
                    return
                }

            })

        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.tintColor = UIColor.black

        let image = UIImage(named : "my_top_header.png")
        let width = self.navigationController?.navigationBar.frame.size.width
        let height = self.navigationController?.navigationBar.frame.size.height
        let newimage = resizeImage(image: image!, newWidth: width!, newHeight: height!)
        self.navigationController?.navigationBar.setBackgroundImage(newimage, for: UIBarMetrics.default)

    }

    func resizeImage(image: UIImage, newWidth: CGFloat, newHeight: CGFloat) -> UIImage {
        let newSize = CGSize(width: newWidth, height: newHeight)
        UIGraphicsBeginImageContext(newSize)

        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func didTapSiteLink(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://quantumlisting.com")!, options: [:], completionHandler: nil)
    }
    
}

