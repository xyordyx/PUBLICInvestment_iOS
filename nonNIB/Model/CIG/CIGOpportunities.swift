//
//  CIGOpportunities.swift
//  Finsmart
//
//  Created by Martinez Giancarlo on 14/12/21.
//

import Foundation
import Alamofire

protocol CIGOppDelegate{
    func didGotResponse(_ cigManager: CIGOpportunities,_ statusResponse: Bool)
    func didFailWithError(error : Error)
}

class CIGOpportunities{
    
    //let createInvestmentUrl = "http://localhost:8080/createinvestment"
    let createInvestmentUrl = "https://hmnorth.uk.r.appspot.com/createinvestment"
    
    var delegate : CIGOppDelegate?
    
    let util = Util()
    
    func createInvestment(_ amount: Double,_ smartToken: String,_ userId: String,_ op: Opportunities){
        let parameters = InvestmentJSON(amount,smartToken,userId,op)
        
        AF.request(createInvestmentUrl,method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).validate(statusCode: 200..<299).response
        {
            (response) in switch response.result
            {
            case .success(_):
                if let data = self.parseInvestmentResponse(response.data!){
                    self.delegate?.didGotResponse(self, data)
                }
            case .failure(let error):
                self.delegate?.didFailWithError(error: error)
            }
        }
    }
    
    //MARK: - PARSERS
    
    func parseInvestmentResponse(_ finsmartData : Data) -> Bool?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(Bool.self, from: finsmartData)
            return decodedData
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

