//
//  DebtorHistory.swift
//
//  Created by Martinez Giancarlo on 13/12/21.
//

import Foundation

struct DebtorHistory: Codable{
    var totalInvoicesAwaitingCollectionCount: Int?
    var totalAmountAwaitingCollection: String?
    var investmentReturned: String?
    var delayedInvoicesCount: Int?
    var amountDelayed: String?
    var invoicesAwaitingCollectionCountPercentage: String?
    var amountAwaitingCollectionPercentage: String?
    var amountAwaitingCollection: String?
    var invoicesAwaitingCollectionCount: Int?
    var amountFinalized: String?
    var finalizedInvoicesCount: Int?
}

struct DebtorQuery: Codable{
    var debtorInvoices: [DebtorInvoices?]
    var delayedInvoices: Int?
}


struct DebtorInvoices: Codable{
    var status: String?
    var tem: Double?
    var tea: Double?
    var currency: String?
    var toBeCollectedIn: String?
    var debtor: Debtor?
    var moraDays: Int?
    var pastDueDays: Int?
    var amountInvested: Double?
    var profitedAmount: Double?
    var expectedProfit: Double?
    var createdAt: String?
}
    
