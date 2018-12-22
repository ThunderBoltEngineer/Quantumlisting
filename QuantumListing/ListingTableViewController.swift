//
//  ListingTableViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/30/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import CircularSpinner
import ESPullToRefresh
import UXMPDFKit
import Alamofire

class ListingTableViewController: UITableViewController, ListingCellDelegate, CLLocationManagerDelegate{

    var listings : NSMutableArray?
    var selectedDict: NSDictionary?
    var locationManager: CLLocationManager?
    var currentIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()
        listings = NSMutableArray()

        currentIndex = 0

        //add tap gesture recognizer to the title view
        let titleView = UILabel()
        titleView.text = "PUBLIC LISTINGS"
        titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width : width, height : 500))
        self.navigationItem.titleView = titleView
        self.navigationItem.titleView?.isUserInteractionEnabled = true

        self.navigationItem.titleView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapTitle(_:))))

        self.tableView.es.addPullToRefresh {
            self.updateData()
        }
        self.tableView.es.addInfiniteScrolling {
            self.loadMore()
        }
        self.tableView.es.startPullToRefresh()
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.updateData()
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func onTapTitle(_ : UITapGestureRecognizer)
    {
        //refresh
        self.tableView.es.startPullToRefresh()
    }

    func updateData() {
        listings?.removeAllObjects()
        self.tableView.reloadData()
        currentIndex = 0
        self.getFeed()
    }

    func getFeed() {
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        
        if let accessToken = user!.access_token as? String {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else {
            // redirect to login ???
        }
        
        let parameters = ["user_id": (user?.user_id)!, "property_type": "recent", "index": String.init(format: "%d", currentIndex!)]

        CircularSpinner.show("Loading", animated: true, type: .indeterminate, showDismissButton: false, delegate: nil)
        let urlString = BASE_URL + "/listings/getListings"
        print("API CALL: \(urlString)")
        print("Params: \(String(describing: parameters))")
        
        Alamofire.request(urlString, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in

            switch response.result {
            case .success:
                if let result = response.result.value{
                    let JSON = result as! NSArray
                    print("Listings count: \(JSON.count)")
                    for object in JSON
                    {
                        let info = (object as! NSDictionary)
                        if info["user_info"] is NSDictionary && info["property_info"] is NSDictionary
                        {
                            self.listings?.add(NSMutableDictionary(dictionary: object as! NSDictionary))
                        }
                    }

                    self.tableView.reloadData()

                }
                self.tableView.es.stopPullToRefresh()
                self.tableView.es.stopLoadingMore()
                self.view.endEditing(true)

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


    func loadMore()
    {
        if(currentIndex! >= 90) {
            self.tableView.es.stopPullToRefresh()
            self.tableView.es.stopLoadingMore()
            let alert = UIAlertController(title: "QuantumListing", message: "You can find more Listings in search.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            currentIndex! += 10
            self.getFeed()
        }
    }

        // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (listings?.count)!
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! CardCell

        if listings?.count == 0 {
            return cell
        }

        let listing = listings?[indexPath.row] as! NSDictionary

        cell.delegate = self
        cell.index = indexPath.row

        cell.configureCell()
        cell.configureListingInfo(listing: listing)


        var isFavorite = listing["isFavorite"] as? Int ?? 0

        // This info isn't updated dynamically
        //let favorites = property_info["favorites"] as? NSArray
        //for item in favorites!
        //{
        //    let user_id = (item as! NSNumber).stringValue
        //    if (user_id == user!.user_id as? String) {
        //        isFavorite = 1
        //    }
        //}

        cell.btnFavorite?.setImage(UIImage(named: isFavorite == 0 ? "flag@4x" : "flag_fill@4x"), for: .normal)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {


        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        print(indexPath.row)
        let dict = listings?[indexPath.row] as? NSDictionary
        dc.listing = dict
        dc.scrollViewShouldMoveUp = false
        dc.isOwner = (dict?["user_info"] as! NSDictionary)["user_id"] as! String == user!.user_id ? true : false
        dc.listingVC = self

        self.navigationController?.pushViewController(dc, animated: true)
    }

    // ListingCellDelegate

    func didPressedLikeButton(_ index: Int) {
        selectedDict = listings?[index] as?  NSDictionary
        favorite_property(index: index)

    }

    func didPressedAddressIndex(_ index: Int) {
        let dict = listings?[index] as! NSDictionary
        let listing_property = dict["property_info"] as! NSDictionary

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController

        let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees((listing_property["latitude"] as! NSString).doubleValue), CLLocationDegrees((listing_property["lognitude"] as! NSString).doubleValue))
        if (coordinate.latitude != 0 && coordinate.longitude != 0) {
            mapVC.selectedLocation = coordinate
            self.navigationController?.pushViewController(mapVC, animated: true)
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no map location was added.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func didPressedActionButton(_ index: Int) {
        selectedDict = listings?.object(at: index) as? NSDictionary
        let listing_property = selectedDict?["property_info"] as! NSDictionary
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
//        let viewAction = UIAlertAction(title: "View on Map", style: .default) { (alert: UIAlertAction!) -> Void in
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let mapVC = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
//
//            let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees((listing_property["latitude"] as! NSString).doubleValue), CLLocationDegrees((listing_property["lognitude"] as! NSString).doubleValue))
//            if (coordinate.latitude != 0 && coordinate.longitude != 0) {
//                mapVC.selectedLocation = coordinate
//                self.navigationController?.pushViewController(mapVC, animated: true)
//            }
//            else {
//                let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no map location was added.", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//            }
//        }
//
//        let galleryAction = UIAlertAction(title: "Open Gallery", style: .default){
//            (alert : UIAlertAction!) -> Void in
//
//            let galleryVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryViewController") as! GalleryViewController
//            galleryVC.property_id = listing_property["property_id"] as! String
//
//            self.navigationController?.pushViewController(galleryVC, animated: true)
//
//        }

        let attachAction = UIAlertAction(title: "Open Attachment", style: .default) { (alert: UIAlertAction!) -> Void in
            let attachment = (listing_property["document"] as? String ?? "") as! NSString
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

//        let favAction = UIAlertAction(title: "Save to Favorites", style: UIAlertActionStyle.default) { (alert: UIAlertAction!) in
//            //let defaults = UserDefaults.standard
//
//            if self.delegate?.products?.count == 0 {
//                let alert = UIAlertController(title: "QuantumListing", message: "Error on our side, try again later.", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//                return
//            }
//            if self.isValidMembership() {
//                self.productPurchased()
//            }
//            else {
//                let alert = UIAlertController(title: "QuantumListing", message: "Please upgrade your membership to access all Premium features of QuantumListing.", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//
//            }
//        }

        let flagAction = UIAlertAction(title: "Flag As Inappropriate", style: UIAlertActionStyle.default) { (alert: UIAlertAction!) in
            self.reportProperty(listing_property["property_id"] as! String)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alert: UIAlertAction!) in

        }

        //actionSheet.addAction(viewAction)
        //actionSheet.addAction(galleryAction)
        actionSheet.addAction(attachAction)
        //actionSheet.addAction(favAction)
        //actionSheet.addAction(flagAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion:nil)
    }

    func didPressedCommentButton(_ index: Int) {

    }

    func didPressedShowCommentButton(_ index: Int) {

    }

    func didPressedShowLikeButton(_ index: Int) {

    }

    func didPressedHashTag(_ hashtag: String) {

    }

    func didPressedUserIndex(_ index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let userVC = storyboard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
        let listing = listings?[index] as! NSDictionary
        userVC.user_info = NSMutableDictionary(dictionary: listing.object(forKey: "user_info") as! NSDictionary)
        self.navigationController?.pushViewController(userVC, animated: true)
    }

    func didPressedUsername(_ username: String) {

    }

    func isValidMembership() -> Bool {
        let str_end = user!.ms_endDate
        let endDate = Utilities.date(fromString: str_end)
        if (endDate.timeIntervalSinceNow > 0) {
            return true
        }
        return false
    }

    // CLLocation Delegate Methods

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedAlways) {
            locationManager?.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations[0]
        let nowLocation = currentLocation.coordinate
        user?.latitude = String(format: "%f", nowLocation.latitude)
        user?.longitude = String(format: "%f", nowLocation.longitude)

        saveUserInfo()
        locationManager?.stopUpdatingLocation()
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

            let document = try PDFDocument(filePath: filePath, password: "password_if_needed")
            let pdf = PDFViewController(document: document)

            self.navigationController?.pushViewController(pdf, animated: true)
        }
        catch let error {
            print(error)

            let alert = UIAlertController(title: "QuantumListing", message: "Failed to open PDF", preferredStyle: UIAlertControllerStyle.alert)
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
                if let result = response.result.value{
                    let alert = UIAlertController(title: "QuantumListing", message: "Successfully reported.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
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

    func favorite_property(index : Int) {
        if (selectedDict == nil) {
            return;
        }
        let listing_property = selectedDict?["property_info"] as! NSDictionary

        var headers = Alamofire.SessionManager.defaultHTTPHeaders

        if let accessToken = user!.access_token as? String {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else {
            // redirect to login ???
        }

        let parameters = ["property_id": listing_property["property_id"] as! String, "user_id": (user?.user_id)!]

        //CircularSpinner.show("", animated: true, type: .indeterminate, showDismissButton: false)
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

                    (self.listings?[index] as! NSMutableDictionary)["isFavorite"] = status
                    self.tableView.reloadData()
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

    // IAP Management

//    func productPurchased() {
//        self.favorite_property()
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
