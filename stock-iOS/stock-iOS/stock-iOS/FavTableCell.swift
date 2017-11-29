//
//  FavTableCell.swift
//  stock-iOS
//
//  Created by Loli on 11/29/17.
//  Copyright © 2017 Wenfei Cao. All rights reserved.
//

import UIKit

class FavTableCell: UITableViewCell {

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
