//
//  ListingViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/22/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import CoreLocation
import CircularSpinner
import Alamofire
import JVFloatLabeledTextField
import DKImagePickerController

class ListingViewController: UIViewController ,UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate, LCItemPickerDelegate, PDFManageViewControllerDelegate, MapViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource{

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var heightOfContentView: NSLayoutConstraint!
    @IBOutlet weak var txtTitle: JVFloatLabeledTextField!
    @IBOutlet weak var vwDetails: UIView!
    @IBOutlet weak var ivListing: UIImageView!
    @IBOutlet weak var lblUploadPhoto: UILabel!
    @IBOutlet weak var txtDetailComments: UITextView!
    @IBOutlet weak var txtRent: JVFloatLabeledTextField!
    @IBOutlet weak var txtFTAvailable: JVFloatLabeledTextField!
    @IBOutlet weak var txtParking: JVFloatLabeledTextField!
    @IBOutlet weak var txtOffices: JVFloatLabeledTextField!
    @IBOutlet weak var txtBathrooms: JVFloatLabeledTextField!
    @IBOutlet weak var txtFloors: JVFloatLabeledTextField!
    @IBOutlet weak var txtEVCharging: JVFloatLabeledTextField!
    @IBOutlet weak var txtDateAvailable: JVFloatLabeledTextField!
    @IBOutlet weak var vwContacts: UIView!
    @IBOutlet weak var txtContacts: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var btnChooseFile: UIButton!
    @IBOutlet weak var vwBuildingInfo: UIView!
    @IBOutlet weak var txtBuildingType: UITextField!
    @IBOutlet weak var txtLeaseType: UITextField!
    @IBOutlet weak var txtAmountPrice: JVFloatLabeledTextField!
    @IBOutlet weak var collectionThumbnail: UICollectionView!


    var selectedImages: [UIImage] = [UIImage]()
    var attachedPDFURL: URL?
    var currentPlacemark: CLPlacemark?
    var activeField: UIView?
    var isGeneratingPDF: Bool?
    var pickerCategory: LCTableViewPickerControl?
    var pickerLease: LCTableViewPickerControl?
    var theDatePicker: UIDatePicker?
    var pickerToolbar: UIToolbar?
    var pickerViewDate: UIAlertController?
    var pickValue: Any?

    override func viewDidLoad() {
        super.viewDidLoad()

        isGeneratingPDF = true
        self.configureUI()
        self.actChangePhoto(self)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.autoFillContractInfo()
    }

    func autoFillContractInfo() {
        txtEmail.text = user?.umail
        txtPhone.text = user?.phone_num
        txtContacts.text = user?.user_blog
    }

    func resetFields() {
        txtBathrooms.text = ""
        txtDateAvailable.text = ""
        txtDetailComments.text = ""
        txtEVCharging.text = ""
        txtFTAvailable.text = ""
        txtFloors.text = ""
        txtOffices.text = ""
        txtParking.text = ""
        txtRent.text = ""
        txtTitle.text = ""
        ivListing.image = nil
        btnChooseFile.setTitle("", for: .normal)
        attachedPDFURL = nil
        lblUploadPhoto.isHidden = false
        txtBuildingType.text = ""
        txtLeaseType.text = ""
        activeField?.resignFirstResponder()
        txtAmountPrice.text = ""

        self.setCurrentDate()

        self.selectedImages.removeAll()
        self.collectionThumbnail.reloadData()
    }

