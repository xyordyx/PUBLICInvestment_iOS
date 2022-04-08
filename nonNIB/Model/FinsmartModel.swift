//
//  FinsmartModel.swift
//  nonNIB
//
//  Created by Martinez Giancarlo on 20/11/21.
//

import Foundation

struct FinancialStats{
    var totalPENAvailable: Double?
    var totalUSDAvailable: Double?
    
    var totalPENScheduled: Double?
    var totalUSDScheduled: Double?
    
    var totalPENDeposited: Double?
    var totalUSDDeposited: Double?

    var totalPENProfited: Double?
    var totalUSDProfited: Double?
    
    var totalPENCurrentInvested: Double?
    var totalUSDCurrentInvested: Double?
    
    var totalPENForecast: Double?
    var totalUSDForecast: Double?
    
    var totalPENOnRisk: Double?
    var totalUSDOnRisk: Double?
}

class DataModel{
    static let shared = DataModel()
    var opportunities = [String: Opportunities]()
    //var opportunities: [Opportunities]?
    var financialStats = FinancialStats()
    var smartToken: String?
    var scheduledInvestmentsNum: Int = 0
}

struct ScheduleData{
    var opportunities = [String : Opportunities]()
    //var opportunities: [Opportunities]?
    var amountPENScheduled = 0.00
    var amountUSDScheduled = 0.00
}

