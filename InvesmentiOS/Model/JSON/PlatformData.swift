//
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

    let invoiceId: String
    //LOGIC WERE REMOVED
    
    
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


