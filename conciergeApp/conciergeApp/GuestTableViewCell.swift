//
//  GuestTableViewCell.swift
//  conciergeApp
//
//  Created by samuel on 3/30/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class GuestTableViewCell: UITableViewCell {

    @IBOutlet weak var roomNumber: UILabel!

    @IBOutlet weak var name: UILabel!

    @IBOutlet weak var phoneNumber: UILabel!

    @IBOutlet weak var checkoutDate: UILabel!
    
    @IBOutlet weak var deleteGuest: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }


}
