//
//  ProfileViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/24/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import CircularSpinner
import JVFloatLabeledTextField
import Alamofire

class ProfileViewController: UIViewController ,UITextFieldDelegate, DLCImagePickerDelegate{

    @IBOutlet weak var btnPickAvatar: UIButton!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var txtBlog: JVFloatLabeledTextField!
    @IBOutlet weak var txtPhone: JVFloatLabeledTextField!
    @IBOutlet weak var txtName: JVFloatLabeledTextField!
    @IBOutlet weak var txtConfirm: JVFloatLabeledTextField!
    @IBOutlet weak var txtPassword: JVFloatLabeledTextField!
    @IBOutlet weak var txtEmail: JVFloatLabeledTextField!
    @IBOutlet weak var txtSkype: JVFloatLabeledTextField!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var heightOfContent: NSLayoutConstraint!

    var activeField : UITextField?
    var userVC : UserViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        //registerForKeyboardNotifications()
        configureUserInterface()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    func configureUserInterface()
    {

        txtEmail.text = user?.umail
        txtName.text = user?.uname
        txtPassword.text = user?.password
        txtConfirm.text = user?.password
        txtPhone.text = user?.phone_num
        txtBlog.text = user?.user_blog

        txtEmail.addUnderline()
        txtName.addUnderline()
        txtPhone.addUnderline()
        txtPassword.addUnderline()
        txtConfirm.addUnderline()
        txtBlog.addUnderline()
        txtSkype.addUnderline()

        ivAvatar.layer.cornerRadius = ivAvatar.bounds.width / 2.0
        ivAvatar.layer.masksToBounds = true
        ivAvatar.clipsToBounds = true

        //ivAvatar.sd_setImage(with: URL(string: (user?.user_photo)!)!)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resignKeyboard))
        contentView.addGestureRecognizer(tapGesture)
    }

