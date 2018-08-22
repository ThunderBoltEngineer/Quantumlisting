//
//  DetailViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/22/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import CoreGraphics
import CoreLocation
import CircularSpinner
import Alamofire
import UXMPDFKit
import WebKit


class DetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UICollectionViewDataSource{

    var lastDistance : CGFloat = 0.0
    var lastPoint = CGPoint.zero

    var imgStartWidth : CGFloat = 0.0
    var imgStartHeight : CGFloat = 0.0

    var hasChanges: Bool = false
    var listing_user : NSDictionary?
    var listing_property : NSDictionary?
    var listing_image : NSDictionary?
    var listing_images : NSArray?

    var galleryUrls : [String] = [String]()

    var activeField : UIView?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var btnAddress: UIButton!
    @IBOutlet weak var btnViews: UIButton!

    @IBOutlet weak var heightOfContent: NSLayoutConstraint!
//
//    @IBOutlet weak var btnGlobe: UIButton!
//    @IBOutlet weak var btnPhone: UIButton!
//    @IBOutlet weak var btnEmail: UIButton!
//    @IBOutlet weak var vwContact: UIView!
//    @IBOutlet weak var lblDate: UILabel!
//    @IBOutlet weak var ivPortrait: UIImageView!
//    @IBOutlet weak var ivAvartar: UIImageView!
//    @IBOutlet weak var vwPortrait: UIView!
//    @IBOutlet weak var lblBy: UILabel!
    @IBOutlet weak var kiLabel: UILabel!
    @IBOutlet weak var vwDetails: UIView!
    @IBOutlet weak var txtComments: UITextView!
    @IBOutlet weak var txtEditTitle: UITextField!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var txtLeaseType: UITextField!
    @IBOutlet weak var txtAssetType: UITextField!
    @IBOutlet weak var txtFTAvailable: UITextField!
    @IBOutlet weak var txtParking: UITextField!
    @IBOutlet weak var txtOffices: UITextField!
    @IBOutlet weak var txtBathrooms: UITextField!
    @IBOutlet weak var txtFloors: UITextField!
    @IBOutlet weak var txtEVCharging: UITextField!
    @IBOutlet weak var txtDateAvailable: UITextField!
//    @IBOutlet weak var labelAmount: UILabel!
//    @IBOutlet weak var labelType: UILabel!
//    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var buttonScroll: UIButton!
    @IBOutlet weak var collectionGallery: UICollectionView!
    @IBOutlet weak var buttonImgCount: UIButton!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblBy: UILabel!
    @IBOutlet weak var lblUserType: UILabel!
    @IBOutlet weak var btnEmail: UIButton!
    @IBOutlet weak var btnPhone: UIButton!
    @IBOutlet weak var btnGlobe: UIButton!
    @IBOutlet weak var btnSkype: UIButton!
    @IBOutlet weak var webDescription: WKWebView!

    @IBOutlet weak var collectionThumbnail: UICollectionView!



    var listing : NSDictionary?
    var isOwner : Bool?
    var isFavorite : Int?
    var listingVC : ListingTableViewController?

    var scrollViewShouldMoveUp : Bool = true

    @IBAction func actScrollRepeat(_ sender: Any) {
        var currentOffset = scrollView.contentOffset
        currentOffset.y += 50;
        if (currentOffset.y <= scrollView.contentSize.height - 500) {
            scrollView.setContentOffset(currentOffset, animated: true)
        }
    }

    @IBAction func actScroll(_ sender: Any) {
        var currentOffset = scrollView.contentOffset
        currentOffset.y += 50;
        if (currentOffset.y <= scrollView.contentSize.height - 500) {
            scrollView.setContentOffset(currentOffset, animated: true)
        }
    }

