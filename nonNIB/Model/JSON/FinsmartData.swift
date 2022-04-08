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
    let time: String
    let debtorName: String
    let smartToken: String?
    let saltPass: String
    
    let autoAdjusted: Bool
    let adjustedAmount: Double
    let status: Bool?
    let message: String?
    let completed: Bool
    let currentState: String
    
    init(_ amount: Double,_ currency: String,_ invoiceId: String,_ time: String,_ debtorName: String,_ smartToken: String
         ,_ saltPass: String){
        self.amount = amount
        self.currency = currency
        self.invoiceId = invoiceId
        self.time = time
        self.debtorName = debtorName
        self.smartToken = smartToken
        self.saltPass = saltPass
        
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


