//
//  CollectionCell.swift
//  QuantumListing
//
//  Created by gOd on 4/13/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit

class CollectionCell: UICollectionViewCell {
    var imgView: UIImageView?
    var lblTitle: UILabel?
    var listing: NSDictionary?
    var title: String!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imgView = UIImageView(frame: CGRect(x: 2, y: 2, width: frame.size.width - 4, height: frame.size.height - 25))
        imgView?.clipsToBounds = true
        imgView?.contentMode = .scaleAspectFill
        
        lblTitle = UILabel(frame: CGRect(x: 2, y: 2 + frame.size.height - 25 + 2, width: frame.size.width - 4, height: 19))
        lblTitle?.backgroundColor = UIColor.white
        
        self.addSubview(imgView!)
        self.addSubview(lblTitle!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell() {
        let images = listing?["images"]
        var strURL = ""
        
        if images is NSDictionary
        {
            strURL = (images as! NSDictionary)["property_image"] as! String
        }
        else if (images is NSArray && (images as! NSArray).count > 0)
        {
            strURL = ((images as! NSArray)[0] as! NSDictionary)["property_image"] as! String
        }
        else
        {
            return
        }

        imgView?.setShowActivityIndicator(true)
        imgView?.setIndicatorStyle(.gray)
        
        if (strURL != "") {
            imgView?.sd_setImage(with: URL(string: strURL)!)
        }
        else {
            imgView?.image = nil
        }
        
        let property_name = listing?["property_name"] as? String
        if property_name != nil {
            lblTitle?.text = " \(property_name as! String)"
        }
        else {
            lblTitle?.text = " \(self.title as! String)"
        }
    }
}
