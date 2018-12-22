//
//  LoginViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/21/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import CircularSpinner
import Alamofire

class LoginViewController: UIViewController {

    @IBOutlet weak var cbKeepSignin: UIButton!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPass: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = false

        // Do any additional setup after loading the view.

    }

    @IBAction func onKeepBtnClicked(_ sender: Any) {
        cbKeepSignin.isSelected = !cbKeepSignin.isSelected
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBackTapped(_ sender: Any) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onSubmit(_ sender: Any) {
        loginUser()
    }

    @IBAction func onForgotPass(_ sender: Any) {
    }

    func loginUser() {
        saveAutoLoginInfo(autologin: self.cbKeepSignin.isSelected)

        let parameters = ["email": self.txtEmail.text!, "password": self.txtPass.text!, "token": CLIENT_SECRET]

        CircularSpinner.show("Log In", animated: true, type: .indeterminate, showDismissButton: false)
        let urlString = BASE_URL + "/account/login"
        print("API CALL: \(urlString)")
        print("Params: \(String(describing: parameters))")
        Alamofire.request(urlString, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            print("Request: \(response.request?.httpMethod as! String) \(response.request!)")
            print("Response: \(response.response?.statusCode as! Int) (\(response.data!))")
            debugPrint(response.result)

            switch response.result {
            case .success:
                if let result = response.result.value{
                    let JSON = result as! NSDictionary
                    if ((JSON["status"] as! String) == "true") {
                        let profile = JSON["profile"] as? [String:Any]
                        if (profile != nil) {
                            user?.user_blog = (profile?["website"] as? String)!
                            user?.user_bio = (profile?["about_me"] as? String)!
                            user?.phone_num = (profile?["mobile"] as? String)!
                            user?.user_photo = (profile?["profile_pic"] as? String)!
                            user?.ms_startDate = (profile?["membership_start"] as! String)
                            user?.ms_endDate = (profile?["membership_end"] as! String)
                            user?.isUpdatedProfile = true
                            user?.ms_type = (profile?["membership_type"] as? String)!
                        }
                        else {
                            user?.isUpdatedProfile = false
                        }

                        user?.uname = (JSON["username"] as? String)!
                        user?.umail = self.txtEmail.text!
                        user?.password = self.txtPass.text!
                        user?.user_id = "\(JSON["user_id"] as! String)"
                        user?.access_token = "\(JSON["access_token"] as! String)"
                        saveUserInfo()
                        configureRootNav()
                    }
                    else {
                        let alert = UIAlertController(title: "QuantumListing", message: JSON["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }

            case .failure(let error):
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                }

//                let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
            }
            self.view.endEditing(true)
            CircularSpinner.hide()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
