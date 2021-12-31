//
//  StatisticsCell.swift
//  Finsmart
//
//  Created by Martinez Giancarlo on 24/12/21.
//

import UIKit

class StatisticsCell: UITableViewCell {

    
    @IBOutlet weak var dollarLabel: UILabel!
    @IBOutlet weak var solesLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statsView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        statsView.layer.cornerRadius = statsView.frame.size.height / 5
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
