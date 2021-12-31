//
//  CIGStatistics.swift
//  Finsmart
//
//  Created by Martinez Giancarlo on 24/12/21.
//

import Foundation
import Alamofire

protocol  CIGStatisticsDelegate {
    func didFailWithError(error : Error)
    func didUpdateFinancialBalance(_ cigManager: CIGStatistics, _ finTran: FinancialBalance)
    
}

class CIGStatistics{
    
    let extraDataUrl = "http://localhost:8080/getextradata"
    //let extraDataUrl = "https://hmrestapi-333720.uk.r.appspot.com/getextradata"
    
    var delegate : CIGStatisticsDelegate?
    
    var headers: HTTPHeaders = [
        "Authorization": "",
        "Accept": "application/json"
    ]
    
    func getExtraData(_ token: String){
        headers.update(name: "Authorization", value: token)
        AF.request(extraDataUrl, headers: headers).responseDecodable(of: FinancialBalance.self) { response in
            switch response.result{
            case .success:
                if let currentSchule = self.parseFinancialBalanceJSON(response.data!){
                    self.delegate?.didUpdateFinancialBalance(self, currentSchule)
                }
            case .failure(let error):
                self.delegate?.didFailWithError(error: error)
            }
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
}

