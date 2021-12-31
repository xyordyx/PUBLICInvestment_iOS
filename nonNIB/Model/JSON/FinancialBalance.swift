//
//  FinancialBalance.swift
//  Finsmart
//
//  Created by Martinez Giancarlo on 25/11/21.
//

import Foundation

struct FinancialBalance: Codable{
    var totalPENDeposited: Double
    var totalUSDDeposited: Double
    
    var totalPENRetentions: Double
    var totalUSDRetentions: Double
    
    var totalPENProfited: Double
    var totalUSDProfited: Double
    
    var totalPENAvailable: Double
    var totalUSDAvailable: Double
    
    var totalPENInProgress: Double
    var totalUSDInProgress: Double
    
    var solesOnRisk: Double
    var dollarOnRisk: Double
    
    var solesProfitExpected: Double
    var dollarProfitExpected: Double
    
    var invoicesIndex: Int
    var financialIndex: Int
}