    @IBAction func actShare(_ sender: Any) {

        if collectionGallery.visibleCells.count <= 0 {
            return
        }

        let visibleCell = collectionGallery.visibleCells[0]
//        debugPrint((visibleCell.viewWithTag(1) as! UIImageView).image)

        //let txtToShare = "Visit QuantumListing.com for more information on this listing"
//        let capturedImage = snapshot()

        //let objectsToShare = [UIImageJPEGRepresentation(capturedImage!, 0.6)] as [Any]
        //let objectsToShare = [self.listing_property?["property_name"] as! String, URL(string: "https://quantumlisting.com/single-property/\(self.listing_property?["property_id"] as! String)/")!, (visibleCell.viewWithTag(1) as! UIImageView).image! ] as [Any]
        var objectsToShare = ["\(self.listing_property?["property_name"] as! String)\n\n\(self.listing_property?["url"] as? String ?? "")"] as [Any]
        print("SHARE OBJECT: \(objectsToShare)")
        if (visibleCell.viewWithTag(1) as! UIImageView).image != nil {
            objectsToShare.append((visibleCell.viewWithTag(1) as! UIImageView).image)
        }


        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

        self.navigationController?.present(activityVC, animated: true, completion: nil)

        if (activityVC.responds(to: #selector(getter: popoverPresentationController))) {
            let presentationController = activityVC.popoverPresentationController

            presentationController?.sourceView = sender as? UIView
        }

    }

    @IBAction func onMapView(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController

        let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees((listing_property?["latitude"] as! NSString).doubleValue), CLLocationDegrees((listing_property?["lognitude"] as! NSString).doubleValue))
        if (coordinate.latitude != 0 && coordinate.longitude != 0) {
            mapVC.selectedLocation = coordinate
            mapVC.listing_email = listing_user?.object(forKey: "email") as? String
            mapVC.listing_phone = listing_user?.object(forKey: "mobile") as? String
            mapVC.listing_website = listing_user?.object(forKey: "website") as? String

            self.navigationController?.pushViewController(mapVC, animated: true)
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no map location was added.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }


    @IBAction func actReport(_ sender: Any) {
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)

//        let viewAction = UIAlertAction(title: "View on Map", style: .default) { (alert: UIAlertAction!) -> Void in
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let mapVC = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
//
//            let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees((self.listing_property?["latitude"] as! NSString).doubleValue), CLLocationDegrees((self.listing_property?["lognitude"] as! NSString).doubleValue))
//            if (coordinate.latitude != 0 && coordinate.longitude != 0) {
//                mapVC.selectedLocation = coordinate
//                mapVC.listing_email = self.listing_user?.object(forKey: "email") as? String
//                mapVC.listing_phone = self.listing_user?.object(forKey: "mobile") as? String
//                mapVC.listing_website = self.listing_user?.object(forKey: "website") as? String
//
//                self.navigationController?.pushViewController(mapVC, animated: true)
//            }
//            else {
//                let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no map location was added.", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//            }
//        }

        let galleryAction = UIAlertAction(title: "Open Gallery", style: .default){
            (alert : UIAlertAction!) -> Void in

            let galleryVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryViewController") as! GalleryViewController
            galleryVC.property_id = self.listing_property?["property_id"] as! String

            self.navigationController?.pushViewController(galleryVC, animated: true)

        }

        let attachAction = UIAlertAction(title: "Open Attachment", style: .default) { (alert: UIAlertAction!) -> Void in
            let attachment = (self.listing_property?["document"] as? String ?? "") as! NSString
            if(attachment.pathExtension == "pdf") {
                let pdfURL = URL(string: attachment as String)
                self.downloadPDFIfFromWeb(pdfURL: pdfURL!)
            }
            else {
                let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no attachment was added.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }

        let watchVideoAction = UIAlertAction(title: "Watch Video", style: UIAlertActionStyle.default) { (alert: UIAlertAction!) in
            self.actPlayVideo()
        }

        let favAction = UIAlertAction(title: self.isFavorite as? Int == 0 ? "Save to Favorites" : "Remove from Favorites", style: UIAlertActionStyle.default) { (alert: UIAlertAction!) in

            if self.isValidMembership() {
                self.productPurchased()
            }
            else {
                let alert = UIAlertController(title: "QuantumListing", message: "Please upgrade your membership to access all Premium features of QuantumListing.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)

            }
        }

        let flagAction = UIAlertAction(title: "Flag As Inappropriate", style: UIAlertActionStyle.default) { (alert: UIAlertAction!) in
            self.reportProperty(self.listing_property?["property_id"] as! String)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alert: UIAlertAction!) in

        }

        //actionSheet.addAction(viewAction)
        actionSheet.addAction(galleryAction)
        actionSheet.addAction(attachAction)
        actionSheet.addAction(watchVideoAction)
        actionSheet.addAction(favAction)
        //actionSheet.addAction(flagAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion:nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        var contentRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        for view in self.contentView.subviews {
            contentRect = contentRect.union(view.frame)
        }
        heightOfContent.constant = contentRect.size.height + 20
        // Do any additional setup after loading the view.

        //self.registerForKeyboardNotifications()
        self.configureUserInterface()
        hasChanges = false
        //vwContact.layer.cornerRadius = 5.0
        //vwContact.layer.masksToBounds = true

        getGalleryList()

        getVisitCount(completionHandler: {
            self.logVisitEvent()
        })

    }

