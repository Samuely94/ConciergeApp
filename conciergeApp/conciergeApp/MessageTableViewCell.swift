//
//  MessageTableViewCell.swift
//  conciergeApp
//
//  Created by Andrea Coldwell on 4/5/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    @IBOutlet weak var guestName: UILabel!
    @IBOutlet weak var roomNumber: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
