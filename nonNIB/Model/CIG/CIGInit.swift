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
    var i = 3
    
    let opportunitiesResumeUrl = "http://localhost:8080/getresumeopps"
    //let opportunitiesResumeUrl = "https://s1-dot-hmrestapi-333720.uk.r.appspot.com/getresumeopps"
    
    let financialBalanceUrl = "http://localhost:8080/getbalance"
    //let financialBalanceUrl = "https://s1-dot-hmrestapi-333720.uk.r.appspot.com/getbalance"
    
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
                    //START FOR TESTING
                    //opps.opportunities = self.parseOpportunitiesTEST()
                    //END FOR TESTING
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
    
    func parseFinancialBalanceJSON(_ finsmartData : Data) -> FinancialData?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(FinancialData.self, from: finsmartData)
            return decodedData
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
    //MARK: - TESTING SECTION
    func parseOpportunitiesTEST() -> [Opportunities]?{
        self.i += 1
        let decoder = JSONDecoder()
        var resource: String?
        if 1 ... 2 ~= self.i{
            resource = "empty"
        }else{
            resource = "oppNov21"
        }
        if let path = Bundle.main.path(forResource: resource, ofType: "json") {
            do{
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let decodedData = try decoder.decode([Opportunities].self, from: data)
                return decodedData
            }catch let error {
                print("parse error: \(String(describing: error))")
            }
           
        } else {
            print("Invalid filename/path.")
        }
        return nil
    }

    
}

