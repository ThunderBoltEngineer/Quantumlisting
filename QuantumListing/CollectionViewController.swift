 //
//  CollectionViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/24/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import CircularSpinner
import Alamofire

class CollectionViewController: UIViewController ,UICollectionViewDelegate, UICollectionViewDataSource{

    @IBOutlet weak var lblNotification: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    let kCollectionCellId = "CollectionCell"
    var listings: NSMutableArray?

    override func viewDidLoad() {
        super.viewDidLoad()
        listings = NSMutableArray()
        self.updateData()
        self.collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: kCollectionCellId)

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(actSwipe))
        collectionView.addGestureRecognizer(swipeGesture)
        // Do any additional setup after loading the view.

        self.view.backgroundColor = UIColor.white
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func actSwipe(_ gesture: UISwipeGestureRecognizer) {
        let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView))
        if (indexPath != nil) {
            self.deleteItemAtIndexPath(indexPath!)
        }
    }

    func updateData() {
        self.getCollections()
    }

    func getCollections() {

        var headers = Alamofire.SessionManager.defaultHTTPHeaders

        if let accessToken = user!.access_token as? String {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else {
            // redirect to login ???
        }

        let parameters = ["user_id": (user?.user_id)!]

        CircularSpinner.show("Loading", animated: true, type: .indeterminate, showDismissButton: false)
        let urlString = BASE_URL + "/profile/getFavorites"
        print("API CALL: \(urlString)")
        print("Params: \(String(describing: parameters))")
        Alamofire.request(urlString, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print("Request: \(response.request?.httpMethod as! String) \(response.request!)")
            print("Response: \(response.response?.statusCode as! Int) (\(response.data!))")
            debugPrint(response.result)

            switch response.result {
            case .success:
                if ((self.listings?.count)! > 0) {
                    self.listings?.removeAllObjects()
                }
                else {
                    self.listings = NSMutableArray()
                }
                if let result = response.result.value{
                    let JSON = result as! NSArray
                    print("Listings count: \(JSON.count)")
                    // TODO CHECK JSON["status"] && JSON["status"] as! Int == 0
                    
                    self.listings?.addObjects(from: JSON as! [Any])
                    self.collectionView.reloadData()

                    if (self.listings?.count == 0) {
                        self.lblNotification.isHidden = false
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

    // UICollectionViewDataSource


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (listings?.count)!
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCollectionCellId, for: indexPath) as! CollectionCell
        let listing = listings?.object(at: indexPath.row) as! NSDictionary
        let listing_property = listing["property_info"] as! NSDictionary
        var listing_images: NSDictionary = [:]

        if listing["property_image"] is NSDictionary {
            listing_images = NSDictionary(object: listing["property_image"], forKey: "images" as NSCopying)
        }
        else {
            if (listing["property_image"] as! NSArray).count > 0 {
                listing_images = NSDictionary(object: (listing["property_image"] as! NSArray)[0] as! NSDictionary, forKey: "images" as NSCopying)
            }
        }
//        let listing_images = NSDictionary(object: (listing["property_image"] as! NSArray)[0] as! NSDictionary, forKey: "images" as NSCopying)

        cell.listing = listing_images
        cell.title = listing_property["property_name"] as! String
        cell.configureCell()
        cell.backgroundColor = UIColor.darkGray
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        let dict = listings?[indexPath.row] as? NSDictionary

        dc.listing = dict
        dc.isOwner = false
        dc.scrollViewShouldMoveUp = false

        self.navigationController?.pushViewController(dc, animated: true)

    }

    func deleteItemAtIndexPath(_ indexPath: IndexPath) {
        let listing = listings?.object(at: indexPath.row) as! NSDictionary
        let listing_property = listing["property_info"] as! NSDictionary

        var headers = Alamofire.SessionManager.defaultHTTPHeaders

        if let accessToken = user!.access_token as? String {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else {
            // redirect to login ???
        }

        let parameters = ["property_id": listing_property["property_id"] as! String, "user_id": (user?.user_id)!]

        CircularSpinner.show("Deleting", animated: true, type: .indeterminate, showDismissButton: false)
        let urlString = BASE_URL + "/profile/deleteFavorites"
        print("API CALL: \(urlString)")
        print("Params: \(String(describing: parameters))")
        Alamofire.request(urlString, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print("Request: \(response.request?.httpMethod as! String) \(response.request!)")
            print("Response: \(response.response?.statusCode as! Int) (\(response.data!))")
            debugPrint(response.result)

            switch response.result {
            case .success:
                if ((self.listings?.count)! > 0) {
                    self.listings?.removeAllObjects()
                }
                else {
                    self.listings = NSMutableArray()
                }
                if let result = response.result.value{
                    let JSON = result as! NSArray
                    // TODO CHECK JSON["status"] && JSON["status"] as! Int == 0
                    
                    self.listings?.addObjects(from: JSON as! [Any])
                    self.collectionView.reloadData()

                    if (self.listings?.count == 0) {
                        self.lblNotification.isHidden = false
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
}
