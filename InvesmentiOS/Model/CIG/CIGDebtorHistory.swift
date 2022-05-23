//
//  CIGDebtorHistory.swift
//
//  Created by Martinez Giancarlo on 13/12/21.
//

import Foundation
import Alamofire

protocol  CIGDebtorHistoryDelegate {
    func didUpdatDebtorSummary(_ cigManager: CIGDebtorHistory,_ debtorSummary: DebtorHistory,_ currency: String)
    func didUpdatDebtorHistory(_ cigManager: CIGDebtorHistory,_ debtorHistory: DebtorQuery)
    func didFailWithError(error : Error)
}

class CIGDebtorHistory{

    let debtorSummaryUrl = "https://api.platform/"
    
    let debtorHistoryUrl = "http://localhost:8080/getdebtorhistory?filter="
    
    var delegate : CIGDebtorHistoryDelegate?
    
    var headers: HTTPHeaders = [
        "Authorization": "",
        "Accept": "application/json"
    ]
    
    func getDebtorSummary(_ token: String,_ debtorId: String,_ currency: String){
        headers.update(name: "Authorization", value: "Bearer "+token)
        AF.request(debtorSummaryUrl+debtorId+"?currency="+currency, headers: headers).responseDecodable(of: DebtorHistory.self) { response in
            switch response.result{
            case .success:
                if let history = self.parseDebtorSummaryJSON(response.data!){
                    self.delegate?.didUpdatDebtorSummary(self, history,currency)
                }
            case .failure(let error):
                self.delegate?.didFailWithError(error: error)
            }
        }
    }
    
    func getDebtorHistory(_ debtorId: String,_ token: String){
        headers.update(name: "Authorization", value: token)
        AF.request(debtorHistoryUrl+debtorId, headers: headers).responseDecodable(of: DebtorQuery.self) { response in
            switch response.result{
            case .success:
                if let history = self.parseDebtorHistoryJSON(response.data!){
                    self.delegate?.didUpdatDebtorHistory(self, history)
                }
            case .failure(let error):
                debugPrint(response)
                self.delegate?.didFailWithError(error: error)
            }
        }
    }
    

    
    //MARK: - PARSE SECTION
    func parseDebtorSummaryJSON(_ data : Data) -> DebtorHistory?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(DebtorHistory.self, from: data)
            return decodedData
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseDebtorHistoryJSON(_ data : Data) -> DebtorQuery?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(DebtorQuery.self, from: data)
            return decodedData
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
