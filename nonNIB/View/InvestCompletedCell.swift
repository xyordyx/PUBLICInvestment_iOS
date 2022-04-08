//
//  InvestCompletedCell.swift
//  Finsmart
//
//  Created by Martinez Giancarlo on 18/01/22.
//

import UIKit

class InvestCompletedCell: UITableViewCell {

    @IBOutlet weak var wrongIcon: UIImageView!
    @IBOutlet weak var equalIcon: UIImageView!
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var debtoLabel: UILabel!
    @IBOutlet weak var view: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        imageIcon.image = imageIcon.image?.withRenderingMode(.alwaysTemplate)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
