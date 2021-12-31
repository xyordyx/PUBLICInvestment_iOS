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

class InvestmentJSON: Encodable, Decodable{
    let amount: Double
    let currency: String
    let invoiceId: String
    let time: Int
    let debtorName: String
    let token: String
    
    let autoAdjusted: Bool
    let adjustedAmount: Double
    let status: Bool?
    let message: String?
    let completed: Bool
    
    init(_ amount: Double,_ currency: String,_ invoiceId: String,_ time: Int,_ debtorName: String,_ token: String){
        self.amount = amount
        self.currency = currency
        self.invoiceId = invoiceId
        self.time = time
        self.debtorName = debtorName
        self.token = token
        
        self.autoAdjusted = false
        self.adjustedAmount = 0.00
        self.status = false
        self.message = ""
        self.completed = false
    }
}

struct ScheduleResponse: Codable{
    let response: String?
}

struct InvestmentResponse: Codable{
    let response: String
    let isScheduled: String
}