    func onUploadingDone(property_id : String)
    {
        resetFields()
        CircularSpinner.hide()

        var headers = Alamofire.SessionManager.defaultHTTPHeaders

        if let accessToken = user!.access_token as? String {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else {
            // redirect to login ???
        }

        //get uploaded property detail
        let parameters = ["user_id": (user?.user_id)!, "property_id": property_id]
        let urlString = BASE_URL + "/listings/getListingById"
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
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let dc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController

                    dc.listing = JSON
                    dc.scrollViewShouldMoveUp = false
                    dc.isOwner = true

                    self.navigationController?.pushViewController(dc, animated: true)
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

    func configureUI() {
        btnChooseFile.layer.borderWidth = 1
        btnChooseFile.layer.borderColor = Utilities.registerBorderColor.cgColor

        vwContacts.layer.cornerRadius = 5
        vwContacts.layer.masksToBounds = true
        vwDetails.layer.cornerRadius = 5
        vwDetails.layer.masksToBounds = true
        vwBuildingInfo.layer.cornerRadius = 5
        vwBuildingInfo.layer.masksToBounds = true

        txtDetailComments.layer.cornerRadius = 5
        txtDetailComments.layer.borderColor = Utilities.borderGrayColor.cgColor
        txtDetailComments.layer.borderWidth = 1
        txtDetailComments.layer.masksToBounds = true

        pickerCategory = LCTableViewPickerControl(frame: CGRect(x: 0, y: Int(self.view.frame.size.height), width: Int(self.view.frame.size.width), height: Int(kPickerControlAgeHeight - 44)), title: "Please Choose an Asset Type", value: pickValue, items: ["Office", "Retail", "Industrial", "Multifamily", "Medical", "Land", "Entertainment", "Specialty", "Hospitality", "Mixed Use", "Residential", "Investment", "Coworking", "Restaurant", "Pad Site", "Flex", "Student Housing"], offset: CGPoint(x: 0, y: 0))

        pickerCategory?.delegate = self
        pickerCategory?.tag = 1002
        self.view.addSubview(pickerCategory!)

        pickerLease = LCTableViewPickerControl(frame: CGRect(x: 0, y: Int(self.view.frame.size.height), width: Int(self.view.frame.size.width), height: Int(kPickerControlAgeHeight)), title: "Please Choose One", value: pickValue, items: ["Lease", "Sale", "Sale & Lease", "Sublease", "Lease (monthly)", "Lease (annually)", "Lease (PSF/Mo)", "Lease (PSF/Ann)"], offset: CGPoint(x: 0, y: 0))

        pickerLease?.delegate = self
        pickerLease?.tag = 1001
        self.view.addSubview(pickerLease!)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resignKeyBoard))
        vwDetails.addGestureRecognizer(tapGesture)

        ivListing.addDashedBorderLayerWithColor(color: Utilities.registerBorderColor.cgColor)

        txtTitle.addUnderline()
        txtRent.addUnderline()
        txtFTAvailable.addUnderline()
        txtParking.addUnderline()
        txtOffices.addUnderline()
        txtBathrooms.addUnderline()
        txtFloors.addUnderline()
        txtEVCharging.addUnderline()
        txtDateAvailable.addUnderline()
        txtAmountPrice.addUnderline()

        setCurrentDate()



        pickerViewDate = UIAlertController(title: "Date Availabe", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        theDatePicker = UIDatePicker(frame: CGRect(x: 0, y: 44, width: 0, height: 0))
        theDatePicker?.datePickerMode = .date
        theDatePicker?.addTarget(self, action: #selector(dateChanged), for: .valueChanged)

        pickerToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        pickerToolbar?.barStyle = .blackOpaque
        pickerToolbar?.sizeToFit()

        pickerToolbar?.setItems([UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(datePickerDoneClick))], animated: true)
        pickerViewDate?.view.addSubview(pickerToolbar!)
        pickerViewDate?.view.addSubview(theDatePicker!)
        pickerViewDate?.view.bounds = CGRect(x: 0, y: 0, width: 320, height: 264)
        txtDateAvailable.inputView = pickerViewDate?.view
    }

    func setCurrentDate()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDateString = dateFormatter.string(from: Date())
        txtDateAvailable.text = currentDateString
    }

    // MARK - Date Picker Delegate , Methods

