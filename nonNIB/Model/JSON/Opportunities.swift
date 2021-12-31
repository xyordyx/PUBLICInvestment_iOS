//
//  Opportunities.swift
//  nonNIB
//
//  Created by Martinez Giancarlo on 22/11/21.
//

import Foundation

class Opportunities: Encodable, Decodable{
    var _id: String?
    var currency: String?
    var debtor: Debtor?
    var evaluation: Evaluation?
    var isConfirming: Bool?
    var advanceAmount: String?
    var toBeCollectedIn: Int?
    var paymentDate: String?
    var tem: String?
    var tea: String?
    var onSale: Bool?
    var availableBalanceAmount: String?
    
    var isScheduled: Bool?
    var time: Int?
    var adjustedAmount: Double?
    var autoAdjusted: Bool?
    var message: String?
    var completed: Bool?
    var amountToInvest: Double?
    var timeToInvest: Int?
    
    
}
