//
//  ChangeViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/22/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import CircularSpinner
import ESPullToRefresh
import CoreLocation
import Alamofire

class ChangeViewController: UIViewController, ListingCellDelegate, UITableViewDelegate, UITableViewDataSource{

    var listings: NSMutableArray?
    var currentIndex: Int?

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var lblNoListings: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        listings = NSMutableArray()
        currentIndex = 0;

        self.myTableView.es.addPullToRefresh {
            self.updateData()
        }
        self.myTableView.es.addInfiniteScrolling {
            self.loadMore()
        }
        //self.myTableView.es.startPullToRefresh()

        //add tap gesture recognizer to the title view
        let titleView = UILabel()
        titleView.text = "MY LISTINGS"
        titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width : width, height : 500))
        self.navigationItem.titleView = titleView
        self.navigationItem.titleView?.isUserInteractionEnabled = true
        self.navigationItem.titleView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapTitle(_:))))

        let leftBtn = UIButton.init(type: .custom)
        leftBtn.setImage(UIImage.init(named: "pdf_flat"), for: UIControlState.normal)
        leftBtn.addTarget(self, action:#selector(actStore(_:)), for:.touchUpInside)
        leftBtn.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
        let leftBarBtn = UIBarButtonItem.init(customView: leftBtn)
        self.navigationItem.leftBarButtonItem = leftBarBtn

        let rightBtn = UIButton.init(type: .custom)
        rightBtn.setImage(UIImage.init(named: "btn_collections"), for: UIControlState.normal)
        rightBtn.addTarget(self, action:#selector(actCollection(_:)), for:.touchUpInside)
        rightBtn.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
        let rightBarBtn = UIBarButtonItem.init(customView: rightBtn)
        self.navigationItem.rightBarButtonItem = rightBarBtn
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }

    @objc func onTapTitle(_ : UITapGestureRecognizer)
    {
        //scroll to top
        self.myTableView.es.startPullToRefresh()
    }


    func updateData() {
        listings?.removeAllObjects()
        currentIndex = 0
        self.myTableView.reloadData()
        self.getFeed()
    }

    func getFeed() {

        var headers = Alamofire.SessionManager.defaultHTTPHeaders

        if let accessToken = user!.access_token as? String {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else {
            // redirect to login ???
        }

        let parameters = ["user_id": (user?.user_id)!, "index": String(format: "%d", self.currentIndex!)]

        CircularSpinner.show("Loading", animated: true, type: .indeterminate, showDismissButton: false)
        let urlString = BASE_URL + "/listings/getMyListings"
        print("API CALL: \(urlString)")
        print("Params: \(String(describing: parameters))")
        Alamofire.request(urlString, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print("Request: \(response.request?.httpMethod as! String) \(response.request!)")
            print("Response: \(response.response?.statusCode as! Int) (\(response.data!))")
            debugPrint(response.result)

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
                            self.listings?.add(object)
                        }
                    }

                    self.myTableView.reloadData()
                    if ((self.listings?.count)! > 0) {
                        self.lblNoListings.isHidden = true
                    }
                }
                self.myTableView.es.stopLoadingMore()
                self.myTableView.es.stopPullToRefresh()

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
        currentIndex! += 10
        self.getFeed()
    }


    // TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (listings?.count)!
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! CardCell

        if listings?.count == 0 {
            return cell
        }

        let listing = listings?[indexPath.row] as! NSDictionary

        cell.delegate = self
        cell.index = indexPath.row

        cell.configureCell()
        cell.configureListingInfo(listing: listing)

        cell.buttonAddress.isHidden = false
        //cell.viewAddress.isHidden = false

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        print(indexPath.row)
        let dict = listings?[indexPath.row] as? NSDictionary
        dc.listing = dict
        dc.isOwner = true
        dc.scrollViewShouldMoveUp = false

        self.navigationController?.pushViewController(dc, animated: true)
    }

    // Cell Delegate
    func didPressedLikeButton(_ index: Int) {

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
        let listing = listings?.object(at: index) as! NSDictionary
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        let albumAction = UIAlertAction(title: "Save to album", style: .default) { (alert: UIAlertAction!) -> Void in
            let cell = self.myTableView.cellForRow(at: IndexPath(row: index, section: 0)) as! CardCell
            UIImageWriteToSavedPhotosAlbum(cell.ivListing.image!, nil, nil, nil)
        }

        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (alert: UIAlertAction!) -> Void in
            let id = ((listing["property_info"] as! NSDictionary)["property_id"] as! String)
            //let temp = listing["property_info"] as! NSDictionary
            self.deleteProperty(id)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alert: UIAlertAction!) in

        }

        actionSheet.addAction(albumAction)
        actionSheet.addAction(deleteAction)
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
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let userVC = storyboard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController

        self.navigationController?.pushViewController(userVC, animated: true)
        */
    }

    func didPressedUsername(_ username: String) {

    }

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

    func deleteProperty(_ property_id: String) {
        var headers = Alamofire.SessionManager.defaultHTTPHeaders

        if let accessToken = user!.access_token as? String {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else {
            // redirect to login ???
        }

        let parameters = ["property_id": property_id, "user_id": (user?.user_id)!]

        CircularSpinner.show("Deleting", animated: true, type: .indeterminate, showDismissButton: false)
        let urlString = BASE_URL + "/listings/deleteListing"
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
                        self.updateData()
                    }

                    let alert = UIAlertController(title: "QuantumListing", message: JSON["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
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

    func isValidMembership() -> Bool {
        let str_end = user!.ms_endDate
        let endDate = Utilities.date(fromString: str_end)
        if (endDate.timeIntervalSinceNow > 0) {
            return true
        }
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func actStore(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pdfVC = storyboard.instantiateViewController(withIdentifier: "PDFManageViewController") as! PDFManageViewController
        pdfVC.isHideDisclaimer = true
        let pdfNav = UINavigationController(rootViewController: pdfVC)
        pdfNav.isNavigationBarHidden = true
        self.navigationController?.present(pdfNav, animated: true, completion: nil)
    }

    @IBAction func actCollection(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let collectionVC = storyboard.instantiateViewController(withIdentifier: "CollectionViewController") as! CollectionViewController
        self.navigationController?.pushViewController(collectionVC, animated: true)
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