    @objc func datePickerDoneClick() {
        _ = self.closeDatePicker()
    }

    func closeDatePicker() -> Bool {
        pickerViewDate?.dismiss(animated: true, completion: nil)
        txtDateAvailable.resignFirstResponder()
        return true
    }

    @objc func dateChanged() {
        txtDateAvailable.text = Utilities.str(fromDateShort: (theDatePicker?.date)!)
    }

    // --- //


    @objc func resignKeyBoard() {
        activeField?.resignFirstResponder()
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
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func actMap(_ sender: Any) {
        activeField?.resignFirstResponder()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dc = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        dc.selectedLocation = currentPlacemark?.location?.coordinate
        dc.selectedPlacemark = currentPlacemark
        dc.delegate = self
        self.navigationController?.pushViewController(dc, animated: true)
    }

    @IBAction func actMap1(_ sender: Any) {
        activeField?.resignFirstResponder()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dc = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        dc.selectedLocation = currentPlacemark?.location?.coordinate
        dc.selectedPlacemark = currentPlacemark
        dc.delegate = self
        self.navigationController?.pushViewController(dc, animated: true)
    }

    @IBAction func actScrollToTop(_ sender: Any) {
        scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }

    @IBAction func actChangePhoto(_ sender: Any) {
        txtAmountPrice.resignFirstResponder()
        pickerLease?.dismiss()
        pickerCategory?.dismiss()

        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let photo = UIAlertAction(title: "Photo", style: .default) { (_ alert: UIAlertAction) in

            self.selectedImages.removeAll()

            let pickerController = DKImagePickerController()
            pickerController.maxSelectableCount = Utilities.MAX_UPLOAD_COUNT
            pickerController.allowMultipleTypes = false
            pickerController.assetType = .allPhotos
            pickerController.showsEmptyAlbums = false
            pickerController.didCancel = { () in

                UIApplication.shared.isStatusBarHidden = true
            }
            pickerController.didSelectAssets = { (assets: [DKAsset]) in
                print("didSelectAssets")
                print(assets)

                for asset in assets
                {
                    asset.fetchOriginalImage(true, completeBlock: {(image, _) in

                        if image != nil
                        {
                            self.selectedImages.append(image!)
                        }
                    })
                }

                if self.selectedImages.count != 0
                {
                    self.ivListing.image = self.selectedImages[0]
                    UIApplication.shared.isStatusBarHidden = true
                    self.lblUploadPhoto.isHidden = true

                    self.collectionThumbnail.reloadData()
                }
            }

            self.present(pickerController, animated: true) {}
        }
        let pdf = UIAlertAction(title: "PDF", style: .default) { (_ alert: UIAlertAction) in
            self.isGeneratingPDF = true
            self.actChooseFile(self)
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        //sheet.addAction(camera)
        sheet.addAction(photo)
        sheet.addAction(pdf)
        self.present(sheet, animated: true)
    }

    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera.",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        self.present(
            alertVC,
            animated: true,
            completion: nil)
    }

