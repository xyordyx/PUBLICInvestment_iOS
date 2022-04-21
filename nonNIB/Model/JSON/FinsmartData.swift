//
//  LoginFinsmart.swift
//  nonNIB
//
//  Created by Martinez Giancarlo on 20/11/21.
//

import Foundation

struct LoginParameters: Encodable {
    let email: String
    let actualPassword: String
}

struct LoginParametersFire: Encodable {
    let email: String
    let password: String
    let returnSecureToken: Bool
}

class InvestmentJSON: Encodable, Decodable{
    let amount: Double
    let currency: String
    let invoiceId: String
    let debtorName: String
    let smartToken: String?
    let onSale: Bool?
    let onSaleSlot: Int
    
    let autoAdjusted: Bool
    let adjustedAmount: Double
    let status: Bool
    let message: String?
    let completed: Bool
    let currentState: String
    let userId: String
    
    
    init(_ amount: Double,_ smartToken: String,_ userId: String,_ opportunitie: Opportunities){
        self.amount = amount
        self.currency = opportunitie.currency!
        self.invoiceId = opportunitie._id!
        self.onSale = opportunitie.onSale
        self.onSaleSlot = opportunitie.onSaleSlot!
        self.debtorName = (opportunitie.debtor?.companyName!)!
        self.smartToken = smartToken
        self.userId = userId
        
        self.autoAdjusted = false
        self.adjustedAmount = 0.00
        self.status = false
        self.message = ""
        self.completed = false
        self.currentState = ""
    }
}

struct ScheduleResponse: Codable{
    let response: String?
}

struct InvestmentResponse: Codable{
    let response: String
    let isScheduled: String
}

struct ResponseJSON: Codable{
    let status: Bool
    let message: String
}


