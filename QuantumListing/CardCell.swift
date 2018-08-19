//
//  CardCell.swift
//  QuantumListing
//
//  Created by Colin Taylor on 6/19/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit

class CardCell: UITableViewCell {

    var index: Int?
    var listing_id: String?
    var listing_contacts: String?
    var listing_website: String?
    var listing_phone: String?
    var listing_email: String?
    var isHaveContact: Bool?
    var is_Owner: Bool?
    var delegate: ListingCellDelegate?
    var isBEditable: Bool?
    
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var kiTitle: UILabel!
    @IBOutlet weak var buttonAddress: UIButton!
    @IBOutlet weak var lblLeaseType: UILabel!
    @IBOutlet weak var lblRentPSF: UILabel!
    @IBOutlet weak var ivListing: UIImageView!
    @IBOutlet weak var txtEditTitle: UITextField!
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var vwPortrait: UIView!
    @IBOutlet weak var ivAvartar: UIImageView!
    @IBOutlet weak var ivPortrait: UIImageView!
    @IBOutlet weak var lblSQFT: UILabel!
    @IBOutlet weak var lblAssetType: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var btnFavorite: UIButton!
    

    @IBAction func actUser(_ sender: Any) {
        self.delegate?.didPressedUserIndex(self.index!)
    }
    
    @IBAction func actReport(_ sender: Any) {
        self.delegate?.didPressedActionButton(self.index!)
    }
    
    @IBAction func onAddress(_ sender: Any) {
        self.delegate?.didPressedAddressIndex(self.index!)
    }

    @IBAction func actFavorite(_ sender: Any) {
        self.delegate?.didPressedLikeButton(self.index!)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setImageURL(imageURL: String) {
        
        self.ivListing.setShowActivityIndicator(true)
        self.ivListing.setIndicatorStyle(.gray)
        if imageURL != "" {
            self.ivListing.sd_setImage(with: URL(string: imageURL)!)
        }
        else {
            self.ivListing.image = nil
        }
    }
    
    func setAvatarImageURL(imageURL: String)
    {
        if (imageURL != "") {
            self.ivAvartar.sd_setImage(with: URL(string: imageURL)!)
            self.ivAvartar.setShowActivityIndicator(true)
            self.ivAvartar.setIndicatorStyle(.gray)
            self.ivPortrait.isHidden = true
        }
        else {
            self.ivAvartar.image = nil
            self.ivPortrait.isHidden = false
        }
    }
    
    func setHaveContact(hc: Bool) {
        isHaveContact = hc
    }
    
    func configureCell() {
        vwPortrait.layer.cornerRadius = vwPortrait.bounds.width / 2.0
        vwPortrait.layer.masksToBounds = true

        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = Utilities.borderGrayColor.cgColor
        
        bgView.layer.shadowColor = UIColor.gray.cgColor
        bgView.layer.shadowOpacity = 0.3
        bgView.layer.shadowRadius = 4.0
        bgView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 4
        
        self.selectionStyle = .none
    }
    
    func configureListingInfo(listing: NSDictionary) {
        
        let listing_images = listing["property_image"] as? NSArray
        
        var listing_image = NSDictionary()
        
        if(listing_images != nil) {
            listing_image = listing_images?[0] as! NSDictionary
            let strPath = listing_image["property_image"] as? String
            if strPath != nil {
                self.setImageURL(imageURL: strPath!)
            }
        }
        
        let listing_user = listing["user_info"] as! NSDictionary
        if(true) {
            self.setHaveContact(hc: true)
            self.listing_email = listing_user["email"] as? String
            self.listing_phone = listing_user["mobile"] as? String
            self.listing_website = listing_user["website"] as? String
            let strUser = listing_user["full_name"] as? String
            if (strUser != nil) {
                self.lblUsername?.text = strUser
            }
            let strAvartar = listing_user["profile_pic"] as? String
            if strAvartar != nil {
                self.setAvatarImageURL(imageURL: strAvartar!)
            }
        }
        
        //let temp = listings?.object(at: self.index) as! NSDictionary
        //self.lblDate?.text = "\(abs((temp["time_elapsed"] as! NSString).integerValue)) days"
        
        let property_info = listing["property_info"] as! NSDictionary
        if(true) {
            let strTitle = property_info["property_name"] as? String
            if strTitle != nil {
                self.kiTitle?.text = strTitle!
            }
            
            self.buttonAddress?.setTitle("   \(property_info["address"] as! String)", for: UIControlState.normal)
            
            let strAssetType = property_info["property_type"] as! String
            let strLeaseType = property_info["property_for"] as! String
            
            var area = "Inquire"
            if (property_info["area"] != nil &&
                (property_info["area"] as! String) != "" &&
                Float((property_info["area"] as! String).replacingOccurrences(of: ",", with: ""))! > 0.0) {
            
                var area_unit = "SQFT"
                if strAssetType.lowercased().range(of: "land") != nil {
                    area_unit = "Acres"
                }
                area = "\(property_info["area"] as! String) \(area_unit as! String)"
            }
            
            var amount_text = "Rent"
            if strLeaseType.lowercased().range(of: "sale") != nil {
                amount_text = "Price"
            }
            else if strLeaseType.lowercased().range(of: "psf") != nil {
                amount_text = "Rent PSF"
            }
            
            var amount = "Inquire"
            if (property_info["amount"] != nil &&
                (property_info["amount"] as! String) != "" &&
                Float((property_info["amount"] as! String).replacingOccurrences(of: ",", with: ""))! > 0.0) {
                
                amount = "$\(property_info["amount"] as! String)"
                
                if strLeaseType.lowercased().range(of: "sale & lease") != nil {
                    if (property_info["rent"] != nil &&
                        (property_info["rent"] as? String ?? "") != "" &&
                        Float((property_info["rent"] as! String).replacingOccurrences(of: ",", with: ""))! > 0.0) {
                        amount_text = "Price/Rent PSF"
                        amount = "\(amount)/\(property_info["rent"] as! String)"
                    }
                }
            }
            
            self.lblAssetType?.text = strAssetType
            self.lblLeaseType?.text = strLeaseType
            self.lblSQFT?.text = area
            self.lblRentPSF?.text = amount
        }
    }
    
    @IBAction func actEmail(_ sender: Any) {
        if (self.listing_email != nil) {
            UIApplication.shared.open(URL(string: "mailto:\(self.listing_email!)")!, options: [:], completionHandler: nil)
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no valid email address has been entered.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func actPhone(_ sender: Any) {
        if (self.listing_phone != nil) {
            listing_phone = listing_phone?.replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "+", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
            UIApplication.shared.open(URL(string: "tel:\(self.listing_phone!)")!, options: [:], completionHandler: nil)
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no valid phone number has been entered.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func actWebsite(_ sender: Any) {
        if (self.listing_website != nil) && (self.listing_website?.characters.count ?? 0) > 4 {
            if (self.listing_website?.substring(to: (self.listing_website?.index((self.listing_website?.startIndex)!, offsetBy: 4))!) == "http") {
                UIApplication.shared.open(URL(string: self.listing_website!)!, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.open(URL(string: "http://\(self.listing_website!)")!, options: [:], completionHandler: nil)
            }
        }
        else {
            let alert = UIAlertController(title: "QuantumListing", message: "Sorry, no valid website address has been entered.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            
        }
    }
}
