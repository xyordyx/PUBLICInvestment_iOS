//
//  FinancialData.swift
//
//  Created by Martinez Giancarlo on 14/03/22.
//

import Foundation

struct FinancialData: Codable{
    var totalPENAvailable: Double
    var totalUSDAvailable: Double
    
    var totalPENScheduled: Double
    var totalUSDScheduled: Double
    
    var totalPENDeposited: Double
    var totalUSDDeposited: Double
    
    var totalPENRetentions: Double
    var totalUSDRetentions: Double
    
    var totalPENProfited: Double
    var totalUSDProfited: Double
    
    var totalPENCurrentInvested: Double
    var totalUSDCurrentInvested: Double
    
    var solesOnRisk: Double
    var dollarOnRisk: Double
    
    var solesProfitExpected: Double
    var dollarProfitExpected: Double
    
    var scheduledInvestmentsNum: Int
    
}
