//
//  DetailsTableCell.swift
//  stock-iOS
//
//  Created by Loli on 11/27/17.
//  Copyright © 2017 Wenfei Cao. All rights reserved.
//

import UIKit

class DetailsTableCell: UITableViewCell {

    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
