//
//  ScheduleCell.swift
//  nonNIB
//
//  Created by Martinez Giancarlo on 20/11/21.
//

import UIKit

class ScheduleCell: UITableViewCell {

    @IBOutlet weak var originalAmountLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var supplierLabel: UILabel!
    @IBOutlet weak var scheduleViewCell: UIView!
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
    
    
