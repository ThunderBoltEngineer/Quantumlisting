//
//  RegisterViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/21/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import CircularSpinner
import Alamofire

class RegisterViewController: UIViewController ,CircularSpinnerDelegate{

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPass: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtWebsite: UITextField!
    @IBOutlet weak var btnAgree: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapView)))

        self.navigationController?.isNavigationBarHidden = false
    }

    @objc func onTapView()
    {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBackTapped(_ sender: Any) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onAgree(_ sender: Any) {
        btnAgree.isSelected = !btnAgree.isSelected
    }

    @IBAction func onSubmit(_ sender: Any) {
        if self.checkValidation() {
            registerUser()
        }
    }

    func registerUser() {
        var parameters = ["username": self.txtFullName.text!, "email": self.txtEmail.text!, "password": self.txtPass.text!]
        if !(self.txtPhone.text?.isEmpty)! {
            parameters["mobile"] = self.txtPhone.text!
        }
        else
        {
            parameters["mobile"] = ""
        }
        if !(self.txtWebsite.text?.isEmpty)! {
            parameters["website"] = self.txtWebsite.text!
        }
        else
        {
            parameters["website"] = ""
        }

        CircularSpinner.show("Register", animated: true, type: .indeterminate, showDismissButton: false)
        let urlString = BASE_URL + "/account/registration"
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
                    if ((JSON["status"] as! String) == "true") {
                        //register successful,  do login
                        DispatchQueue.main.async(execute: {
                            self.loginUser()
                        })
                    }
                    else {
                        var message = JSON["message"] as? String ?? "Registration failed"
                        
                        if message == "This email was already used." {
                            message = "This email address already exists in our system. Try logging in instead."
                        }
                        
                        let alert = UIAlertController(title: "QuantumListing", message: message, preferredStyle: UIAlertControllerStyle.alert)
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
            CircularSpinner.hide()
        }
    }

    func checkValidation() ->Bool {
        if(txtFullName.text?.isEmpty)! {
            let alert = UIAlertController(title: "QuantumListing", message: "Username is Empty.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        if(txtEmail.text?.isEmpty)! {
            let alert = UIAlertController(title: "QuantumListing", message: "Email is Empty.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        if(txtPass.text?.isEmpty)! {
            let alert = UIAlertController(title: "QuantumListing", message: "Password is Empty.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }

        if(txtPhone.text?.isEmpty)! {
            let alert = UIAlertController(title: "QuantumListing", message: "Phone is Empty.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        if(!btnAgree.isSelected) {
            let alert = UIAlertController(title: "QuantumListing", message: "You must agree terms & policy to register.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }

    func loginUser() {
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
                        let message = JSON["message"] as? String ?? "Registration failed"
                        
                        let alert = UIAlertController(title: "QuantumListing", message: message, preferredStyle: UIAlertControllerStyle.alert)
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
            CircularSpinner.hide()
        }

    }
    
    
    @IBAction func didTapLogin(_ sender: Any) {
        let loginViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
        navigationController?.pushViewController(loginViewController, animated: false)
        
        navigationController?.viewControllers.remove(at: navigationController!.viewControllers.count - 2)
    
    }
    
}