    @objc func resignKeyboard()
    {
        self.view.endEditing(true)
    }

//    func registerForKeyboardNotifications() {
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: Notification.Name.UIKeyboardDidShow, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: Notification.Name.UIKeyboardWillHide, object: nil)
//    }
//
//    func keyboardWasShown(_ aNotification: Notification) {
//
//        if activeField == nil
//        {
//            return
//        }
//
//        let info = aNotification.userInfo
//        let kbSize = (info?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        let contentInsets = UIEdgeInsetsMake(0, 0, (kbSize.height), 0)
//        scrollView.contentInset = contentInsets
//        scrollView.scrollIndicatorInsets = contentInsets
//
//        var aRect = self.view.frame
//        aRect.size.height -= (kbSize.height)
//
//        if(!aRect.contains((activeField?.frame.origin)!)) {
//            let scrollPoint = CGPoint(x: 0, y: (activeField?.frame.origin.y)! - (kbSize.height))
//            scrollView.setContentOffset(scrollPoint, animated: true)
//        }
//
//    }
//
//    func keyboardWillBeHidden(_ aNotificaton: Notification) {
//        let contentInsets = UIEdgeInsets.zero
//        scrollView.contentInset = contentInsets
//        scrollView.scrollIndicatorInsets = contentInsets
//
//    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField

        return true
    }


    // *** //

    @IBAction func onBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func actEdit(_ sender: Any) {

        self.view.endEditing(true)

        if (txtPassword.text == txtConfirm.text) {

            updateProfileDetail()
        }
        else
        {
            let alert = UIAlertController(title: "QuantumListing", message: "Password mismatch.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)

        }
    }

    @IBAction func actLogout(_ sender: Any) {

        removeSession()
        user?.user_id = ""
        configureLoginNav()
        let transition = CATransition()
        transition.type = kCATransitionFade
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        DispatchQueue.main.async {
            appDelegate.window?.layer.add(transition, forKey: "transition")
        }
    }

    @IBAction func actUploadAvatar(_ sender: Any) {
        self.view.endEditing(true)

        let picker = DLCImagePickerController()
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)

    }

    //DLCPickerController delegate
    func imagePickerControllerDidCancel(_ picker: DLCImagePickerController!) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: DLCImagePickerController!, didFinishPickingMediaWithInfo info: [AnyHashable : Any]!) {
        picker.dismiss(animated: true, completion: nil)

        ivAvatar.image = ((info as NSDictionary).object(forKey: "image") as! UIImage)

        uploadProfileImage()
    }

    func uploadProfileImage()
    {
        var headers = Alamofire.SessionManager.defaultHTTPHeaders

        if let accessToken = user!.access_token as? String {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else {
            // redirect to login ???
        }

        let parameters = ["user_id" : user!.user_id]

        CircularSpinner.show("Updating", animated: true, type: .indeterminate, showDismissButton: false)
        let urlString = BASE_URL + "/profile/uploadAvatar"
        print("UPLOAD API CALL: \(urlString)")
        print("Params: \(String(describing: parameters))")
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
                multipartFormData.append(UIImageJPEGRepresentation(self.ivAvatar.image!, 1.0)!, withName: "fileToUpload", fileName: "photo.jpg", mimeType: "image/jpeg")
                debugPrint(multipartFormData)
            },
            to: urlString,
            headers: headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        print("Request: \(response.request?.httpMethod as! String) \(response.request!)")
                        print("Response: \(response.response?.statusCode as! Int) (\(response.data!))")
                        debugPrint(response.result)

                        switch response.result {
                        case .success:
                            if let result = response.result.value{
                                let JSON = result as! NSDictionary
                                if JSON.value(forKey: "status") as! String == "success"
                                {
                                    user?.user_photo = JSON.value(forKey: "path") as! String
                                    saveUserInfo()

                                    self.userVC?.user_info?["profile_pic"] = JSON.value(forKey: "path") as! String
                                }

                                let alert = UIAlertController(title: "QuantumListing", message: JSON["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
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
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )
    }

    func updateProfileDetail() {

        var parameters = ["user_id":(user?.user_id)!, "username":txtName.text!, "email":txtEmail.text!, "mobile":txtPhone.text!, "website":txtBlog.text!]

        if (txtPassword.text == txtConfirm.text && txtPassword.text?.isEmpty == false) {
            parameters["password"] = txtPassword.text!
        }

        var headers = Alamofire.SessionManager.defaultHTTPHeaders

        if let accessToken = user!.access_token as? String {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else {
            // redirect to login ???
        }

        CircularSpinner.show("Updating", animated: true, type: .indeterminate, showDismissButton: false)
        let urlString = BASE_URL + "/account/updateProfile"
        print("API CALL: \(urlString)")
        print("Params: \(String(describing: parameters))")
        Alamofire.request(urlString, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print("Request: \(response.request?.httpMethod as! String) \(response.request!)")
            print("Response: \(response.response?.statusCode as! Int) (\(response.data!))")
            debugPrint(response.result)

            switch response.result {
            case .success:
                if let result = response.result.value{
                    let JSON = result as! NSDictionary
                    if JSON.value(forKey: "status") as! String == "true"
                    {
                        user?.umail = self.txtEmail.text!
                        user?.password = self.txtPassword.text!
                        user?.uname = self.txtName.text!
                        user?.user_blog = self.txtBlog.text!
                        user?.phone_num = self.txtPhone.text!
                        user?.isUpdatedProfile = true

                        saveUserInfo()

                        self.userVC?.user_info?["email"] = self.txtEmail.text!
                        self.userVC?.user_info?["mobile"] = self.txtPhone.text!
                        self.userVC?.user_info?["website"] = self.txtBlog.text!

                        let alert = UIAlertController(title: "QuantumListing", message: "Profile updated.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
//                    else
//                    {
//                        let alert = UIAlertController(title: "QuantumListing", message: JSON["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
//                    }
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
