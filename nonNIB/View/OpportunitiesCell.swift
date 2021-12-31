//
//  OpportunitiesCell.swift
//  Finsmart
//
//  Created by Martinez Giancarlo on 26/11/21.
//

import UIKit

class OpportunitiesCell: UITableViewCell {

    @IBOutlet weak var confirmingLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var teaLabel: UILabel!
    @IBOutlet weak var temLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var oppVIew: UIView!
    @IBOutlet weak var supplierLabel: UILabel!
    var invoiceID: String!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
