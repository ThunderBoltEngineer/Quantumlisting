//
//  MembershipViewController.swift
//  QuantumListing
//
//  Created by lucky clover on 3/24/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit
import StoreKit
import CircularSpinner
import Alamofire

class MembershipViewController: UIViewController ,SKPaymentTransactionObserver{

    var selectedType: Int?
    var product: SKProduct?
    let IAPHelperProductPurchasedNotification = "IAPHelperProductPurchasedNotification"
    let IAPHelperProductFailedNotification = "IAPHelperProductFailedNotification"


    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var buttonRestore: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(productPurchased), name: NSNotification.Name(rawValue: IAPHelperProductPurchasedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(productPurchasedFailed), name: NSNotification.Name(rawValue: IAPHelperProductFailedNotification), object: nil)

        self.checkStatus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onRestore(_ sender: Any) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    @IBAction func actOneMonth(_ sender: Any) {
        self.updateToServer(4)
    }

    @IBAction func actThreeMonths(_ sender: Any) {
        self.updateToServer(5)
    }

    @IBAction func actOneYear(_ sender: Any) {
        self.updateToServer(6)
    }

    func updateToServer(_ type: Int) {
        selectedType = type
        let defaults = UserDefaults.standard
        if (products?.count == 0) {
            let alert = UIAlertController(title: "QuantumListing", message: "Error on our side, try again later.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

            return
        }

        var selectedId: String? = nil
        if (type == 4) {
            selectedId = "com.quantumlisting.purchase.onemonthlicense"
        }
        else if (type == 5) {
            selectedId = "com.quantumlisting.purchase.threemonthlicense"
        }
        else if (type == 6) {
            selectedId = "com.quantumlisting.purchase.oneyearlicense"
        }

        for productTemp in (products)! {
            if ((productTemp as! SKProduct).productIdentifier == selectedId) {
                product = productTemp as? SKProduct
                break
            }
        }

        print(defaults.bool(forKey: (product?.productIdentifier)!))
        print((product?.productIdentifier)!)

        if (product != nil && defaults.bool(forKey: (product?.productIdentifier)!)) {
            self.upgradeMembership()
        }
        else {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = product!.priceLocale
            let priceString = numberFormatter.string(from: product!.price)

            let alert = UIAlertController(title: "QuantumListing", message: "Click OK to add unlimited Listings to your account for \(priceString!)", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (alert: UIAlertAction!) -> Void in

                RentagraphAPHelper.sharedInstance().buy(self.product!)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) -> Void in

            }

            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    @objc func productPurchased() {
        self.upgradeMembership()
    }

    @objc func productPurchasedFailed() {
        let alert = UIAlertController(title: "QuantumListing", message: "Failed to payment transaction. Please try with another Apple account again.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func checkStatus() {
        var membership = "Free"
        if (user?.ms_type == "Premium") {
            membership = "Premium"
        }

        let str = "You are now a \(membership) Member of QuantumListing"

        let attrText = NSMutableAttributedString(string: str)
        attrText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: (str as NSString).range(of: membership))
        lblStatus.attributedText = attrText
    }

    func upgradeMembership() {
        let start_date = Date()
        var end_date: Date? = nil
        var dateComponents = DateComponents()
        let calendar = Calendar.current

        if (selectedType == 4) {
            dateComponents.month = 1
        }
        else if (selectedType == 5) {
            dateComponents.month = 3
        }
        else if (selectedType == 6) {
            dateComponents.year = 1
        }
        end_date = calendar.date(byAdding: dateComponents, to: start_date)

        let str_start = Utilities.str(from: start_date)
        let str_end = Utilities.str(from: end_date!)

        let parameters = ["start_date": start_date, "end_date": end_date!, "user_id": (user?.user_id)!] as [String : Any]

        var headers = Alamofire.SessionManager.defaultHTTPHeaders

        if let accessToken = user!.access_token as? String {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else {
            // redirect to login ???
        }

        CircularSpinner.show("Upgrading", animated: true, type: .indeterminate, showDismissButton: false)
        let urlString = BASE_URL + "/profile/upgradeMembership"
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
                    let status = JSON["status"] as! Bool
                    if (status) {
                        user?.ms_endDate = str_end
                        user?.ms_startDate = str_start
                        user?.ms_type = "Premium"

                        saveUserInfo()
                        self.checkStatus()
                    }
                    else {
                        let alert = UIAlertController(title: "QuantumListing", message: JSON["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }

            case .failure(let error):
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                }
//
//                let alert = UIAlertController(title: "QuantumListing", message: "Connection failed with reason : \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
            }
            CircularSpinner.hide()
        }
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        for transaction in queue.transactions {
            let productID = transaction.payment.productIdentifier

            if (productID == "com.quantumlisting.purchase.onemonthlicnese") {
                selectedType = 4
            }
            else if (productID == "com.quantumlisting.purchase.threemonthlicense") {
                selectedType = 5
            }
            else if (productID == "com.quantumlisting.purchase.oneyearlicense") {
                selectedType = 6
            }

            self.upgradeMembership()
        }
    }

    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {

    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Add Payment")

        for transaction:AnyObject in transactions{
            let trans = transaction as! SKPaymentTransaction
            print(trans.error!)
            switch trans.transactionState{
            case .purchased:
                self.productPurchased()
                break
            case .failed:
                self.productPurchasedFailed()
                break
            default:
                print("default: Error")
                break
            }
        }
    }

    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        print("Purchases Restored")

        _ = []
        for transaction in queue.transactions {
            let t: SKPaymentTransaction = transaction as SKPaymentTransaction

            let prodID = t.payment.productIdentifier as String
            switch prodID{
            case "IAP id":
                break

            default:
                print("IAP not setup")
            }


        }
    }
    func finishTransaction(trans:SKPaymentTransaction){
        print("Finshed Transaction")
    }

    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print("Remove Transaction")
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
