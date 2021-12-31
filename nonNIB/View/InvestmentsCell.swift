//
//  InvestmentsCell.swift
//  Finsmart
//
//  Created by Martinez Giancarlo on 27/12/21.
//

import UIKit

class InvestmentsCell: UITableViewCell {
    
    @IBOutlet weak var profitLabel: UILabel!
    @IBOutlet weak var investmentAmountLabel: UILabel!
    @IBOutlet weak var remainingDaysLabel: UILabel!
    @IBOutlet weak var rucLabel: UILabel!
    @IBOutlet weak var debtorLabel: UILabel!
    @IBOutlet weak var investmentView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        investmentView.layer.cornerRadius = investmentView.frame.size.height / 7.5
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
