//
//  FollowUserTableViewController.swift
//  QuantumListing
//
//  Created by Colin Taylor on 5/27/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import CircularSpinner
import Alamofire

class FollowUserTableViewController: UITableViewController {

    var userIdList : [String] = [String]()
    var navTitle : String = ""
    var userList : NSMutableArray?
    var downloaded = 0

    @IBAction func onBackTapped(_ sender: Any) {

        self.navigationController?.popViewController(animated: true)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = navTitle

        self.userList = NSMutableArray()

        loadData()
    }



    func loadData()
    {
        for user_id in userIdList
        {
            var headers = Alamofire.SessionManager.defaultHTTPHeaders

            if let accessToken = user!.access_token as? String {
                headers["Authorization"] = "Bearer \(accessToken)"
            } else {
                // redirect to login ???
            }

            let parameters = ["user_id": user_id]

            CircularSpinner.show("Loading", animated: true, type: .indeterminate, showDismissButton: false)
            let urlString = BASE_URL + "/profile/getUserById"
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
                        
                        let user_info = JSON["user_info"] as? NSDictionary

                        if user_info != nil
                        {
                            self.userList?.add(NSMutableDictionary(dictionary: user_info as! NSDictionary))
                        }
                    }
                    self.tableView.reloadData()

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (userList?.count)!
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell

        let user_info = userList?[indexPath.row] as! NSDictionary

        cell.lblUserName.text = user_info["full_name"] as? String

        cell.lblUserType.text = user_info["type"] as? String

        let strAvartar = user_info["profile_pic"] as? String
        if strAvartar != nil {
            cell.setAvatarImageURL(imageURL: user_info["profile_pic"] as! String)
        }

        cell.configureCell()

        return cell


    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let userVC = storyboard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
        userVC.user_info = NSMutableDictionary(dictionary : userList?[indexPath.row] as! NSDictionary)
        self.navigationController?.pushViewController(userVC, animated: true)
    }
}
