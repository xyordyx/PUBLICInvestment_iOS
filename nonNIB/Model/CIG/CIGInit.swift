//
//   CloudIntegrationGateway.swift
//  nonNIB
//
//  Created by Martinez Giancarlo on 20/11/21.
//

import Foundation
import Alamofire

protocol  CIGInitDelegate {
    func didFailWithError(error : Error)
    func didUpdateOpportunities(_ cigManager: CIGInit, _ appData: APPData)
}

class CIGInit{
    //let opportunitiesResumeUrl = "http://localhost:8080/getresumeopps"
    //let financialBalanceUrl = "http://localhost:8080/getbalance"

    let opportunitiesResumeUrl = "https://hmnorth.uk.r.appspot.com/getresumeopps"
    let financialBalanceUrl = "https://hmnorth.uk.r.appspot.com/getbalance"
    
    var delegate : CIGInitDelegate?
    
    var headers: HTTPHeaders = [
        "Authorization": "",
        "ScheduledInvestments":"",
        "Accept": "application/json"
    ]

    func getOpportunities(_ token: String,_ scheduledInvestments: Int){
        headers.update(name: "Authorization", value: token)
        headers.update(name: "ScheduledInvestments", value: String(scheduledInvestments))
        AF.request(opportunitiesResumeUrl, headers: headers).responseDecodable(of: APPData.self) { response in
            switch response.result{
            case .success:
                if let opps = self.parseOpportunitiesJSON(response.data!){
                    self.delegate?.didUpdateOpportunities(self, opps)
                }
            case .failure(let error):
                self.delegate?.didFailWithError(error: error)
            }
        }
    }
    
    
    //MARK: - PARSE SECTION
    
    func parseOpportunitiesJSON(_ finsmartData : Data) -> APPData?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(APPData.self, from: finsmartData)
            return decodedData
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

