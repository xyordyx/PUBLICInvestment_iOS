//
//  FinsmartModel.swift
//  nonNIB
//
//  Created by Martinez Giancarlo on 20/11/21.
//

import Foundation

struct FinancialStats{
    var totalPENDeposited: Double?
    var totalUSDDeposited: Double?
    var totalPENAvailable: Double?
    var totalUSDAvailable: Double?
    var totalPENProfited: Double?
    var totalUSDProfited: Double?
    var totalPENInProgress: Double?
    var totalUSDInProgress: Double?
    var totalPENForecast: Double?
    var totalUSDForecast: Double?
    var totalPENOnRisk: Double?
    var totalUSDOnRisk: Double?
    
    var totalPENDisplay: Double?
    var totalUSDDisplay: Double?
}

class DataModel{
    static let shared = DataModel()
    var opportunities = [String: Opportunities]()
    var financialStats = FinancialStats()
    var token: String?
}

struct ScheduleData{
    var opportunities = [String : Opportunities]()
    var amountPENScheduled = 0.00
    var amountUSDScheduled = 0.00
}

