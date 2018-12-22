//
//  UserViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/22/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import BSKeyboardControls
import CircularSpinner
import Alamofire

class UserViewController: UIViewController ,BSKeyboardControlsDelegate, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, DLCImagePickerDelegate{

    @IBOutlet weak var lblReminder: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var buttonWebsite: UIButton!
    @IBOutlet weak var buttonPhone: UIButton!
    @IBOutlet weak var buttonEmail: UIButton!
    @IBOutlet weak var vwPortrait: UIView!
    @IBOutlet weak var ivAvartar: UIImageView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var btnUpload: UIButton!
    @IBOutlet weak var txtBio: UITextView!
    @IBOutlet weak var lblListings: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var lblNotification: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSettings: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUserType: UILabel!
    @IBOutlet weak var lblMembership: UILabel!
    @IBOutlet weak var lblMembershipConstraint: NSLayoutConstraint!

    var user_info : NSMutableDictionary?
    var is_following: Bool?
    var listing: NSMutableArray?
    let kCollectionCellId = "CollectionCell"
    @IBOutlet weak var followBtnHConstraint: NSLayoutConstraint!
    var keyboardControls: BSKeyboardControls?
    var userFollowings : [String] = [String]()
    var userFollowers : [String] = [String]()
    var followerTapped = true

    override func viewDidLoad() {
        super.viewDidLoad()

        is_following = false

        self.collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: kCollectionCellId)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.layer.cornerRadius = 2.0
        vwPortrait.layer.cornerRadius = vwPortrait.bounds.width / 2.0
        vwPortrait.layer.masksToBounds = true
        listing = NSMutableArray()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true

