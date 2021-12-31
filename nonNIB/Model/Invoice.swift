//
//  Invoice.swift
//  nonNIB
//
//  Created by Martinez Giancarlo on 22/11/21.
//

import Foundation

class Invoice{
    var opportunitie: Opportunities
    var amountToInvest: Double
    var timeToInvest: Int
    
    var isScheduled: Bool?
    
    init(_ opp: Opportunities){
        self.opportunitie = opp
        self.amountToInvest = 0.00
        self.timeToInvest = 0
        self.isScheduled = false
    }
}