    func logVisitEvent()
    {
        let parameters = ["property_id" : self.listing_property!["property_id"] as! String]
        let urlString = BASE_URL + "/listings/setViewed"
        print("API CALL: \(urlString)")
        print("Params: \(String(describing: parameters))")
        Alamofire.request(urlString, method: .get, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            print("Request: \(response.request?.httpMethod as! String) \(response.request!)")
            print("Response: \(response.response?.statusCode as! Int) (\(response.data!))")
            debugPrint(response.result)

            switch response.result {
            case .success:
                break

            case .failure(let error):
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                }
            }
        }

    }

    func getVisitCount(completionHandler : @escaping ()->Void)
    {
        //log page view event
        let parameters = ["property_id" : self.listing_property!["property_id"] as! String]
        let urlString = BASE_URL + "/listings/getViews"
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
                    // TODO CHECK JSON["status"] && JSON["status"] as! Int == 0
                    
                    let result = JSON["totalsForAllResults"] as? NSDictionary
                    let viewCount = result?.value(forKey: "ga:pageviews")

                    if viewCount != nil
                    {
                        let title = "    "
                        self.btnViews.setTitle(title + String(format: "%@", viewCount as! CVarArg) + " View(s)", for: .normal)
                    }
                }

            case .failure(let error):
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                }

                let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func getGalleryList()
    {
        var headers = Alamofire.SessionManager.defaultHTTPHeaders

        if let accessToken = user!.access_token as? String {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else {
            // redirect to login ???
        }

        let parameters = ["property_id" : self.listing_property!["property_id"] as! String]

        let urlString = BASE_URL + "/listings/listingImagesById"
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
                    let resultImages = JSON["images"] as? [String]

                    if resultImages != nil
                    {

                        for imgUrl in resultImages!
                        {
                            self.galleryUrls.append(imgUrl)
                        }

                        self.buttonImgCount.setTitle(String(resultImages!.count), for: .normal)
                    }
                    else
                    {
                        self.galleryUrls.append(self.listing_image!["property_image"] as! String)
                    }

                    print("GALLERY URLS: \(self.galleryUrls)")

                    self.collectionGallery.reloadData()
                    self.collectionThumbnail.reloadData()
                }

            case .failure(let error):
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                }

                let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryUrls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == collectionGallery
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath)

            let imageView = cell.viewWithTag(1) as! UIImageView
            imageView.setIndicatorStyle(.gray)
            imageView.setShowActivityIndicator(true)
            imageView.sd_setImage(with: URL(string : galleryUrls[indexPath.row])!)

        //imageView.ImageFromURL(url: galleryUrls[indexPath.row], indicatorColor: .gray, errorImage: UIImage(), imageView: imageView)

            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"ThumbnailCell", for: indexPath)

            let imageView = cell.viewWithTag(1) as! UIImageView
            imageView.setIndicatorStyle(.gray)
            imageView.setShowActivityIndicator(true)
            imageView.sd_setImage(with: URL(string : galleryUrls[indexPath.row])!)

            //imageView.ImageFromURL(url: galleryUrls[indexPath.row], indicatorColor: .gray, errorImage: UIImage(), imageView: imageView)

            return cell
        }

    }



    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
