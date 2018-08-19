//
//  UserCell.swift
//  QuantumListing
//
//  Created by Colin Taylor on 5/27/17.
//  Copyright © 2017 lucky clover. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var ivPortrait: UIImageView!
    @IBOutlet weak var lblUserType: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setAvatarImageURL(imageURL: String)
    {
        ivPortrait.setShowActivityIndicator(true)
        ivPortrait.setIndicatorStyle(.gray)
        if (imageURL != "") {
            self.ivPortrait.sd_setImage(with: URL(string: imageURL)!, placeholderImage: UIImage(named: "my_avatar_icon.png"))
        }
        else {
            //self.ivPortrait.image = nil
        }
    }


    func configureCell() {
        ivPortrait.layer.cornerRadius = ivPortrait.bounds.width / 2.0
        ivPortrait.layer.masksToBounds = true

        self.selectionStyle = .none
    }

}