    @IBAction func onPublish(_ sender: Any) {
        activeField?.resignFirstResponder()
        txtDetailComments.resignFirstResponder()

        if (self.txtTitle.text == "" || ivListing.image == nil || currentPlacemark == nil || txtFTAvailable.text == "" || txtAmountPrice.text == "" || self.txtDateAvailable.text == "") {
            let alert = UIAlertController(title: "QuantumListing", message: "Please input all required fields.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if (!(user?.isUpdatedProfile)!) {
            let alert = UIAlertController(title: "QuantumListing", message: "Please update profile including contact info before you submit.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        self.txtTitle.resignFirstResponder()
        if (self.isValidMembership()) {
            let main_params: NSMutableDictionary = [
                "user_id": (user?.user_id)!,
                "property_name": self.txtTitle.text!,
                "property_type" : self.txtBuildingType.text!,
                "property_for" : self.txtLeaseType.text!,
                "description": self.txtDetailComments.text!,
                "amount": self.txtAmountPrice.text!.replacingOccurrences(of: "$", with: ""),
                "rent": self.txtRent.text!,
                "area": self.txtFTAvailable.text!,
                "date_available" : self.txtDateAvailable.text!
            ]

            let detail_params: NSMutableDictionary = [
                "parking": self.txtParking.text!,
                "offices": self.txtOffices.text!,
                "bathrooms": self.txtBathrooms.text!,
                "floors": self.txtFloors.text!,
                "ev_charging": self.txtEVCharging.text!
            ]

            if (currentPlacemark != nil) {
                main_params.setValue("\((currentPlacemark?.location?.coordinate.latitude)!)", forKey: "latitude")
                main_params.setValue("\((currentPlacemark?.location?.coordinate.longitude)!)", forKey: "lognitude")
                main_params.setValue((currentPlacemark?.addressDictionary?["FormattedAddressLines"] as! [String]).joined(separator: ", "), forKey: "address")
            }

            let parameters: Parameters = ["main_params": main_params, "detail_params": detail_params]

            var headers = Alamofire.SessionManager.defaultHTTPHeaders

            if let accessToken = user!.access_token as? String {
                headers["Authorization"] = "Bearer \(accessToken)"
            } else {
                // redirect to login ???
            }

            CircularSpinner.show("Publishing", animated: true, type: .indeterminate, showDismissButton: false)
            let urlString = BASE_URL + "/profile/publishProperty"
            print("API CALL: \(urlString)")
            print("Params: \(String(describing: parameters))")
            Alamofire.request(urlString, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON {
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
                            self.uploadImagesWithPropertyId(String(JSON["id"] as! Int), self.attachedPDFURL)
                        }
                        else {
                            self.view.endEditing(true)
                            let alert = UIAlertController(title: "QuantumListing", message: JSON["message"] as! String, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            CircularSpinner.hide()
                        }
                    }

                case .failure(let error):
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        print("Data: \(utf8Text)")
                    }

//                    let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
                    self.view.endEditing(true)
                    self.resetFields()
                    CircularSpinner.hide()
                }
            }
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Please upgrade your membership to access all Premium features of QuantumListing.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            let action = UIAlertAction(title: "Upgrade", style: .default, handler: { (alertAction: UIAlertAction) in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let dc = storyboard.instantiateViewController(withIdentifier: "MembershipViewController") as! MembershipViewController
                self.navigationController?.pushViewController(dc, animated: true)
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func uploadImagesWithPropertyId(_ property_id: String, _ pdfURL: URL?) {
        var headers = Alamofire.SessionManager.defaultHTTPHeaders

        if let accessToken = user!.access_token as? String {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else {
            // redirect to login ???
        }

        var parameters = ["property_id": property_id, "featured" : "featured.jpg"]
        let urlString = BASE_URL + "/publish/uploadImages"
        print("UPLOAD API CALL: \(urlString)")
        print("Params: \(String(describing: parameters))")
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
                if self.selectedImages.count == 0
                {
                    multipartFormData.append(UIImageJPEGRepresentation(self.ivListing.image!, 0.5)!, withName: "fileToUpload[]", fileName: "featured.jpg", mimeType: "image/jpeg")
                }
                else
                {
                    multipartFormData.append(UIImageJPEGRepresentation(self.selectedImages[0], 0.5)!, withName: "fileToUpload[]", fileName: "featured.jpg", mimeType: "image/jpeg")

                    for index in 1..<self.selectedImages.count
                    {
                        multipartFormData.append(UIImageJPEGRepresentation(self.selectedImages[index], 0.5)!, withName: "fileToUpload[]", fileName: "photo\(index).jpg", mimeType: "image/jpeg")
                    }
                }
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
                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                            print("Data: \(utf8Text)")
                        }

                        if pdfURL != nil
                        {
                            self.uploadDocumentWithPropertyId(property_id, pdfURL!)
                        }
                        else {
                            self.onUploadingDone(property_id: property_id)
                            //CircularSpinner.hide()
                            //let alert = UIAlertController(title: "QuantumListing", message: "Successfully Uploaded.", preferredStyle: UIAlertControllerStyle.alert)
                            //alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            //self.present(alert, animated: true, completion: nil)
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )

    }

    func uploadDocumentWithPropertyId(_ property_id: String, _ pdfURL: URL) {
        var headers = Alamofire.SessionManager.defaultHTTPHeaders

        if let accessToken = user!.access_token as? String {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else {
            // redirect to login ???
        }

        var parameters = ["property_id": property_id]
        let urlString = BASE_URL + "/publish/uploadDocuments"
        print("UPLOAD API CALL: \(urlString)")
        print("Params: \(String(describing: parameters))")
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
                do {
                    let d = try NSData(contentsOfFile: (self.attachedPDFURL?.path)!, options: NSData.ReadingOptions(rawValue: 0))
                    multipartFormData.append(d as Data, withName: "fileToUpload", fileName: (self.attachedPDFURL?.pathComponents.last)!, mimeType: "")
                }
                catch {

                }
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
                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                            print("Data: \(utf8Text)")
                        }

                        if let result = response.result.value{
                            do {
                                let JSON = result as! NSDictionary
                                //if (JSON["result"] as! NSArray).object(at: 0) as! Int == 1 {
                                if (JSON["success"] as! Int) == 1 {
                                    self.onUploadingDone(property_id: property_id)
                                    //CircularSpinner.hide()
                                    //let alert = UIAlertController(title: "QuantumListing", message: "Successfully Uploaded.", preferredStyle: UIAlertControllerStyle.alert)
                                    //alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                    //self.present(alert, animated: true, completion: nil)
                                }
                            }
                            catch {
                                CircularSpinner.hide()
                            }
                            self.view.endEditing(true)
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        )
    }

    func isValidMembership() -> Bool {
        let str_end = user?.ms_endDate
        if (str_end != nil) {
            let endDate = Utilities.date(fromString: str_end!)
            if (endDate.timeIntervalSinceNow > 0) {
                return true
            }
        }
        return false
    }

    @IBAction func actAssetType(_ sender: Any) {
        self.view.endEditing(true)
        pickerCategory?.show(in: self.view)
    }

    @IBAction func actChooseFile(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dc = storyboard.instantiateViewController(withIdentifier: "PDFManageViewController") as! PDFManageViewController
        dc.delegate = self
        let pdfNav = UINavigationController.init(rootViewController: dc)
        pdfNav.isNavigationBarHidden = true
        self.navigationController?.present(pdfNav, animated: true, completion: nil)
    }

    @IBAction func actLeaseType(_ sender: Any) {
        self.view.endEditing(true)
        pickerLease?.show(in: self.view)
    }

    // UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField

        if (textField == txtAmountPrice) {
            txtAmountPrice.text = txtAmountPrice.text?.replacingOccurrences(of: "$", with: "")
        }

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField == txtAmountPrice) {
            txtAmountPrice.text = "$\(txtAmountPrice.text!)"
        }
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {

        activeField = textView

        return true
    }

    // Touches Delegate

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeField?.resignFirstResponder()
    }


    // PDFManagerViewControllerDelegate
    func getAttachedDocumentRef(_ filePath: String) -> CGPDFDocument? {
        let inputPDFFileAsCString = filePath.cString(using: .ascii)
        let path = CFStringCreateWithCString(nil, inputPDFFileAsCString, CFStringEncoding(CFStringEncodings.UTF7.rawValue))

        let url = CFURLCreateWithFileSystemPath(nil, path, CFURLPathStyle.cfurlposixPathStyle, false)

        let document = CGPDFDocument(url!)

        if (document?.numberOfPages == 0) {
            return nil
        }

        return document
    }

    func generatePDFImage() -> UIImage? {

        let document = getAttachedDocumentRef((self.attachedPDFURL?.path)!)
        guard let page = document?.page(at: 1) else { return nil }

        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)

            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height);
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0);

            ctx.cgContext.drawPDFPage(page);
        }