        self.configureUserInterface()
        self.getProfileInfo()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configureUserInterface() {
        if user_info == nil
        {
            return
        }

        if (user_info?["user_id"] as? String) == user?.user_id
        {
            if ((self.navigationController?.viewControllers.count)! > 1) {
                btnBack.isHidden = false
            }
            else {
                btnBack.isHidden = true
            }

            btnUpload.isHidden = false
            //txtBio.isEditable = true
            btnFollow.isHidden = true
            followBtnHConstraint.constant = 0.0

            btnAccount.isHidden = false
            btnSettings.isHidden = false
//            buttonWebsite.isUserInteractionEnabled = false
//            buttonPhone.isUserInteractionEnabled = false
//            buttonEmail.isUserInteractionEnabled = false
            keyboardControls = BSKeyboardControls()
            keyboardControls?.delegate = self

            if !(user?.isUpdatedProfile)! {
                lblReminder.isHidden = false
            }
            lblName.text = user?.uname

            lblMembership.text = membershipDescrption()
        }
        else {
            lblTitle.text = "Profile"
            lblName.text = user_info?["full_name"] as! String?
            btnBack.isHidden = false
            btnUpload.isHidden = true

            btnFollow.isHidden = false
            btnAccount.isHidden = true
            btnSettings.isHidden = true
            buttonWebsite.isHidden = false
            buttonEmail.isHidden = false
            buttonPhone.isHidden = false

            lblMembership.isHidden = true
            lblMembershipConstraint.constant = 0.0
        }
        let path = user_info?["profile_pic"] as? String
        if path != nil && (path?.count)! > 0 {
            self.ivAvartar.setShowActivityIndicator(true)
            self.ivAvartar.setIndicatorStyle(.gray)
            self.ivAvartar.sd_setImage(with: URL(string: path as! String)!)

            self.imgProfile.isHidden = true
        }

        //
        buttonEmail.setTitle("  \(user_info?["email"] as? String ?? "(no data)")", for: .normal)
        buttonWebsite.setTitle("  \(user_info?["website"] as? String ?? "(no data)")", for: .normal)
        buttonPhone.setTitle("  \(user_info?["mobile"] as? String ?? "(no data)")", for: .normal)

        lblUserType.text = user_info?["type"] as? String


        //add tap gestures to follower & following label
        lblFollowers.isUserInteractionEnabled = true
        lblFollowing.isUserInteractionEnabled = true
        lblFollowers.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapFollower)))
        lblFollowing.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapFollowing)))
    }

    @objc func onTapFollower(_ : UITapGestureRecognizer)
    {
        self.followerTapped = true
        performSegue(withIdentifier: "ProfileToUserList", sender: nil)
    }

    @objc func onTapFollowing(_ : UITapGestureRecognizer)
    {
        self.followerTapped = false
        performSegue(withIdentifier: "ProfileToUserList", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "ProfileToUserList"
        {
            let vc = segue.destination as! FollowUserTableViewController

            if followerTapped == true
            {
                vc.userIdList = self.userFollowers
                vc.navTitle = "FOLLOWERS"
            }
            else
            {
                vc.userIdList = self.userFollowings
                vc.navTitle = "FOLLOWING"
            }
        }

        //super.prepare(for: segue, sender: sender)
    }


    func getProfileInfo() {
        if user_info == nil
        {
            return
        }


        var headers = Alamofire.SessionManager.defaultHTTPHeaders

        if let accessToken = user!.access_token as? String {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else {
            // redirect to login ???
        }

        let parameters = ["user_id": user_info!["user_id"] as? String]

        CircularSpinner.show("Loading", animated: true, type: .indeterminate, showDismissButton: false)
        let urlString = BASE_URL + "/profile/getProfileById"
        print("API CALL: \(urlString)")
        print("Params: \(String(describing: parameters))")
        Alamofire.request(urlString, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print("Request: \(response.request?.httpMethod as! String) \(response.request!)")
            print("Response: \(response.response?.statusCode as! Int) (\(response.data!))")
            debugPrint(response.result)

            switch response.result {
            case .success:
                if let result = response.result.value{
                    let JSON = result as! NSDictionary
                    // TODO CHECK JSON["status"] && JSON["status"] as! Int == 0
                    
                    if (self.listing?.count)! > 0 {
                        self.listing?.removeAllObjects()
                    }
                    else {
                        self.listing = NSMutableArray()
                    }

                    let user_listings = JSON["user_listings"] as? [Any]
                    if (user_listings != nil) {
                        self.lblListings.text = "\((user_listings?.count)!) Listings"
                        self.listing?.addObjects(from: user_listings!)
                    }
                    else
                    {
                        self.lblListings.text = "0 Listings"
                    }

                    self.collectionView.reloadData()

                    let user_followings = JSON["user_followings"] as? NSArray
                    if (user_followings != nil) {
                        self.lblFollowing.text = "\((user_followings?.count)!) Following"
                        self.userFollowings.removeAll()

                        for item in user_followings!
                        {
                            let user_id = (item as! NSNumber).stringValue
                            self.userFollowings.append(user_id)

                        }
                    }

                    let user_followers = JSON["user_followers"] as? NSArray
                    if (user_followers != nil) {

                        // Check if I am following this user
                        var isFollowing : Bool = false
                        for item in user_followers! {
                            let user_id = (item as! NSNumber).stringValue
                            if (user_id == (user?.user_id)!) {
                                isFollowing = true
                            }
                        }
                        if (isFollowing) {
                            self.is_following = true
                            self.btnFollow.setTitle("Unfollow", for: .normal)
                        }
                        else {
                            self.is_following = false
                            self.btnFollow.setTitle("Follow", for: .normal)
                        }


                        if self.listing?.count == 0 {
                            self.lblNotification.isHidden = false
                        }
                        else
                        {
                            self.lblNotification.isHidden = true
                        }

                        self.lblFollowers.text = "\((user_followers?.count)!) Followers"
                        self.userFollowers.removeAll()

                        for item in user_followers!
                        {
                            let user_id = (item as! NSNumber).stringValue
                            self.userFollowers.append(user_id)
                        }
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

    @IBAction func actSettings(_ sender: Any) {
    }

    @IBAction func actBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func actAccount(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
//        vc.delegate = self.delegate
        vc.userVC = self

        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func actFollow(_ sender: Any) {
        if !is_following! {
            self.follow_user()
        }
        else {
            self.unfollow_user()
        }
    }
    @IBAction func actUpload(_ sender: Any) {


    }
    @IBAction func onEmail(_ sender: Any) {
        let listing_email = user_info?["email"] as? String
        if (listing_email != nil) {
            UIApplication.shared.open(URL(string: "mailto:\(listing_email!)")!, options: [:], completionHandler: nil)
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no valid email address has been entered.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    }

    @IBAction func onPhone(_ sender: Any) {
        var listing_phone = user_info?["mobile"] as? String
        if (listing_phone != nil) {
            listing_phone = listing_phone?.replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "+", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
            UIApplication.shared.open(URL(string: "tel:\(listing_phone!)")!, options: [:], completionHandler: nil)
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no valid phone number has been entered.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func onWebsite(_ sender: Any) {
        let listing_website = user_info?["website"] as? String
        if (listing_website != nil) && (listing_website?.characters.count)! > 4 {
            if (listing_website!.substring(to: (listing_website?.index((listing_website?.startIndex)!, offsetBy: 4))!) == "http") {
                UIApplication.shared.open(URL(string: listing_website!)!, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.open(URL(string: "http://\(listing_website!)")!, options: [:], completionHandler: nil)
            }
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no valid website address has been entered.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func follow_user() {
        var headers = Alamofire.SessionManager.defaultHTTPHeaders

        if let accessToken = user!.access_token as? String {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else {
            // redirect to login ???
        }

        let parameters = ["to_user_id": user_info!["user_id"] as! String, "from_user_id":(user?.user_id)!]

        CircularSpinner.show("", animated: true, type: .indeterminate, showDismissButton: false)
        let urlString = BASE_URL + "/profile/followUser"
        print("API CALL: \(urlString)")
        print("Params: \(String(describing: parameters))")
        Alamofire.request(urlString, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print("Request: \(response.request?.httpMethod as! String) \(response.request!)")
            print("Response: \(response.response?.statusCode as! Int) (\(response.data!))")
            debugPrint(response.result)

            switch response.result {
            case .success:
                if let result = response.result.value{
                    let JSON = result as! NSDictionary
                    if ((JSON["status"] as! String) == "true") {
                        let alert = UIAlertController(title: "QuantumListing", message: "You are now following this user.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)

                        self.getProfileInfo()
                    }
                    else {
                        let alert = UIAlertController(title: "QuantumListing", message: JSON["message"] as! String, preferredStyle: UIAlertControllerStyle.alert)
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

    func unfollow_user() {
        var headers = Alamofire.SessionManager.defaultHTTPHeaders

        if let accessToken = user!.access_token as? String {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else {
            // redirect to login ???
        }

        let parameters = ["to_user_id": user_info!["user_id"] as! String, "from_user_id":(user?.user_id)!]

        CircularSpinner.show("", animated: true, type: .indeterminate, showDismissButton: false)
        let urlString = BASE_URL + "/profile/unfollowUser"
        print("API CALL: \(urlString)")
        print("Params: \(String(describing: parameters))")
        Alamofire.request(urlString, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print("Request: \(response.request?.httpMethod as! String) \(response.request!)")
            print("Response: \(response.response?.statusCode as! Int) (\(response.data!))")
            debugPrint(response.result)

            switch response.result {
            case .success:
                if let result = response.result.value{
                    let JSON = result as! NSDictionary
                    if ((JSON["status"] as! String) == "true") {
                        self.getProfileInfo()
                    }
                    else {
                        let alert = UIAlertController(title: "QuantumListing", message: JSON["message"] as! String, preferredStyle: UIAlertControllerStyle.alert)
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

    // BSKeyboardControls Delegate

    func keyboardControlsDonePressed(_ keyboardControls: BSKeyboardControls!) {
        //self.txtBio.resignFirstResponder()
        self.updateProfileDetail()
    }

    func updateProfileDetail() {
        /*
        //let detail: NSMutableDictionary = ["about_me":txtBio.text, "user_id":(user?.user_id)!]
        let master: NSMutableDictionary = ["user_id":(user?.user_id)!]
        let parameters: NSMutableDictionary = ["detail": detail, "master":master]

        CircularSpinner.show("Updating", animated: true, type: .indeterminate, showDismissButton: false)
        ConnectionManager.sharedClient().post("\(BASE_URL)?apiEntry=update_profile_detail", parameters: parameters, progress: nil, success: {(_ task: URLSessionTask?, _ responseObject: Any) -> Void in
            print("JSON: \(responseObject)")

            //self.user?.user_bio = self.txtBio.text
            self.delegate?.saveUserInfo()

            CircularSpinner.hide()

        }, failure: {(_ operation: URLSessionTask?, _ error: Error?) -> Void in
            print("Error: \(error)")

            let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.debugDescription)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

            self.view.endEditing(true)
            CircularSpinner.hide()
        })
 */
    }

    // UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (listing?.count)!
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCollectionCellId, for: indexPath) as! CollectionCell

        cell.listing = listing?.object(at: indexPath.row) as! NSDictionary?
        cell.configureCell()
        cell.backgroundColor = UIColor.darkGray
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController

        let dict = listing?[indexPath.row] as! NSDictionary
        var listing_images: NSDictionary = [:]

        if dict["images"] is NSDictionary {
            listing_images = dict["images"] as! NSDictionary
        }
        else {
            if (dict["images"] as! NSArray).count > 0 {
                listing_images = (dict["images"] as! NSArray)[0] as! NSDictionary
            }
        }

        let listing_user: NSDictionary = user_info!

        let listing_info: NSDictionary = ["property_info":dict, "property_image":listing_images, "user_info":listing_user]

        vc.listing = listing_info
        vc.scrollViewShouldMoveUp = false
        vc.isOwner = (listing_info["user_info"] as! NSDictionary)["user_id"] as! String == user!.user_id ? true : false
        self.navigationController?.pushViewController(vc, animated: true)

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //DLCPickerController delegate
    func imagePickerControllerDidCancel(_ picker: DLCImagePickerController!) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: DLCImagePickerController!, didFinishPickingMediaWithInfo info: [AnyHashable : Any]!) {
        picker.dismiss(animated: true, completion: nil)

        ivAvartar.image = ((info as NSDictionary).object(forKey: "image") as! UIImage)
        imgProfile.isHidden = true
        self.uploadProfileImage()
    }

    // CHECK DEPRECATED
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
                multipartFormData.append(UIImageJPEGRepresentation(self.ivAvartar.image!, 1.0)!, withName: "fileToUpload", fileName: "photo.jpg", mimeType: "image/jpeg")
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
                                if JSON["status"] as! String == "success"
                                {
                                    user?.user_photo = JSON["path"] as! String
                                    saveUserInfo()
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


    //
    func membershipDescrption() -> String
    {
        let membership_type = user_info?["membership_type"] as! String

        if membership_type == "Premium"
        {
            let end_date = user_info?["membership_end"] as! String

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

            let date_start = Date()
            let date_end = formatter.date(from: end_date)

            let components = Calendar.current.dateComponents([.day], from: date_start, to: date_end!)
            let day_remain = components.day!

            return "\(day_remain) Day Premium"
        }
        else
        {
            return "Free Membership"
        }

    }

}
