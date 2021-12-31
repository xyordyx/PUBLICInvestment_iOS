//
//  CIGOpportunities.swift
//  Finsmart
//
//  Created by Martinez Giancarlo on 14/12/21.
//

import Foundation
import Alamofire

protocol CIGOppDelegate{
    func didGotResponse(_ cigManager: CIGOpportunities,_ codeResponse: Int)
    func didFailWithError(error : Error)
}

class CIGOpportunities{
    
    let scheduleInvestmentUrl = "http://localhost:8080/scheduleinvestment"
    //let scheduleInvestmentUrl = "https://hmrestapi-333720.uk.r.appspot.com/scheduleinvestment"
    
    var delegate : CIGOppDelegate?
    
    func scheduleInvestment(_ amount: Double,_ currency: String,_ invoiceId: String,_ time: Int,_ debtorName: String,_ token: String){
        let parameters = InvestmentJSON(amount, currency, invoiceId, time, debtorName, token)
        AF.request(scheduleInvestmentUrl,method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).response
        { (response) in switch response.result {
        case .success(_):
            if let codeResponse = response.response?.statusCode{
                self.delegate?.didGotResponse(self, codeResponse)
            }
            case .failure(let error):
                self.delegate?.didFailWithError(error: error)
            }
        }
    }
    
    
    //MARK: - PARSERS
    
    func parseInvestmentResponse(_ finsmartData : Data) -> InvestmentResponse?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(InvestmentResponse.self, from: finsmartData)
            return decodedData
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