//        vwPortrait.layer.cornerRadius = vwPortrait.bounds.width/2.0
//        vwPortrait.layer.masksToBounds = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        txtComments.setContentOffset(CGPoint.zero, animated: false)

    }

    func configureUserInterface() {
        listing_image = (listing?["property_image"] is NSArray) ? ((listing?["property_image"] as! NSArray)[0] as! NSDictionary) :  (listing?["property_image"] as! NSDictionary)

        //listing_image = listing_images
        listing_property = listing?["property_info"] as? NSDictionary
        listing_user = listing?["user_info"] as? NSDictionary
        if (listing_user == nil) {
            return
        }
        self.kiLabel.text = listing_property?["property_name"] as? String
        self.lblBy.text = listing_user?["full_name"] as? String
        self.lblUserType.text = listing_user?["type"] as? String

        if(listing_image != nil) {
            let strURL = listing_image?["property_image"] as? String

        }

        let favorites = listing_property?["favorites"] as? NSArray

        isFavorite = 0
        for item in favorites!
        {
            let user_id = (item as! NSNumber).stringValue
            if (user_id == user!.user_id as? String) {
                isFavorite = 1
            }
        }

        lastPoint = CGPoint(x: 0, y: 0)

        btnEmail.setTitle(listing_user?["email"] as! String?, for: .normal)
        btnPhone.setTitle(listing_user?["mobile"] as? String, for: .normal)
        btnGlobe.setTitle(listing_user?["website"] as? String, for: .normal)
        btnSkype.setTitle("", for: .normal)

        self.txtEditTitle.isHidden = false
        
        
        if isOwner! {
            //vwDetails.isUserInteractionEnabled = true
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit",
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(self.startEdit))
        }
//        else {
        if(true) {
            vwDetails.isUserInteractionEnabled = false

            for subView in vwDetails.subviews
            {
                if subView.tag == 1
                {
                    subView.isUserInteractionEnabled = true
                }
                else
                {
                    subView.isUserInteractionEnabled = false
                }
            }

            txtComments.isSelectable = false
            txtComments.isEditable = false
            txtEditTitle.isHidden = true
        }

//        ivAvartar.layer.cornerRadius = ivAvartar.bounds.width / 2.0
//        ivAvartar.layer.masksToBounds = true
//
        let strAvatar = listing_user?["profile_pic"] as! String?
        if ((strAvatar) != nil && strAvatar != "") {
//            ivAvatar.setImageWith(URL(string: strAvatar!)!)
            ivAvatar.sd_setImage(with: URL(string: strAvatar!)!, placeholderImage: UIImage(named: "my_avatar_icon.png"))
        }
//        if(listing?["time_elapsed"] != nil)
//        {
//            lblDate.text = String(format: "%d days", abs((listing?["time_elapsed"] as! NSString).integerValue))
//        }

        txtLeaseType.text = listing_property?["property_for"] as? String
        txtAssetType.text = listing_property?["property_type"] as? String
        txtFTAvailable.text = listing_property?["area"] as? String
        txtDateAvailable.text = listing_property?["date_available"] as? String
        
        let htmlData = NSString(string: listing_property?["description"] as? String ?? "No description").data(using: String.Encoding.unicode.rawValue)
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        let attributedString = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)
        txtComments.attributedText = attributedString