        return img
    }

    @objc func didAttachedPDFWithDictionary(_ pdf: String) {
        btnChooseFile.setTitle(pdf, for: .normal)
        self.attachedPDFURL = self.fullPathWithFileName(pdf)
        if (isGeneratingPDF)! {
            ivListing.image = self.generatePDFImage()
            lblUploadPhoto.isHidden = true
        }
    }
    func fullPathWithFileName(_ filename: String) -> URL {
        return URL(fileURLWithPath: "\(self.inboxPath())/\(filename)")
    }

    func documentsPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }

    func inboxPath() -> String {
        return self.documentsPath().appending("/Inbox")
    }

    // MapViewControllerDelegate

    func didSelectedPlacemark(_ placemark: CLPlacemark) {
        lblLocation.text = (placemark.addressDictionary?["FormattedAddressLines"] as! [String]).joined(separator: ", ")
        self.currentPlacemark = placemark
    }

    // LCTableViewPickerDelegate
    func dismissPickerControl(_ view: LCTableViewPickerControl) {
        view.dismiss()
    }

    func select(_ view: LCTableViewPickerControl!, didSelectWithItem item: Any!) {
        self.pickValue = item
        if (item as! String == "") {

        }
        else {
            if (view.tag == 1001) {
                txtLeaseType.text = item as? String

                let strLeaseType = item as! String
                if strLeaseType.lowercased().range(of: "sale") != nil {
                    txtAmountPrice.setPlaceholder("Price*", floatingTitle: "Price*")
                }
                else if strLeaseType.lowercased().range(of: "psf") != nil {
                    txtAmountPrice.setPlaceholder("Rent PSF*", floatingTitle: "Rent PSF*")
                }
                else {
                    txtAmountPrice.setPlaceholder("Rent*", floatingTitle: "Rent*")
                }

                if strLeaseType.lowercased().range(of: "sale & lease") != nil {
                    txtAmountPrice.setPlaceholder("Price*", floatingTitle: "Price*")
                    txtRent.setPlaceholder("Rent", floatingTitle: "Rent")
                    txtRent.isEnabled = true
                }
                else {
                    txtRent.setPlaceholder("", floatingTitle: "")
                    txtRent.isEnabled = false
                    txtRent.text = ""
                }
            }
            else if (view.tag == 1002) {
                txtBuildingType.text = item as? String

                let strAssetType = item as! String
                if strAssetType.lowercased().range(of: "land") != nil {
                    txtFTAvailable.setPlaceholder("Acres Available*", floatingTitle: "Acres Available*")
                }
                else {
                    txtFTAvailable.setPlaceholder("SQ.FT. Available*", floatingTitle: "SQ.FT. Available*")
                }
            }
        }

        self.dismissPickerControl(view)
    }

    func select(_ view: LCTableViewPickerControl!, didCancelWithItem item: Any!) {
        self.dismissPickerControl(view)
    }


    // MARK :- CollectionView Delegate Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return Utilities.MAX_UPLOAD_COUNT
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailCell", for: indexPath)

        let imageView = cell.viewWithTag(1) as! UIImageView
        let plusLabel = cell.viewWithTag(2) as! UILabel

        if indexPath.row < selectedImages.count
        {
            plusLabel.text = "\(indexPath.row + 1)"
            plusLabel.isHidden = false
            imageView.image = selectedImages[indexPath.row]
        }
        else
        {
            plusLabel.isHidden = true
            imageView.addDashedBorderLayerWithColor(color: Utilities.registerBorderColor.cgColor)
            imageView.image = UIImage()
        }

        return cell
    }
}
