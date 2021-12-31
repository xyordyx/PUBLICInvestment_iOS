//
//   CloudIntegrationGateway.swift
//  nonNIB
//
//  Created by Martinez Giancarlo on 20/11/21.
//

import Foundation
import Alamofire

protocol  CIGInitDelegate {
    func didUpdateToken(_ cigManager: CIGInit,_ token: String)
    func didFailWithError(error : Error)
    func didUpdateOpportunities(_ cigManager: CIGInit, _ ops: [Opportunities])
    func didUpdateFinancialBalance(_ cigManager: CIGInit, _ finTran: FinancialBalance)
    func didFinancialBalanceGotUpdate(_ cigManager: CIGInit, _ finTran: FinancialBalance)
    
}

class CIGInit{
    var i = 3
    
    let loginUrl = "https://api.finsmart.pe/api/v1/authentications"
    let opportunitiesUrl = "https://api.finsmart.pe/api/v1/opportunities"
    
    let financialBalanceUrl = "http://localhost:8080/getbalance"
    //let financialBalanceUrl = "https://hmrestapi-333720.uk.r.appspot.com/getbalance"
    
    var delegate : CIGInitDelegate?
    
    var headers: HTTPHeaders = [
        "Authorization": "",
        "Accept": "application/json"
    ]

    func getOpportunities(_ token: String){
        headers.update(name: "Authorization", value: "Bearer "+token)
        AF.request(opportunitiesUrl, headers: headers).responseDecodable(of: [Opportunities].self) { response in
            switch response.result{
            case .success:
                //FOR TESTING
                //if let opps = self.parseOpportunitiesTEST(){
                
                if let opps = self.parseOpportunitiesJSON(response.data!){
                    self.delegate?.didUpdateOpportunities(self, opps)
                }
            case .failure(let error):
                self.delegate?.didFailWithError(error: error)
            }
        }
    }
    
    func getFinancialBalance(_ token: String){
        headers.update(name: "Authorization", value: token)
        AF.request(financialBalanceUrl, headers: headers).responseDecodable(of: FinancialBalance.self) { response in
            switch response.result{
            case .success:
                if let finTran = self.parseFinancialBalanceJSON(response.data!){
                    self.delegate?.didUpdateFinancialBalance(self, finTran)
                }
            case .failure(let error):
                self.delegate?.didFailWithError(error: error)
            }
        }
    }
    
    func updateFinancialBalance(_ token: String){
        headers.update(name: "Authorization", value: token)
        AF.request(financialBalanceUrl, headers: headers).responseDecodable(of: FinancialBalance.self) { response in
            switch response.result{
            case .success:
                if let finTran = self.parseFinancialBalanceJSON(response.data!){
                    self.delegate?.didFinancialBalanceGotUpdate(self, finTran)
                }
            case .failure(let error):
                self.delegate?.didFailWithError(error: error)
            }
        }
    }
    
    func getToken(email: String, actualPassword: String){
        if let url = URL(string: loginUrl){
            //Create URL session
            let login = LoginParameters(email: email, actualPassword: actualPassword)
            AF.request(url,
                       method: .post,
                       parameters: login,
                       encoder: JSONParameterEncoder.default).responseDecodable(of: Login.self) { response in
                switch response.result{
                case .success:
                    if let token = self.parseTokenJSON(response.data!){
                        self.delegate?.didUpdateToken(self, token)
                    }
                case .failure(let error):
                    self.delegate?.didFailWithError(error: error)
                }
            }
        }
    }
    
    //MARK: - PARSE SECTION
    
    func parseTokenJSON(_ finsmartData : Data) -> String?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(Login.self, from: finsmartData)
            return decodedData.accessToken
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseOpportunitiesJSON(_ finsmartData : Data) -> [Opportunities]?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode([Opportunities].self, from: finsmartData)
            return decodedData
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseFinancialBalanceJSON(_ finsmartData : Data) -> FinancialBalance?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(FinancialBalance.self, from: finsmartData)
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
                print("parse error: \(error.localizedDescription)")
            }
           
        } else {
            print("Invalid filename/path.")
        }
        return nil
    }

    
}