//        webDescription.loadHTMLString(listing_property?["description"] as? String ?? "", baseURL: nil)
//        webDescription.evaluateJavaScript("document.getElementsByTagName('body')[0].style.fontFamily =\"-apple-system\"", completionHandler: nil)
//        webDescription.evaluateJavaScript("document.getElementsByTagName('body')[0].style.fontSize = 20px", completionHandler: nil)
//
//        let font = UIFont.systemFont(ofSize: 20)
//        webDescription.loadHTMLString("<span style=\"font-family: \(font.fontName); color: #21367B\">\(listing_property?["description"] as? String ?? "")</span>", baseURL: nil)
        
        txtParking.text = listing_property?["parking"] as? String
        txtOffices.text = listing_property?["offices"] as? String
        txtBathrooms.text = listing_property?["bathrooms"] as? String
        txtFloors.text = listing_property?["floors"] as? String
        txtEVCharging.text = listing_property?["ev_charging"] as? String

        if listing_property?["amount"] != nil
        {
            txtAmount.text = "$\((listing_property?["amount"] as! String))"

            let strLeaseType = listing_property?["property_for"] as! String
            if strLeaseType.lowercased().range(of: "sale & lease") != nil {
                if (listing_property?["rent"] != nil &&
                    (listing_property?["rent"] as? String ?? "") != "" &&
                    Float(listing_property?["rent"] as! String)! > 0.0) {
                    txtAmount.text = "$\((listing_property?["amount"] as! String))/\(listing_property?["rent"] as! String)"
                }
            }
        }

        btnAddress.setTitle("   \(listing_property?["address"] as! String)", for: .normal)

        buttonScroll.layer.cornerRadius = buttonScroll.frame.size.height / 2
        buttonScroll.layer.masksToBounds = true

        txtComments.layer.cornerRadius = 5
        txtComments.layer.borderColor = Utilities.borderGrayColor.cgColor
        txtComments.layer.borderWidth = 1
        txtComments.layer.masksToBounds = true

        for subView in vwDetails.subviews
        {
            if subView.tag == 0
            {
                if subView is UITextField
                {
                    subView.layer.sublayerTransform = CATransform3DMakeTranslation(-20, 0, 0)
                }
                else
                {
                    subView.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0)
                }
                subView.layer.borderWidth = 0.5
                subView.layer.borderColor = Utilities.borderGrayColor.cgColor
            }
        }


        if scrollViewShouldMoveUp == true
        {
            scrollView.contentInset = UIEdgeInsets(top: -44, left: 0, bottom: 0, right: 0)
        }

    }


    func didClickedHashtag(hashtag: NSString) {

    }

    func didClickedUsername(username: NSString) {

    }
    
    @objc func startEdit() {
        if isOwner! {
            vwDetails.isUserInteractionEnabled = true
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(self.actSaveChanges))
            
            for subView in vwDetails.subviews
            {
                if subView.tag == 1
                {
                    subView.isUserInteractionEnabled = false
                }
                else
                {
                    subView.isUserInteractionEnabled = true
                }
            }
            
            txtComments.isSelectable = true
            txtComments.isEditable = true
            txtEditTitle.isHidden = false
            
            // Scroll view to top immediately without animation to prevent UI down-layouted on focus
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            
            // Set focus to start edit from title
            txtEditTitle.becomeFirstResponder()
        }
    }
    
    @objc func finishEdit() {
        if isOwner! {
            vwDetails.isUserInteractionEnabled = false
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit",
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(self.startEdit))
            
            for subView in vwDetails.subviews
            {
                if subView.tag == 1
                {
                    subView.isUserInteractionEnabled = true
                }
                else
                {
                    subView.isUserInteractionEnabled = false
                }
            }
            
            txtComments.isSelectable = false
            txtComments.isEditable = false
            txtEditTitle.isHidden = true
        }
    }

    func pinchGestureDetected(recognizer: UIPinchGestureRecognizer) {
        let state = recognizer.state
        if (state == UIGestureRecognizerState.began || state == UIGestureRecognizerState.changed) {
            let scale = recognizer.scale
            recognizer.view?.transform = (recognizer.view?.transform.scaledBy(x: scale, y: scale))!
            recognizer.scale = 1.0
        }
    }

    func rotateGestureDetected(recognizer: UIRotationGestureRecognizer) {
        self.adjustAnchorPointForGestureRecognizer(recognizer)
        if (recognizer.state == UIGestureRecognizerState.began || recognizer.state == UIGestureRecognizerState.changed) {
            recognizer.view?.transform = (recognizer.view?.transform.rotated(by: recognizer.rotation))!
            recognizer.rotation = 0.0
        }
    }

    func adjustAnchorPointForGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if (gestureRecognizer.state == UIGestureRecognizerState.began) {
            let piece = gestureRecognizer.view
            let locationView = gestureRecognizer.location(in: piece)
            let locationInSuperview = gestureRecognizer.location(in: piece?.superview)

            piece?.layer.anchorPoint = CGPoint(x: locationView.x / (piece?.bounds.size.width)!, y: locationView.y / (piece?.bounds.size.height)!)
            piece?.center = locationInSuperview
        }
    }

    func panGestureDetected(recognizer: UIPanGestureRecognizer) {
        let state = recognizer.state
        if (state == UIGestureRecognizerState.began || state == UIGestureRecognizerState.changed) {
            let translation = recognizer.translation(in: recognizer.view)
            recognizer.view?.transform = (recognizer.view?.transform.translatedBy(x: translation.x, y: translation.y))!
            recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func actSaveChanges(popView : Bool = false) {
        self.view.endEditing(true)
        
        if (hasChanges) {
            //update property details
            let main_params: NSMutableDictionary = [
                "user_id": (user!.user_id),
                "property_name": self.kiLabel.text!,
                "property_type" : self.txtAssetType.text!,
                "property_for" : self.txtLeaseType.text!,
                "description": self.txtComments.text!,
                "area": self.txtFTAvailable.text!,
                "date_available" : self.txtDateAvailable.text!
            ]

            let strAmount = self.txtAmount.text!
            let strLeaseType = self.txtLeaseType.text!

            let priceArr = strAmount.components(separatedBy: "/")
            main_params.setValue(priceArr[0].replacingOccurrences(of: "$", with: ""), forKey: "amount")

            if priceArr.count > 1 {
                if strLeaseType.lowercased().range(of: "sale & lease") != nil {
                    main_params.setValue(priceArr[1].replacingOccurrences(of: "$", with: ""), forKey: "rent")
                }
            }

            let detail_params: NSMutableDictionary = [
                "parking": self.txtParking.text!,
                "offices": self.txtOffices.text!,
                "bathrooms": self.txtBathrooms.text!,
                "floors": self.txtFloors.text!,
                "ev_charging": self.txtEVCharging.text!
            ]

            let parameters: Parameters = ["property_id":self.listing_property!["property_id"] as! String , "main_params": main_params, "detail_params": detail_params]

            var headers = Alamofire.SessionManager.defaultHTTPHeaders

            if let accessToken = user!.access_token as? String {
                headers["Authorization"] = "Bearer \(accessToken)"
            } else {
                // redirect to login ???
            }

            CircularSpinner.show("Updating", animated: true, type: .indeterminate, showDismissButton: false)
            let urlString = BASE_URL + "/profile/updateProperty"
            print("API CALL: \(urlString)")
            print("Params: \(String(describing: parameters))")
            Alamofire.request(urlString, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON(completionHandler: {
                response in
                print("Request: \(response.request?.httpMethod as! String) \(response.request!)")
                print("Response: \(response.response?.statusCode as! Int) (\(response.data!))")
                debugPrint(response.result)

                switch response.result
                {
                case .success:
                    if let result = response.result.value{
                        let JSON = result as! NSDictionary
                        if (JSON["success"] as! Int) == 1 {
                            
                            self.finishEdit()
                            self.hasChanges = false
                            
                            if (popView) {
                                self.navigationController?.popViewController(animated: true)
                            }
                            
                            if self.listingVC != nil {
                                self.listingVC?.updateData()
                            }
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

                    let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                self.view.endEditing(true)
                CircularSpinner.hide()
            })
        }
        else {
            self.finishEdit()
        }
    }

    @IBAction func onBackTapped(_ sender: Any) {
        textFieldShouldReturn(txtEditTitle)

        if (hasChanges) {
            let alert = UIAlertController(title: "QuantumListing", message: "Do you want to save changes?", preferredStyle: UIAlertControllerStyle.alert)
            let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: {
                alert in

                self.actSaveChanges(popView: true)
            })
            let cancelAction = UIAlertAction(title: "Discard", style: UIAlertActionStyle.cancel) { (alert: UIAlertAction!) in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func isValidMembership() -> Bool {
        let str_end = user!.ms_endDate
        let endDate = Utilities.date(fromString: str_end)
        if (endDate.timeIntervalSinceNow > 0) {
            return true
        }
        return false
    }

    // PDF Management

    func isFromWeb(pdfURL: URL) -> Bool {
        if (pdfURL.scheme == "file") {
            return false
        }
        return true
    }

    func downloadPDFIfFromWeb(pdfURL :URL) {

        if self.isFromWeb(pdfURL: pdfURL) {
            let pdfName = pdfURL.lastPathComponent
            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let path = URL(fileURLWithPath: paths[0]).appendingPathComponent(pdfName)

            let request = URLRequest(url: pdfURL)

            // When
            CircularSpinner.show("Opening", animated: true, type: .indeterminate, showDismissButton: false)
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in

                return (path, [.removePreviousFile, .createIntermediateDirectories])
            }
            print("DOWNLOAD API CALL: \(pdfURL)")
            Alamofire.download(request, to: destination).response { response in
                print("Request: \(response.request?.httpMethod as! String) \(response.request!)")
                print("Response: \(response.response?.statusCode as! Int)")

                if response.response?.statusCode == 404 {
                    let alert = UIAlertController(title: "QuantumListing", message: "Cannot open : PDF Not Found.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else if response.error == nil, let downloadPath = response.destinationURL?.path {
                    self.openLocalPdf(URL(string: downloadPath)!)
                }
                CircularSpinner.hide()
            }
        }
        else {
            self.openLocalPdf(pdfURL)
        }
    }

    func openLocalPdf(_ localPath : URL) {
        do {
            let filePath = localPath.path

            print("Trying to open PDF: \(filePath)")
            let document = try PDFDocument(filePath: filePath, password: "password_if_needed")
            let pdf = PDFViewController(document: document)

            self.navigationController?.pushViewController(pdf, animated: true)
        }
        catch let error {
            print(error)

            let alert = UIAlertController(title: "QuantumListing", message: "Error occured while opening : \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func dismissReaderViewController() {
        self.navigationController?.popViewController(animated: true)
    }

    // Property Management

    func reportProperty(_ property_id : String) {
        let parameters = ["property_id": property_id, "user_id": (user?.user_id)!]

        CircularSpinner.show("Reporting", animated: true, type: .indeterminate, showDismissButton: false)
        let urlString = BASE_URL + "/listings/flagProperty"
        print("API CALL: \(urlString)")
        print("Params: \(String(describing: parameters))")
        Alamofire.request(urlString, method: .get, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            print("Request: \(response.request?.httpMethod as! String) \(response.request!)")
            print("Response: \(response.response?.statusCode as! Int) (\(response.data!))")
            debugPrint(response.result)

            switch response.result {
            case .success:
                let alert = UIAlertController(title: "QuantumListing", message: "Successfully reported.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)

            case .failure(let error):
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                }

                let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            CircularSpinner.hide()
        }
    }

    func favorite_property() {

        var headers = Alamofire.SessionManager.defaultHTTPHeaders

        if let accessToken = user!.access_token as? String {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else {
            // redirect to login ???
        }

        let parameters = ["property_id": listing_property?["property_id"], "user_id": (user?.user_id)!]

        CircularSpinner.show("", animated: true, type: .indeterminate, showDismissButton: false)
        let urlString = BASE_URL + "/profile/addToFavorites"
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
                    let status = JSON["status"] as! Int
                    self.isFavorite = status

                    let alert = UIAlertController(title: "QuantumListing", message: JSON["message"] as! String, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)

                    if self.listingVC != nil {
                        self.listingVC?.updateData()
                    }
                }

            case .failure(let error):
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                }

                let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            CircularSpinner.hide()
        }
    }

    // IAP Management

    func productPurchased() {
        self.favorite_property()
    }

    // MARK : - TextField Delegate Methods

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField

        if activeField != txtEditTitle
        {
            kiLabel.isHidden = false
        }

        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        hasChanges = true
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtEditTitle
        {
        kiLabel.isHidden = true
        txtEditTitle.text = kiLabel.text
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtEditTitle
        {
        kiLabel.text = txtEditTitle.text
        txtEditTitle.text = ""
        kiLabel.isHidden = false

        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

            textField.resignFirstResponder()
            activeField = nil
            return true

    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {

        activeField = textView

        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        hasChanges = true
    }

    // MARK : - User taps on gallery count btn

    @IBAction func actImgCount(_ sender: Any) {

        if galleryUrls.count > 0
        {

            let galleryVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryViewController") as! GalleryViewController
            galleryVC.property_id = self.listing_property?["property_id"] as! String

            self.navigationController?.pushViewController(galleryVC, animated: true)
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

    // MARK : - Contact Form

    @IBAction func actUserAvatar(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let userVC = storyboard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
        userVC.user_info = NSMutableDictionary(dictionary: listing_user!)
        self.navigationController?.pushViewController(userVC, animated: true)
    }


    @IBAction func actEmail(_ sender: Any) {

        let listing_email = listing_user?.object(forKey: "email") as? String
        if (listing_email != nil) {
            UIApplication.shared.open(URL(string: "mailto:\(listing_email!)")!, options: [:], completionHandler: nil)
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no valid email address has been entered.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func actPhone(_ sender: Any) {

        var listing_phone = listing_user?.object(forKey: "mobile") as? String
        if (listing_phone != nil) {
            listing_phone = listing_phone?.replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "+", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")

            let url = URL(string: "tel:\(listing_phone!)")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no valid phone number has been entered.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func actSkype(_ sender: Any) {

        //TODO
    }

    @IBAction func actWebsite(_ sender: Any) {

        let listing_website = listing_user?.object(forKey: "website") as? String
        if ((listing_website != nil) && ((listing_website?.characters.count)! > 4)) {
            let index = listing_website?.index((listing_website?.startIndex)!, offsetBy: 4)
            if (listing_website?.substring(to: index!) == "http") {
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

    func actPlayVideo() {
        let video_url = listing_property!["video_url"] as? String ?? ""

        if video_url == ""
        {
            let alert = UIAlertController(title: "QuantumListing", message: "Sorry, this listing has no video.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            //play video
            let videoPlayerVC = YoutubeVideoPlayerViewController(videoIdentifier: video_url)
            self.present(videoPlayerVC, animated: true, completion: nil)
        }
    }

    func snapshot() -> UIImage?
    {
        //UIGraphicsBeginImageContext(scrollView.contentSize)
        UIGraphicsBeginImageContextWithOptions(scrollView.contentSize,  scrollView.isOpaque, 0.0)

        let savedContentOffset = scrollView.contentOffset
        let savedFrame = scrollView.frame;

        scrollView.contentOffset = CGPoint.zero;
        scrollView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height);

        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext();

        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;

        UIGraphicsEndImageContext();

        return image
    }

}

