//
//  HistoryCell.swift
//  nonNIB
//
//  Created by Martinez Giancarlo on 19/11/21.
//

import UIKit

class HistoryCell: UITableViewCell {



    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var dueDaysLabel: UILabel!
    @IBOutlet weak var profitLabel: UILabel!
    @IBOutlet weak var temLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var historyViewCell: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        historyViewCell.layer.cornerRadius = historyViewCell.frame.size.height / 5
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
