//
//  GalleryViewController.swift
//  QuantumListing
//
//  Created by Colin Taylor on 6/7/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import Alamofire

class GalleryViewController: UIViewController, UICollectionViewDataSource {
    @IBOutlet weak var collectionGallery: UICollectionView!

    var galleryUrls : [String] = [String]()
    var property_id : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        getGalleryList()
    }

    override func viewWillAppear(_ animated: Bool) {

        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {

        self.tabBarController?.tabBar.isHidden = false
    }

    func getGalleryList()
    {
        var headers = Alamofire.SessionManager.defaultHTTPHeaders

        if let accessToken = user!.access_token as? String {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else {
            // redirect to login ???
        }

        let parameters = ["property_id" : property_id]

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
                    let resultArray = JSON["images"] as? [String]

                    if resultArray == nil
                    {
                        return
                    }

                    for imgUrl in resultArray!
                    {
                        self.galleryUrls.append(imgUrl)
                    }

                    print("GALLERY URLS: \(self.galleryUrls)")

                    self.collectionGallery.reloadData()
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBack(_ sender: Any) {

        self.navigationController?.popViewController(animated: true)
    }
    //collection view datasource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return galleryUrls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath)

        let imageView = cell.viewWithTag(1) as! UIImageView

        imageView.setShowActivityIndicator(true)
        imageView.setIndicatorStyle(.gray)
        imageView.sd_setImage(with: URL(string: galleryUrls[indexPath.row])!)


        return cell
    }

}
